//===- CombOps.cpp - Implement the Comb operations ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements combinational ops.
//
//===----------------------------------------------------------------------===//

#include "circt/Dialect/Comb/CombOps.h"
#include "circt/Dialect/RTL/RTLTypes.h"
#include "mlir/IR/Builders.h"

using namespace mlir;
using namespace circt;
using namespace comb;

/// Return true if the specified type is a signless non-zero width integer type,
/// the only type which the comb ops operate.
static bool isCombIntegerType(mlir::Type type) {
  auto intType = type.dyn_cast<IntegerType>();
  if (!intType || !intType.isSignless())
    return false;

  return intType.getWidth() != 0;
}

//===----------------------------------------------------------------------===//
// ICmpOp
//===----------------------------------------------------------------------===//

ICmpPredicate ICmpOp::getFlippedPredicate(ICmpPredicate predicate) {
  switch (predicate) {
  case ICmpPredicate::eq:
    return ICmpPredicate::eq;
  case ICmpPredicate::ne:
    return ICmpPredicate::ne;
  case ICmpPredicate::slt:
    return ICmpPredicate::sgt;
  case ICmpPredicate::sle:
    return ICmpPredicate::sge;
  case ICmpPredicate::sgt:
    return ICmpPredicate::slt;
  case ICmpPredicate::sge:
    return ICmpPredicate::sle;
  case ICmpPredicate::ult:
    return ICmpPredicate::ugt;
  case ICmpPredicate::ule:
    return ICmpPredicate::uge;
  case ICmpPredicate::ugt:
    return ICmpPredicate::ult;
  case ICmpPredicate::uge:
    return ICmpPredicate::ule;
  }
  llvm_unreachable("unknown comparison predicate");
}



//===----------------------------------------------------------------------===//
// Unary Operations
//===----------------------------------------------------------------------===//

static LogicalResult verifySExtOp(SExtOp op) {
  // The source must be equal or smaller than the dest type.  Both are already known to
  // be signless integers.
  auto srcType = op.getOperand().getType().cast<IntegerType>();
  if (srcType.getWidth() > op.getType().getWidth()) {
    op.emitOpError("extension must increase bitwidth of operand");
    return failure();
  }

  return success();
}

//===----------------------------------------------------------------------===//
// Other Operations
//===----------------------------------------------------------------------===//

static LogicalResult verifyExtractOp(ExtractOp op) {
  unsigned srcWidth = op.input().getType().cast<IntegerType>().getWidth();
  unsigned dstWidth = op.getType().getWidth();
  if (op.lowBit() >= srcWidth || srcWidth - op.lowBit() < dstWidth)
    return op.emitOpError("from bit too large for input"), failure();

  return success();
}

//===----------------------------------------------------------------------===//
// Variadic operations
//===----------------------------------------------------------------------===//

static LogicalResult verifyUTVariadicOp(Operation *op) {
  if (op->getOperands().empty())
    return op->emitOpError("requires 1 or more args");

  return success();
}

//===----------------------------------------------------------------------===//
// ConcatOp
//===----------------------------------------------------------------------===//

void ConcatOp::build(OpBuilder &builder, OperationState &result,
                     ValueRange inputs) {
  unsigned resultWidth = 0;
  for (auto input : inputs) {
    resultWidth += input.getType().cast<IntegerType>().getWidth();
  }
  build(builder, result, builder.getIntegerType(resultWidth), inputs);
}

//===----------------------------------------------------------------------===//
// TableGen generated logic.
//===----------------------------------------------------------------------===//

// Provide the autogenerated implementation guts for the Op classes.
#define GET_OP_CLASSES
#include "circt/Dialect/Comb/Comb.cpp.inc"
