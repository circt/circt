//===- integration_test/driver.cpp - Verilator software driver ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// A fairly standard, boilerplate Verilator C++ simulation driver. Assumes the
// top level exposes just two signals: 'clk' and 'rstn'.
//
//===----------------------------------------------------------------------===//

#include "Vmain.h"

#ifdef DEBUG
#include "verilated_vcd_c.h"
#endif

#include "signal.h"
#include <iostream>

vluint64_t timeStamp;

// Stop the simulation gracefully on ctrl-c.
volatile bool stopSimulation = false;
void handle_sigint(int) { stopSimulation = true; }

// Called by $time in Verilog.
double sc_time_stamp() { return timeStamp; }

int main(int argc, char **argv) {
  // Register graceful exit handler.
  signal(SIGINT, handle_sigint);

  Verilated::commandArgs(argc, argv);

  size_t numCyclesToRun = 0;
  // Search the command line args for those we are sensitive to.
  for (int i = 1; i < argc; ++i) {
    if (std::string(argv[i]) == "--cycles") {
      if (i + 1 < argc) {
        numCyclesToRun = std::strtoull(argv[++i], nullptr, 10);
      } else {
        std::cerr << "--cycles must be followed by number of cycles."
                  << std::endl;
        return 1;
      }
    }
  }

  // Construct the simulated module's C++ model.
  auto &dut = *new Vmain();
#ifdef DEBUG
  VerilatedVcdC *tfp = new VerilatedVcdC;
  Verilated::traceEverOn(true);
  dut.trace(tfp, 99); // Trace 99 levels of hierarchy
  tfp->open("main.vcd");
#endif

  std::cout << "[driver] Starting simulation" << std::endl;

  // Reset.
  dut.rstn = 0;
  dut.clk = 0;

  // Run for a few cycles with reset held.
  for (timeStamp = 0; timeStamp < 10 && !Verilated::gotFinish(); timeStamp++) {
    dut.eval();
    dut.clk = !dut.clk;
#ifdef DEBUG
    tfp->dump(timeStamp);
#endif
  }

  // Take simulation out of reset.
  dut.rstn = 1;

  // Run for the specified number of cycles out of reset.
  for (; timeStamp <= (numCyclesToRun * 2) && !Verilated::gotFinish() &&
         !stopSimulation;
       timeStamp++) {
    dut.eval();
    dut.clk = !dut.clk;
#ifdef DEBUG
    tfp->dump(timeStamp);
#endif
  }

  // Tell the simulator that we're going to exit. This flushes the output(s) and
  // frees whatever memory may have been allocated.
  dut.final();
#ifdef DEBUG
  tfp->close();
#endif

  std::cout << "[driver] Ending simulation at tick #" << timeStamp << std::endl;
  return 0;
}
