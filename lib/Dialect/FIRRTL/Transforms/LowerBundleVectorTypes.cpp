//===- LowerBundleVectorTypes.cpp - Lower Aggregate Types -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the LowerBundleVectorTypes pass.  This pass replaces
// aggregate types with expanded values.
//
// This pass walks the operations in reverse order. This lets it visit users
// before defs. Users can usually be expanded out to multiple operations (think
// mux of a bundle to muxes of each field) with a temporary subWhatever op
// inserted. When processing an aggregate producer, we blow out the op as
// appropriate, then walk the users, often those are subWhatever ops which can
// be bypassed and deleted. Function arguments are logically last on the
// operation visit order and walked left to right, being peeled one layer at a
// time with replacements inserted to the right of the original argument.
//
// Each processing of an op peels one layer of aggregate type off.  Because new
// ops are inserted immediately above the current up, the walk will visit them
// next, effectively recusing on the aggregate types, without recusing.  These
// potentially temporary ops(if the aggregate is complex) effectively serve as
// the worklist.  Often aggregates are shallow, so the new ops are the final
// ones.
//
//===----------------------------------------------------------------------===//

#include "PassDetails.h"
#include "circt/Dialect/FIRRTL/FIRRTLOps.h"
#include "circt/Dialect/FIRRTL/FIRRTLTypes.h"
#include "circt/Dialect/FIRRTL/FIRRTLVisitors.h"
#include "circt/Dialect/FIRRTL/Passes.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "llvm/Support/Parallel.h"
#include <deque>

    using namespace circt;
using namespace firrtl;

// TODO: check all argument types
namespace {
/// This represents a flattened bundle field element.
struct FlatBundleFieldEntry {
  /// This is the underlying ground type of the field.
  FIRRTLType type;
  /// The index in the parent type
  size_t index;
  /// This is a suffix to add to the field name to make it unique.
  SmallString<16> suffix;
  /// This indicates whether the field was flipped to be an output.
  bool isOutput;

  FlatBundleFieldEntry(const FIRRTLType &type, size_t index, StringRef suffix,
                       bool isOutput)
      : type(type), index(index), suffix(suffix), isOutput(isOutput) {}
};
} // end anonymous namespace

/// Peel one layer of an aggregate type into its components.  Type may be
/// complex, but empty, in which case fields is empty, but the return is true.
static bool peelType(Type type, SmallVectorImpl<FlatBundleFieldEntry>& fields) {
  return TypeSwitch<Type, bool>(type)
      .Case<BundleType>([&](auto bundle) {
        SmallString<16> tmpSuffix;
        // Otherwise, we have a bundle type.  Break it down.
        for (auto &elt : llvm::enumerate(bundle.getElements())) {
          // Construct the suffix to pass down.
          tmpSuffix.resize(0);
          tmpSuffix.push_back('_');
          tmpSuffix.append(elt.value().name.getValue());
          fields.emplace_back(elt.value().type, elt.index(), tmpSuffix,
                              elt.value().isFlip);
        }
        return true;
      })
      .Case<FVectorType>([&](auto vector) {
        // Increment the field ID to point to the first element.
        for (size_t i = 0, e = vector.getNumElements(); i != e; ++i) {
          fields.emplace_back(vector.getElementType(), i,
                              "_" + std::to_string(i), false);
        }
        return true;
      })
      .Default([](auto op) { return false; });
}

static MemOp cloneMemWithNewType(ImplicitLocOpBuilder *b, MemOp op,
                                 FIRRTLType type, StringRef suffix) {
  SmallVector<Type, 8> ports;
  SmallVector<Attribute, 8> portNames;
  for (auto port : op.getPorts()) {
    ports.push_back(MemOp::getTypeForPort(op.depth(), type, port.second));
    portNames.push_back(port.first);
  }
  return b->create<MemOp>(ports, op.readLatency(), op.writeLatency(),
                          op.depth(), op.ruw(), b->getArrayAttr(portNames),
                          (op.name() + suffix).str(), op.annotations());
}

/// Look through and collect subfields leading to a subaccess.
static SmallVector<Operation *> getSAWritePath(Operation *op) {
  SmallVector<Operation *> retval;
  auto defOp = op->getOperand(0).getDefiningOp();
  while (defOp && isa<SubfieldOp, SubindexOp, SubaccessOp>(defOp)) {
    retval.push_back(defOp);
    defOp = defOp->getOperand(0).getDefiningOp();
  }
  // Trim to the subaccess
  while (!retval.empty() && !isa<SubaccessOp>(retval.back()))
    retval.pop_back();
  return retval;
}

/// Copy annotations from \p annotations to \p loweredAttrs, except annotations
/// with "target" key, that do not match the field suffix.
static SmallVector<Attribute> filterAnnotations(ArrayAttr annotations,
                                                StringRef suffix) {
  SmallVector<Attribute> retval;
  if (!annotations || annotations.empty())
    return retval;

  for (auto opAttr : annotations) {
    auto di = opAttr.dyn_cast<DictionaryAttr>();
    if (!di) {
      retval.push_back(opAttr);
      continue;
    }
    auto targetAttr = di.get("target");
    if (!targetAttr) {
      retval.push_back(opAttr);
      continue;
    }

    ArrayAttr subFieldTarget = targetAttr.cast<ArrayAttr>();
    SmallString<16> targetStr = subFieldTarget[0].cast<StringAttr>().getValue();
    // The fNameStr will begin with either '[' or '.', replace it with an
    // '_' to construct the suffix.
    targetStr[0] = '_';
    // If it ends with ']', then just remove it.
    if (targetStr.back() == ']')
      targetStr.pop_back();

    // If no subfield attribute, then copy the annotation.
    if (targetStr.empty()) {
      assert(0);
      retval.push_back(opAttr);
      continue;
    }
    // If the subfield suffix doesn't match, then ignore the annotation.
    if (!targetStr.equals(suffix))
      continue;

    NamedAttrList modAttr;
    for (auto attr : di.getValue()) {
      // Ignore the actual target annotation, but copy the rest of annotations.
      if (attr.first.str() == "target") {
        if (subFieldTarget.size() > 1)
          modAttr.append(attr.first,
                         ArrayAttr::get(annotations.getContext(),
                                        subFieldTarget.getValue().slice(1)));

      } else {
        modAttr.push_back(attr);
      }
    }
    retval.push_back(DictionaryAttr::get(annotations.getContext(), modAttr));
  }
  return retval;
}

/// Copy annotations from \p annotations into a new AnnotationSet and return it.
/// This removes annotations with "target" key that does not match the field
/// suffix.
static AnnotationSet filterAnnotations(AnnotationSet annotations,
                                       StringRef suffix) {
  if (annotations.empty())
    return annotations;
  SmallVector<Attribute> loweredAttrs =
      filterAnnotations(annotations.getArrayAttr(), suffix);
  return AnnotationSet(ArrayAttr::get(annotations.getContext(), loweredAttrs));
}

namespace {
class AggregateUserVisitor
    : public FIRRTLVisitor<AggregateUserVisitor, void, ArrayRef<Value>> {
public:
  AggregateUserVisitor(ImplicitLocOpBuilder *builder) : builder(builder) {}
  using FIRRTLVisitor<AggregateUserVisitor, void, ArrayRef<Value>>::visitDecl;
  using FIRRTLVisitor<AggregateUserVisitor, void, ArrayRef<Value>>::visitExpr;
  using FIRRTLVisitor<AggregateUserVisitor, void, ArrayRef<Value>>::visitStmt;

  void visitExpr(SubfieldOp op, ArrayRef<Value> mapping);
  void visitExpr(SubindexOp op, ArrayRef<Value> mapping);

private:
  /// The builder is set and maintained in the main loop.
  ImplicitLocOpBuilder *builder;
};
} // namespace

void AggregateUserVisitor::visitExpr(SubindexOp op, ArrayRef<Value> mapping) {
  Value repl = mapping[op.index()];
  op.replaceAllUsesWith(repl);
  op.erase();
}

void AggregateUserVisitor::visitExpr(SubfieldOp op, ArrayRef<Value> mapping) {
  // Get the input bundle type.
  Value input = op.input();
  auto bundleType = input.getType().cast<BundleType>();
  Value repl = mapping[*bundleType.getElementIndex(op.fieldname())];
  op.replaceAllUsesWith(repl);
  op.erase();
}

//===----------------------------------------------------------------------===//
// Module Type Lowering
//===----------------------------------------------------------------------===//
namespace {
struct TypeLoweringVisitor : public FIRRTLVisitor<TypeLoweringVisitor> {

  TypeLoweringVisitor(MLIRContext *context) : context(context) {}
  using FIRRTLVisitor<TypeLoweringVisitor>::visitDecl;
  using FIRRTLVisitor<TypeLoweringVisitor>::visitExpr;
  using FIRRTLVisitor<TypeLoweringVisitor>::visitStmt;

  /// If the referenced operation is a FModuleOp or an FExtModuleOp, perform
  /// type lowering on all operations.
  void lowerModule(Operation *op);

  bool lowerArg(
      Operation *module, size_t argIndex,
      SmallVectorImpl<std::pair<ModulePortInfo, SmallVector<NamedAttribute>>>
          &newArgs,
      SmallVectorImpl<Value>& lowering);
  std::pair<Value, firrtl::ModulePortInfo>
  addArg(Operation *module, unsigned insertPt, FIRRTLType type, bool isOutput,
         StringRef nameSuffix, ModulePortInfo &oldArg);

  // Helpers to manage state.
  void visitDecl(FExtModuleOp op);
  void visitDecl(FModuleOp op);
  void visitDecl(InstanceOp op);
  void visitDecl(MemOp op);
  void visitDecl(NodeOp op);
  void visitDecl(RegOp op);
  void visitDecl(WireOp op);
  void visitDecl(RegResetOp op);
  void visitExpr(InvalidValueOp op);
  void visitExpr(SubaccessOp op);
  void visitExpr(MuxPrimOp op);
  void visitExpr(AsPassivePrimOp op);
  void visitStmt(ConnectOp op);
  void visitStmt(PartialConnectOp op);
  void visitStmt(WhenOp op);

private:
  void processUsers(Value val, ArrayRef<Value> mapping);
  bool processSAPath(Operation *);
  void lowerBlock(Block *);
  void lowerSAWritePath(Operation *, ArrayRef<Operation *> writePath);
  void
  lowerProducer(Operation *op,
                llvm::function_ref<Operation *(FlatBundleFieldEntry, StringRef,
                                               SmallVector<Attribute> &)>
                    clone);
  Value getSubWhatever(Value val, size_t index);

  MLIRContext *context;

  /// The builder is set and maintained in the main loop.
  ImplicitLocOpBuilder *builder;

  /// State to keep track of arguments and operations to clean up at the end.
  SmallVector<Operation *, 16> opsToRemove;
};
} // namespace

Value TypeLoweringVisitor::getSubWhatever(Value val, size_t index) {
  if (BundleType bundle = val.getType().dyn_cast<BundleType>()) {
    return builder->create<SubfieldOp>(val, bundle.getElement(index).name);
  } else if (FVectorType fvector = val.getType().dyn_cast<FVectorType>()) {
    return builder->create<SubindexOp>(val, index);
  }
  llvm_unreachable("Unknown aggregate type");
  return nullptr;
}

/// Conditionally expand a subaccessop write path
bool TypeLoweringVisitor::processSAPath(Operation *op) {
  // Does this LHS have a subaccessop?
  SmallVector<Operation *> writePath = getSAWritePath(op);
  if (!writePath.empty()) {
    lowerSAWritePath(op, writePath);
    // Unhook the writePath from the connect.  This isn't the right type, but we
    // are deleting the op anyway.
    op->setOperand(0, writePath.back()->getResult(0));
    // See how far up the tree we can delete things.
    for (size_t i = 1; i < writePath.size() - 1; ++i) {
      if (writePath[i]->use_empty())
        writePath[i]->erase();
    }
    opsToRemove.push_back(op);
    return true;
  }
  return false;
}

void TypeLoweringVisitor::lowerBlock(Block *block) {
  // Lower the operations.
  for (auto& iop : llvm::reverse(*block)) {
    // We erase old ops eagerly so we don't have dangling uses we've already
    // lowered.
    for (auto *op : opsToRemove)
      op->erase();
    opsToRemove.clear();

    builder->setInsertionPoint(&iop);
    builder->setLoc(iop.getLoc());
    dispatchVisitor(&iop);
  }

  for (auto *op : opsToRemove)
    op->erase();
  opsToRemove.clear();
}

void TypeLoweringVisitor::lowerProducer(
    Operation *op,
    llvm::function_ref<Operation *(FlatBundleFieldEntry, StringRef,
                                   SmallVector<Attribute> &)>
        clone) {
  // If the wire is not a bundle, there is nothing to do.
      SmallVector<FlatBundleFieldEntry, 8> fieldTypes;
      if (!peelType(op->getResult(0).getType(), fieldTypes))
        return;

      SmallVector<Value> lowered;

      // Loop over the leaf aggregates.
      SmallString<16> loweredName;
      if (auto nameAttr = op->getAttr("name"))
        if (auto nameStrAttr = nameAttr.dyn_cast<StringAttr>())
          loweredName = nameStrAttr.getValue();
      auto baseNameLen = loweredName.size();
      for (auto field : fieldTypes) {
        if (!loweredName.empty()) {
          loweredName.resize(baseNameLen);
          loweredName += field.suffix;
        }
        // For all annotations on the parent op, filter them based on the target
        // attribute.
        auto oldAnno = op->getAttr("annotations");
        SmallVector<Attribute> loweredAttrs;
        if (auto anno = oldAnno.dyn_cast_or_null<ArrayAttr>())
          loweredAttrs = filterAnnotations(anno, field.suffix);
        auto newOp = clone(field, loweredName, loweredAttrs);
        lowered.push_back(newOp->getResult(0));
  }

  processUsers(op->getResult(0), lowered);
  opsToRemove.push_back(op);
}

void TypeLoweringVisitor::processUsers(Value val, ArrayRef<Value> mapping) {
  AggregateUserVisitor aggV(builder);
  for (auto user : llvm::make_early_inc_range(val.getUsers())) {
    aggV.dispatchVisitor(user, mapping);
  }
}

void TypeLoweringVisitor::lowerModule(Operation *op) {
  if (auto module = dyn_cast<FModuleOp>(op))
    return visitDecl(module);
  if (auto extModule = dyn_cast<FExtModuleOp>(op))
    return visitDecl(extModule);
}

// Creates and returns a new block argument of the specified type to the
// module. This also maintains the name attribute for the new argument,
// possibly with a new suffix appended.
std::pair<Value, firrtl::ModulePortInfo>
TypeLoweringVisitor::addArg(Operation *module, unsigned insertPt,
                            FIRRTLType type, bool isOutput,
                            StringRef nameSuffix, ModulePortInfo &oldArg) {
  Value newValue;
  if (auto mod = dyn_cast<FModuleOp>(module)) {
    Block *body = mod.getBodyBlock();
    // Append the new argument.
    newValue = body->insertArgument(insertPt, type);
  }

  // Save the name attribute for the new argument.
  auto nameStr = oldArg.name.getValue().str() + nameSuffix.str();
  auto name = builder->getStringAttr(nameStr);

  // Populate the new arg attributes.
  AnnotationSet newAnnotations =
      filterAnnotations(oldArg.annotations, nameSuffix);

  // Flip the direction if the field is an output.
  auto direction = (Direction)((unsigned)oldArg.direction ^ isOutput);

  return std::make_pair(newValue,
                        firrtl::ModulePortInfo{name, type, direction,
                                               oldArg.loc, newAnnotations});
}

// Lower arguments with bundle type by flattening them.
bool TypeLoweringVisitor::lowerArg(
    Operation *module, size_t argIndex,
    SmallVectorImpl<std::pair<ModulePortInfo, SmallVector<NamedAttribute>>>
        &newArgs,
    SmallVectorImpl<Value>& lowering) {

  // Flatten any bundle types.
  SmallVector<FlatBundleFieldEntry> fieldTypes;
  if (!peelType(newArgs[argIndex].first.type, fieldTypes))
    return false;

  for (auto field : llvm::enumerate(fieldTypes)) {
    auto newValue = addArg(module, 1 + argIndex + field.index(),
                           field.value().type, field.value().isOutput,
                           field.value().suffix, newArgs[argIndex].first);
    newArgs.insert(newArgs.begin() + 1 + argIndex + field.index(),
                   std::make_pair(newValue.second, newArgs[argIndex].second));
    // Lower any other arguments by copying them to keep the relative order.
    lowering.push_back(newValue.first);
  }
  return true;
}

static Value cloneAccess(ImplicitLocOpBuilder *builder, Operation *op,
                         Value rhs) {
  if (auto rop = dyn_cast<SubfieldOp>(op))
    return builder->create<SubfieldOp>(rhs, rop.fieldname());
  if (auto rop = dyn_cast<SubindexOp>(op))
    return builder->create<SubindexOp>(rhs, rop.index());
  if (auto rop = dyn_cast<SubaccessOp>(op))
    return builder->create<SubaccessOp>(rhs, rop.index());
  op->emitError("Unknown accessor");
  return nullptr;
}

void TypeLoweringVisitor::lowerSAWritePath(Operation *op,
                                           ArrayRef<Operation *> writePath) {
  SubaccessOp sao = cast<SubaccessOp>(writePath.back());
  auto saoType = sao.input().getType().cast<FVectorType>();
  auto selectWidth =
      sao.index().getType().cast<FIRRTLType>().getBitWidthOrSentinel();

  for (size_t index = 0, e = saoType.getNumElements(); index < e; ++index) {
    auto cond = builder->create<EQPrimOp>(
        sao.index(),
        builder->createOrFold<ConstantOp>(UIntType::get(context, selectWidth),
                                          APInt(selectWidth, index)));
    builder->create<WhenOp>(cond, false, [&]() {
      // Recreate the write Path
      Value leaf = builder->create<SubindexOp>(sao.input(), index);
      for (int i = writePath.size() - 2; i >= 0; --i)
        leaf = cloneAccess(builder, writePath[i], leaf);

      if (isa<ConnectOp>(op))
        builder->create<ConnectOp>(leaf, writePath[0]->getResult(0));
      else
        builder->create<PartialConnectOp>(leaf, writePath[0]->getResult(0));
    });
  }
}

// Expand connects of aggregates
void TypeLoweringVisitor::visitStmt(ConnectOp op) {
  if (processSAPath(op))
    return;

  // Attempt to get the bundle types.
  SmallVector<FlatBundleFieldEntry> fields;
  if (!peelType(op.dest().getType(), fields))
    return;

  // Loop over the leaf aggregates.
  for (auto field : llvm::enumerate(fields)) {
    Value src = getSubWhatever(op.src(), field.index());
    Value dest = getSubWhatever(op.dest(), field.index());
    if (field.value().isOutput)
      std::swap(src, dest);
    builder->create<ConnectOp>(dest, src);
  }
  opsToRemove.push_back(op);
}

void TypeLoweringVisitor::visitStmt(PartialConnectOp op) {
  if (processSAPath(op))
    return;

  SmallVector<FlatBundleFieldEntry> srcFields, destFields;
  bool sValid = peelType(op.src().getType(), srcFields);
  bool dValid = peelType(op.dest().getType(), destFields);

  // Ground Type
  if (!dValid) {
    // check for truncation
    Value src = op.src();
    Value dest = op.dest();
    auto srcType = src.getType().cast<FIRRTLType>();
    auto destType = dest.getType().cast<FIRRTLType>();
    auto srcWidth = srcType.getBitWidthOrSentinel();
    auto destWidth = destType.getBitWidthOrSentinel();

    if (destType == srcType) {
      builder->create<ConnectOp>(dest, src);
      opsToRemove.push_back(op);
    } else if (destType.isa<IntType>() && srcType.isa<IntType>() &&
               destWidth >= 0 && destWidth < srcWidth) {
      // firrtl.tail always returns uint even for sint operands.
      IntType tmpType = destType.cast<IntType>();
      if (tmpType.isSigned())
        tmpType = UIntType::get(destType.getContext(), destWidth);
      src = builder->create<TailPrimOp>(tmpType, src, srcWidth - destWidth);
      // Insert the cast back to signed if needed.
      if (tmpType != destType)
        src = builder->create<AsSIntPrimOp>(destType, src);
      builder->create<ConnectOp>(dest, src);
      opsToRemove.push_back(op);
    }
    return;
  }

  // Aggregates
  if (FVectorType fvector = op.src().getType().dyn_cast<FVectorType>()) {
    for (int index = 0, e = std::min(srcFields.size(), destFields.size());
         index != e; ++index) {
      Value src = builder->create<SubindexOp>(op.src(), index);
      Value dest = builder->create<SubindexOp>(op.dest(), index);
      if (src.getType() == dest.getType())
        builder->create<ConnectOp>(dest, src);
      else
        builder->create<PartialConnectOp>(dest, src);
    }
  } else if (BundleType srcBundle = op.src().getType().dyn_cast<BundleType>()) {
    // Pairwise connect on matching field names
    BundleType destBundle = op.dest().getType().cast<BundleType>();
    for (int srcIndex = 0, srcEnd = srcBundle.getNumElements();
         srcIndex < srcEnd; ++srcIndex) {
      auto srcName = srcBundle.getElement(srcIndex).name;
      for (int destIndex = 0, destEnd = destBundle.getNumElements();
           destIndex < destEnd; ++destIndex) {
        auto destName = destBundle.getElement(destIndex).name;
        if (srcName == destName) {
          Value src = builder->create<SubfieldOp>(op.src(), srcName);
          Value dest = builder->create<SubfieldOp>(op.dest(), destName);
          if (destFields[destIndex].isOutput)
            std::swap(src, dest);
          if (src.getType().isa<AnalogType>())
            builder->create<AttachOp>(ArrayRef<Value>{dest, src});
          else if (src.getType() == dest.getType())
            builder->create<ConnectOp>(dest, src);
          else
            builder->create<PartialConnectOp>(dest, src);
          break;
        }
      }
    }
  } else {
    op.emitError("Unknown aggregate type");
  }

  opsToRemove.push_back(op);
}

void TypeLoweringVisitor::visitStmt(WhenOp op) {
  // The WhenOp itself does not require any lowering, the only value it uses
  // is a one-bit predicate.  Recursively visit all regions so internal
  // operations are lowered.

  // Visit operations in the then block.
  lowerBlock(&op.getThenBlock());

  // If there is no else block, return.
  if (!op.hasElseRegion())
    return;

  // Visit operations in the else block.
  lowerBlock(&op.getElseBlock());
}

/// Lower memory operations. A new memory is created for every leaf
/// element in a memory's data type.
void TypeLoweringVisitor::visitDecl(MemOp op) {
  // Attempt to get the bundle types.
  SmallVector<FlatBundleFieldEntry> fields;
  if (!peelType(op.getDataType(), fields))
    return;

  SmallVector<MemOp> newMemories;
  SmallVector<Value> wireToOldResult;
  SmallVector<WireOp> oldPorts;

  // Wires for old ports
  for (unsigned int index = 0, end = op.getNumResults(); index < end; ++index) {
    auto result = op.getResult(index);
    auto wire = builder->create<WireOp>(
        result.getType(),
        (op.name() + "_" + op.getPortName(index).getValue()).str());
    oldPorts.push_back(wire);
    result.replaceAllUsesWith(wire.getResult());
  }

  // Memory for each field
  for (auto field : fields)
    newMemories.push_back(
        cloneMemWithNewType(builder, op, field.type, field.suffix));

  // Hook up the new memories to the wires the old memory was replaced with.
  for (size_t index = 0, rend = op.getNumResults(); index < rend; ++index) {
    auto result = oldPorts[index];
    auto rType = result.getType().cast<BundleType>();
    for (size_t fieldIndex = 0, fend = rType.getNumElements();
         fieldIndex != fend; ++fieldIndex) {
      auto name = rType.getElement(fieldIndex).name.getValue();
      auto oldField = builder->create<SubfieldOp>(result, name);
      // data and mask depend on the memory type which was split.  They can also
      // go both directions, depending on the port direction.
      if (name == "data" || name == "mask") {
        for (auto field : fields) {
          auto realOldField = getSubWhatever(oldField, field.index);
          auto newField = getSubWhatever(
              newMemories[field.index].getResult(index), fieldIndex);
          if (rType.getElement(fieldIndex).isFlip)
            std::swap(realOldField, newField);
          builder->create<ConnectOp>(newField, realOldField);
        }
      } else {
        for (auto mem : newMemories) {
          auto newField =
              builder->create<SubfieldOp>(mem.getResult(index), name);
          builder->create<ConnectOp>(newField, oldField);
        }
      }
    }
  }
  opsToRemove.push_back(op);
}

void TypeLoweringVisitor::visitDecl(FExtModuleOp extModule) {
  ImplicitLocOpBuilder theBuilder(extModule.getLoc(), context);
  builder = &theBuilder;

  // Top level builder
  OpBuilder builder(context);

  // Lower the module block arguments.
  SmallVector<unsigned> argsToRemove;
  // First get all the info for existing ports
  SmallVector<std::pair<ModulePortInfo, SmallVector<NamedAttribute>>> newArgs;
  for (auto port : llvm::enumerate(extModule.getPorts())) {
    SmallVector<NamedAttribute> argAttrs;
    AnnotationSet::forPort(extModule, port.index(), argAttrs);
    newArgs.push_back(std::make_pair(port.value(), argAttrs));
  }

  for (size_t argIndex = 0; argIndex < newArgs.size(); ++argIndex) {
    SmallVector<Value> lowering;
    if (lowerArg(extModule, argIndex, newArgs, lowering))
      argsToRemove.push_back(argIndex);
    // lowerArg might have invalidated any reference to newArgs, be careful
  }

  // Remove block args that have been lowered
  for (auto ii = argsToRemove.rbegin(), ee = argsToRemove.rend(); ii != ee;
       ++ii)
    newArgs.erase(newArgs.begin() + *ii);

  SmallVector<NamedAttribute, 8> newModuleAttrs;

  // Copy over any attributes that weren't original argument attributes.
  for (auto attr : extModule->getAttrDictionary())
    // Drop old "portNames", directions, and argument attributes.  These are
    // handled differently below.
    if (attr.first != "portNames" && attr.first != direction::attrKey &&
        attr.first != mlir::function_like_impl::getArgDictAttrName())
      newModuleAttrs.push_back(attr);

  SmallVector<Attribute> newArgNames;
  SmallVector<Direction> newArgDirections;
  SmallVector<Attribute, 8> newArgAttrs;
  SmallVector<Type, 8> inputTypes;

  for (auto &port : newArgs) {
    newArgNames.push_back(port.first.name);
    newArgDirections.push_back(port.first.direction);
    newArgAttrs.push_back(
        port.first.annotations.getArgumentAttrDict(port.second));
    inputTypes.push_back(port.first.type);
  }
  newModuleAttrs.push_back(NamedAttribute(Identifier::get("portNames", context),
                                          builder.getArrayAttr(newArgNames)));
  newModuleAttrs.push_back(
      NamedAttribute(Identifier::get(direction::attrKey, context),
                     direction::packAttribute(newArgDirections, context)));

  // Attach new argument attributes.
  newModuleAttrs.push_back(NamedAttribute(
      builder.getIdentifier(mlir::function_like_impl::getArgDictAttrName()),
      builder.getArrayAttr(newArgAttrs)));

  // Update the module's attributes.
  extModule->setAttrs(newModuleAttrs);

  // Keep the module's type up-to-date.
  extModule.setType(builder.getFunctionType(inputTypes, {}));
}

void TypeLoweringVisitor::visitDecl(FModuleOp module) {
  auto *body = module.getBodyBlock();

  ImplicitLocOpBuilder theBuilder(module.getLoc(), context);
  builder = &theBuilder;

  // Lower the operations.
  lowerBlock(body);

  // Lower the module block arguments.
  SmallVector<unsigned> argsToRemove;
  // First get all the info for existing ports
  SmallVector<std::pair<ModulePortInfo, SmallVector<NamedAttribute>>> newArgs;
  for (auto port : llvm::enumerate(module.getPorts())) {
    SmallVector<NamedAttribute> argAttrs;
    AnnotationSet::forPort(module, port.index(), argAttrs);
    newArgs.push_back(std::make_pair(port.value(), argAttrs));
  }

  for (size_t argIndex = 0; argIndex < newArgs.size(); ++argIndex) {
    SmallVector<Value> lowerings; 
    if (lowerArg(module, argIndex, newArgs, lowerings)) {
      auto arg = module.getPortArgument(argIndex);
      processUsers(arg, lowerings);
      argsToRemove.push_back(argIndex);
    }
    // lowerArg might have invalidated any reference to newArgs, be careful
  }

  // Remove block args that have been lowered.
  body->eraseArguments(argsToRemove);
  for (auto deadArg : llvm::reverse(argsToRemove))
    newArgs.erase(newArgs.begin() + deadArg);

  SmallVector<NamedAttribute, 8> newModuleAttrs;

  // Copy over any attributes that weren't original argument attributes.
  for (auto attr : module->getAttrDictionary())
    // Drop old "portNames", directions, and argument attributes.  These are
    // handled differently below.
    if (attr.first != "portNames" && attr.first != direction::attrKey &&
        attr.first != mlir::function_like_impl::getArgDictAttrName())
      newModuleAttrs.push_back(attr);

  SmallVector<Attribute> newArgNames;
  SmallVector<Direction> newArgDirections;
  SmallVector<Attribute, 8> newArgAttrs;
  for (auto &port : newArgs) {
    newArgNames.push_back(port.first.name);
    newArgDirections.push_back(port.first.direction);
    newArgAttrs.push_back(
        port.first.annotations.getArgumentAttrDict(port.second));
  }
  newModuleAttrs.push_back(NamedAttribute(Identifier::get("portNames", context),
                                          builder->getArrayAttr(newArgNames)));
  newModuleAttrs.push_back(
      NamedAttribute(Identifier::get(direction::attrKey, context),
                     direction::packAttribute(newArgDirections, context)));

  // Attach new argument attributes.
  newModuleAttrs.push_back(NamedAttribute(
      builder->getIdentifier(mlir::function_like_impl::getArgDictAttrName()),
      builder->getArrayAttr(newArgAttrs)));

  // Update the module's attributes.
  module->setAttrs(newModuleAttrs);

  // Keep the module's type up-to-date.
  auto moduleType = builder->getFunctionType(body->getArgumentTypes(), {});
  module->setAttr(module.getTypeAttrName(), TypeAttr::get(moduleType));
}

/// Lower a wire op with a bundle to multiple non-bundled wires.
void TypeLoweringVisitor::visitDecl(WireOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    return builder->create<WireOp>(field.type, name, attrs);
  };
  lowerProducer(op, clone);
}

/// Lower a reg op with a bundle to multiple non-bundled regs.
void TypeLoweringVisitor::visitDecl(RegOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    return builder->create<RegOp>(field.type, op.clockVal(), name, attrs);
  };
  lowerProducer(op, clone);
}

/// Lower a reg op with a bundle to multiple non-bundled regs.
void TypeLoweringVisitor::visitDecl(RegResetOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    auto resetVal = getSubWhatever(op.resetValue(), field.index);
    return builder->create<RegResetOp>(field.type, op.clockVal(),
                                       op.resetSignal(), resetVal, name, attrs);
  };
  lowerProducer(op, clone);
}

/// Lower a wire op with a bundle to multiple non-bundled wires.
void TypeLoweringVisitor::visitDecl(NodeOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    auto input = getSubWhatever(op.input(), field.index);
    return builder->create<NodeOp>(field.type, input, name, attrs);
  };
  lowerProducer(op, clone);
}

/// Lower an InvalidValue op with a bundle to multiple non-bundled InvalidOps.
void TypeLoweringVisitor::visitExpr(InvalidValueOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    return builder->create<InvalidValueOp>(field.type);
  };
  lowerProducer(op, clone);
}

// Expand muxes of aggregates
void TypeLoweringVisitor::visitExpr(MuxPrimOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    auto high = getSubWhatever(op.high(), field.index);
    auto low = getSubWhatever(op.low(), field.index);
    return builder->create<MuxPrimOp>(op.sel(), high, low);
  };
  lowerProducer(op, clone);
}

// Expand AsPassivePrimOp of aggregates
void TypeLoweringVisitor::visitExpr(AsPassivePrimOp op) {
  auto clone = [&](FlatBundleFieldEntry field, StringRef name,
                   SmallVector<Attribute> &attrs) -> Operation * {
    auto input = getSubWhatever(op.input(), field.index);
    return builder->create<AsPassivePrimOp>(field.type, input);
  };
  lowerProducer(op, clone);
}

void TypeLoweringVisitor::visitDecl(InstanceOp op) {
  SmallVector<Type, 8> resultTypes;
  SmallVector<int64_t, 8> endFields; // Compressed sparse row encoding
  SmallVector<StringAttr, 8> resultNames;
  bool skip = true;

  endFields.push_back(0);
  for (size_t i = 0, e = op.getNumResults(); i != e; ++i) {
    auto srcType = op.getType(i).cast<FIRRTLType>();

    // Flatten any nested bundle types the usual way.
    SmallVector<FlatBundleFieldEntry, 8> fieldTypes;
    if (!peelType(srcType, fieldTypes))
      resultTypes.push_back(srcType);
    else {
      skip = false;
      // Store the flat type for the new bundle type.
      for (auto field : fieldTypes)
        resultTypes.push_back(field.type);
    }
    endFields.push_back(resultTypes.size());
  }

  if (skip)
    return;

  // FIXME: annotation update
  auto newInstance = builder->create<InstanceOp>(
      resultTypes, op.moduleNameAttr(), op.nameAttr(), op.annotations());

  SmallVector<Value> lowered;
  for (size_t aggIndex = 0, eAgg = op.getNumResults(); aggIndex != eAgg;
       ++aggIndex) {
    lowered.clear();
    for (size_t fieldIndex = endFields[aggIndex],
                eField = endFields[aggIndex + 1];
         fieldIndex < eField; ++fieldIndex)
      lowered.push_back(newInstance.getResult(fieldIndex));
    if (lowered.size() != 1 || op.getType(aggIndex) != resultTypes[endFields[aggIndex]])
      processUsers(op.getResult(aggIndex), lowered);
    else
      op.getResult(aggIndex).replaceAllUsesWith(lowered[0]);
  }
  opsToRemove.push_back(op);
}

void TypeLoweringVisitor::visitExpr(SubaccessOp op) {
  // Reads.  All writes have been eliminated before now

  auto input = op.input();
  auto vType = input.getType().cast<FVectorType>();
  auto selectWidth =
      op.index().getType().cast<FIRRTLType>().getBitWidthOrSentinel();

  Value mux = builder->create<InvalidValueOp>(vType.getElementType());
  // Build up the mux
  for (size_t index = 0, e = vType.getNumElements(); index < e; ++index) {
    auto cond = builder->create<EQPrimOp>(
        op.index(), builder->createOrFold<ConstantOp>(
                        UIntType::get(op.getContext(), selectWidth),
                        APInt(selectWidth, index)));
    auto access = builder->create<SubindexOp>(input, index);
    mux = builder->create<MuxPrimOp>(cond, access, mux);
  }
  op.replaceAllUsesWith(mux);
  opsToRemove.push_back(op);
}

//===----------------------------------------------------------------------===//
// Pass Infrastructure
//===----------------------------------------------------------------------===//

namespace {
struct LowerBundleVectorPass
    : public LowerBundleVectorBase<LowerBundleVectorPass> {
  void runOnOperation() override;

private:
  void runParallel();
};
} // end anonymous namespace

void LowerBundleVectorPass::runParallel() {
  // Collect the operations to iterate in a vector. We can't use parallelFor
  // with the regular op list, since it requires a RandomAccessIterator. This
  // also lets us use parallelForEachN, which means we don't have to
  // llvm::enumerate the ops with their index. TODO(mlir): There should really
  // be a way to do this without collecting the operations first.
  std::deque<Operation *> ops;
  llvm::for_each(getOperation().getBody()->getOperations(),
                 [&](Operation &op) { ops.push_back(&op); });

  mlir::ParallelDiagnosticHandler diagHandler(&getContext());
  llvm::parallelForEachN(0, ops.size(), [&](auto index) {
    // Notify the handler the op index and then perform lowering.
    diagHandler.setOrderIDForThread(index);
    TypeLoweringVisitor(&getContext()).lowerModule(ops[index]);
    diagHandler.eraseOrderIDForThread();
  });
}

// This is the main entrypoint for the lowering pass.
void LowerBundleVectorPass::runOnOperation() {
  auto *context = &getContext();
  if (context->isMultithreadingEnabled())
    runParallel();
  else
    for (auto &op : getOperation().getBody()->getOperations())
      TypeLoweringVisitor(context).lowerModule(&op);
}

/// This is the pass constructor.
std::unique_ptr<mlir::Pass> circt::firrtl::createLowerBundleVectorTypesPass() {
  return std::make_unique<LowerBundleVectorPass>();
}