//===- Ops.h - StaticLogic MLIR Operations ----------------------*- C++ -*-===//
//
// Copyright 2020 The CIRCT Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================
//
//
//===----------------------------------------------------------------------===//

#include "circt/Conversion/StandardToHandshake/StandardToHandshake.h"
#include "circt/Conversion/StandardToStaticLogic/StandardToStaticLogic.h"
#include "circt/Dialect/StaticLogic/StaticLogic.h"
#include "circt/Dialect/Handshake/HandshakeOps.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Function.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Types.h"
#include "mlir/IR/Value.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/Passes.h"
#include "mlir/Transforms/Utils.h"

using namespace mlir;
using namespace circt;
using namespace circt::handshake;
using namespace circt::staticlogic;