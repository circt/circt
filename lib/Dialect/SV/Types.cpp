//===- SVTypes.cpp - Implement the SV types -------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implement the SV dialect type system.
//
//===----------------------------------------------------------------------===//

#include "circt/Dialect/SV/SVDialect.h"
#include "circt/Dialect/SV/SVTypes.h"

#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace circt::sv;
using namespace mlir;

//===----------------------------------------------------------------------===//
// SV Interface type logic.
//===----------------------------------------------------------------------===//

Type InterfaceType::parse(MLIRContext *ctxt, DialectAsmParser &p) {
  FlatSymbolRefAttr iface;
  if (p.parseLess() || p.parseAttribute(iface) || p.parseGreater())
    return Type();
  return get(ctxt, iface);
}

void InterfaceType::print(DialectAsmPrinter &p) const {
  p << "interface<" << getInterface() << ">";
}

Type ModportType::parse(MLIRContext *ctxt, DialectAsmParser &p) {
  SymbolRefAttr modPort;
  if (p.parseLess() || p.parseAttribute(modPort) || p.parseGreater())
    return Type();
  return get(ctxt, modPort);
}

void ModportType::print(DialectAsmPrinter &p) const {
  p << "modport<" << getModport() << ">";
}

//===----------------------------------------------------------------------===//
// TableGen generated logic.
//===----------------------------------------------------------------------===//

// Provide the autogenerated implementation guts for the Op classes.
#define GET_TYPEDEF_CLASSES
#include "circt/Dialect/SV/SVTypes.cpp.inc"

/// Parses a type registered to this dialect
Type SVDialect::parseType(DialectAsmParser &parser) const {
  llvm::StringRef mnemonic;
  auto loc = parser.getCurrentLocation();
  if (parser.parseKeyword(&mnemonic))
    return Type();
  if (auto type = generatedTypeParser(getContext(), parser, mnemonic))
    return type;
  parser.emitError(loc, "Failed to parse type sv.") << mnemonic << "\n";
  return Type();
}

/// Print a type registered to this dialect
void SVDialect::printType(Type type, DialectAsmPrinter &printer) const {
  if (succeeded(generatedTypePrinter(type, printer)))
    return;
  llvm_unreachable("unexpected 'rtl' type kind");
}
