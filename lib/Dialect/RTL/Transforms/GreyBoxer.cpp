//===- RTLCleanup.cpp - RTL Cleanup Pass ----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This transformation pass performs various cleanups and canonicalization
// transformations for rtl.module bodies.
//
//===----------------------------------------------------------------------===//

#include "RTLPassDetail.h"
#include "circt/Dialect/RTL/RTLOps.h"
#include "circt/Dialect/SV/SVOps.h"
#include "circt/Dialect/RTL/RTLPasses.h"
#include "circt/Support/ImplicitLocOpBuilder.h"

using namespace circt;

//===----------------------------------------------------------------------===//
// GreyBoxer Pass
//===----------------------------------------------------------------------===//

namespace {
struct RTLGreyBoxerPass : public rtl::RTLGreyBoxerBase<RTLGreyBoxerPass> {
  void runOnOperation() override;
};
} // end anonymous namespace


void RTLGreyBoxerPass::runOnOperation() {
  auto topModule = getOperation().getBody();
  SmallVector<rtl::RTLModuleExternOp, 8> toErase;

  for (auto &op : *topModule)
    if (auto module = dyn_cast<rtl::RTLModuleExternOp>(op)) {
      module.dump();
      OpBuilder builder(topModule->getTerminator());
      SmallVector<rtl::ModulePortInfo, 8> ports;
      module.getPortInfo(ports);
      auto nameAttr = builder.getStringAttr(module.getName());
      auto newModule = builder.create<rtl::RTLModuleOp>(module.getLoc(), nameAttr, ports);
      auto outputOp = newModule.getBodyBlock()->getTerminator();
      OpBuilder innerBuilder(outputOp);
      SmallVector<Value, 8> outputs;
      for (auto & p : ports) {
        if (p.isOutput())
          outputs.push_back(innerBuilder.create<sv::ConstantXOp>(outputOp->getLoc(), p.type));
      }
      outputOp->setOperands(outputs);
      toErase.push_back(module);
    }
  // If we did not change anything in the graph mark all analysis as
  // preserved.
  if (toErase.empty())
    markAllAnalysesPreserved();
  for (auto&m : toErase)
    m->erase();

}

std::unique_ptr<Pass> circt::rtl::createRTLGreyBoxerPass() {
  return std::make_unique<RTLGreyBoxerPass>();
}