#ifndef CIRCT_DIALECT_LLHD_SIMULATOR_ENGINE_H
#define CIRCT_DIALECT_LLHD_SIMULATOR_ENGINE_H

#include "circt/Dialect/LLHD/IR/LLHDOps.h"

#include "mlir/ExecutionEngine/ExecutionEngine.h"
#include "mlir/IR/Module.h"

namespace mlir {
namespace llhd {
namespace sim {

struct State;
struct Instance;

class Engine {
public:
  /// Initialize an LLHD simulation engine. This initializes the state, as well
  /// as the mlir::ExecutionEngine with the given module.
  Engine(llvm::raw_ostream &out, OwningModuleRef &module, MLIRContext &context,
         std::string root);

  /// Default destructor
  ~Engine();

  /// Run simulation up to n steps. Pass n=0 to run indefinitely.
  int simulate(int n);

  /// Build the instance layout of the design.
  void buildLayout(ModuleOp module);

  /// Get a reference to the module
  ModuleOp *getModuleRef() { return &module; }

  /// Get the simulation state.
  State *getState() { return state.get(); }

  /// Dump the instance layout stored in the State.
  void dumpStateLayout();

  /// Dump the instances each signal triggers.
  void dumpStateSignalTriggers();

private:
  void walkEntity(EntityOp entity, Instance &child);

  llvm::raw_ostream &out;
  std::string root;
  std::unique_ptr<State> state;
  std::unique_ptr<ExecutionEngine> engine;
  ModuleOp module;
};

} // namespace sim
} // namespace llhd
} // namespace mlir

#endif // CIRCT_DIALECT_LLHD_SIMULATOR_ENGINE_H
