// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: circt-opt %s -llhd-early-code-motion | FileCheck %s

// CHECK-LABEL:   llhd.proc @check_dont_move_sideeffect() -> (
// CHECK-SAME:                                                %[[VAL_0:.*]] : !llhd.sig<i32>) {
// CHECK:           %[[VAL_1:.*]] = llhd.const 4 : i32
// CHECK:           %[[VAL_2:.*]] = llhd.const #llhd.time<1ns, 0d, 0e> : !llhd.time
// CHECK:           br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_3:.*]] = llhd.var %[[VAL_1]] : i32
// CHECK:           llhd.drv %[[VAL_0]], %[[VAL_1]] after %[[VAL_2]] : !llhd.sig<i32>
// CHECK:           br ^bb2
// CHECK:         ^bb2:
// CHECK:           %[[VAL_4:.*]] = llhd.load %[[VAL_3]] : !llhd.ptr<i32>
// CHECK:           llhd.store %[[VAL_3]], %[[VAL_1]] : !llhd.ptr<i32>
// CHECK:           llhd.halt
// CHECK:         }
llhd.proc @check_dont_move_sideeffect() -> (%sig : !llhd.sig<i32>) {
  // TR: -1
  %c = llhd.const 4 : i32
  %time = llhd.const #llhd.time<1ns, 0d, 0e> : !llhd.time
  br ^bb1
^bb1:
  // TR: -1
  %ptr = llhd.var %c : i32
  llhd.drv %sig, %c after %time : !llhd.sig<i32>
  br ^bb2
^bb2:
  // TR: -1
  %ld = llhd.load %ptr : !llhd.ptr<i32>
  llhd.store %ptr, %c : !llhd.ptr<i32>
  llhd.halt
}

// Checks that prb is moved to predecessor block if it is in the same TR, but
// not if one predecessor has a wait terminator, but side-effect-free operations
// are moved freely
// CHECK-LABEL:   llhd.proc @check_move_prb1(
// CHECK-SAME:                               %[[VAL_0:.*]] : !llhd.sig<i32>) -> () {
// CHECK:           %[[VAL_1:.*]] = llhd.const 4 : i32
// CHECK:           %[[VAL_2:.*]] = addi %[[VAL_1]], %[[VAL_1]] : i32
// CHECK:           br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_3:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i32>
// CHECK:           %[[VAL_4:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i32>
// CHECK:           br ^bb2
// CHECK:         ^bb2:
// CHECK:           llhd.wait ^bb1
// CHECK:         }
llhd.proc @check_move_prb1(%sig : !llhd.sig<i32>) -> () {
  // TR: -1
  br ^bb1
^bb1:
  // TR: 0
  %c = llhd.const 4 : i32
  %prb1 = llhd.prb %sig : !llhd.sig<i32>
  br ^bb2
^bb2:
  // TR: 0
  %double = addi %c, %c : i32
  %prb2 = llhd.prb %sig : !llhd.sig<i32>
  llhd.wait ^bb1
}

// Checks that prb is not moved to predecessor if not all predecessors are in
// the same TR, but side-effect-free operations are moved freely
// CHECK-LABEL:   llhd.proc @check_move_prb2(
// CHECK-SAME:                               %[[VAL_0:.*]] : !llhd.sig<i32>) -> () {
// CHECK:           %[[VAL_1:.*]] = llhd.const 4 : i32
// CHECK:           %[[VAL_2:.*]] = addi %[[VAL_1]], %[[VAL_1]] : i32
// CHECK:           br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_3:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i32>
// CHECK:           llhd.wait ^bb2
// CHECK:         ^bb2:
// CHECK:           %[[VAL_4:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i32>
// CHECK:           br ^bb1
// CHECK:         }
llhd.proc @check_move_prb2(%sig : !llhd.sig<i32>) -> () {
  // TR: -1
  br ^bb1
^bb1:
  // TR: 1
  %c = llhd.const 4 : i32
  %prb1 = llhd.prb %sig : !llhd.sig<i32>
  llhd.wait ^bb2
^bb2:
  // TR: 0
  %double = addi %c, %c : i32
  %prb2 = llhd.prb %sig : !llhd.sig<i32>
  br ^bb1
}

// CHECK-LABEL:   llhd.proc @check_blockarg(
// CHECK-SAME:                              %[[VAL_0:.*]] : !llhd.sig<i32>) -> () {
// CHECK:           %[[VAL_1:.*]] = llhd.const 4 : i32
// CHECK:           br ^bb1(%[[VAL_1]] : i32)
// CHECK:         ^bb1(%[[VAL_2:.*]]: i32):
// CHECK:           %[[VAL_3:.*]] = addi %[[VAL_2]], %[[VAL_2]] : i32
// CHECK:           llhd.halt
// CHECK:         }
llhd.proc @check_blockarg(%sig : !llhd.sig<i32>) -> () {
  // TR: -1
  %c = llhd.const 4 : i32
  br ^bb1(%c : i32)
^bb1(%a : i32):
  // TR: -1
  %double = addi %a, %a : i32
  llhd.halt
}

// CHECK-LABEL:   llhd.proc @loop(
// CHECK-SAME:                    %[[VAL_0:.*]] : !llhd.sig<i2>) -> () {
// CHECK:           %[[VAL_1:.*]] = llhd.const 0 : i32
// CHECK:           %[[VAL_2:.*]] = llhd.const 2 : i32
// CHECK:           %[[VAL_3:.*]] = llhd.const 0 : i2
// CHECK:           %[[VAL_4:.*]] = llhd.const 1 : i32
// CHECK:           br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_5:.*]] = llhd.var %[[VAL_1]] : i32
// CHECK:           br ^bb2
// CHECK:         ^bb2:
// CHECK:           %[[VAL_6:.*]] = llhd.load %[[VAL_5]] : !llhd.ptr<i32>
// CHECK:           %[[VAL_7:.*]] = cmpi ult, %[[VAL_6]], %[[VAL_2]] : i32
// CHECK:           %[[VAL_8:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i2>
// CHECK:           cond_br %[[VAL_7]], ^bb4, ^bb3
// CHECK:         ^bb3:
// CHECK:           llhd.wait (%[[VAL_0]] : !llhd.sig<i2>), ^bb1
// CHECK:         ^bb4:
// CHECK:           %[[VAL_9:.*]] = llhd.load %[[VAL_5]] : !llhd.ptr<i32>
// CHECK:           %[[VAL_10:.*]] = addi %[[VAL_9]], %[[VAL_4]] : i32
// CHECK:           llhd.store %[[VAL_5]], %[[VAL_10]] : !llhd.ptr<i32>
// CHECK:           br ^bb2
// CHECK:         }
llhd.proc @loop(%in_i : !llhd.sig<i2>) -> () {
  // TR: -1
  br ^body
^body:
  // TR: 0
  %0 = llhd.const 0 : i32
  %i = llhd.var %0 : i32
  br ^loop_body
^loop_body:
  // TR: 1
  %i_ld = llhd.load %i : !llhd.ptr<i32>
  %1 = llhd.const 2 : i32
  %2 = cmpi ult, %i_ld, %1 : i32
  cond_br %2, ^loop_continue, ^check
^check:
  // TR: 1
  llhd.wait (%in_i : !llhd.sig<i2>), ^body
^loop_continue:
  // TR: 1
  %3 = llhd.const 0 : i2
  %5 = llhd.const 1 : i32
  %prb = llhd.prb %in_i : !llhd.sig<i2>
  %i_ld4 = llhd.load %i : !llhd.ptr<i32>
  %14 = addi %i_ld4, %5 : i32
  llhd.store %i, %14 : !llhd.ptr<i32>
  br ^loop_body
}

// CHECK-LABEL:   llhd.proc @complicated(
// CHECK-SAME: %[[VAL_0:.*]] : !llhd.sig<i1>, %[[VAL_1:.*]] : !llhd.sig<i1>, %[[VAL_2:.*]] : !llhd.sig<i1>) -> (%[[VAL_3:.*]] : !llhd.sig<i1>, %[[VAL_4:.*]] : !llhd.sig<i1>) {
// CHECK:           %[[VAL_5:.*]] = llhd.const false : i1
// CHECK:           %[[VAL_6:.*]] = llhd.const #llhd.time<0s, 1d, 0e> : !llhd.time
// CHECK:           br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_7:.*]] = llhd.prb %[[VAL_3]] : !llhd.sig<i1>
// CHECK:           %[[VAL_8:.*]] = llhd.var %[[VAL_7]] : i1
// CHECK:           br ^bb2
// CHECK:         ^bb2:
// CHECK:           %[[VAL_9:.*]] = llhd.prb %[[VAL_1]] : !llhd.sig<i1>
// CHECK:           %[[VAL_10:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i1>
// CHECK:           %[[VAL_11:.*]] = llhd.eq %[[VAL_9]], %[[VAL_5]] : i1
// CHECK:           %[[VAL_12:.*]] = llhd.neq %[[VAL_10]], %[[VAL_5]] : i1
// CHECK:           llhd.wait (%[[VAL_1]], %[[VAL_0]] : !llhd.sig<i1>, !llhd.sig<i1>), ^bb3
// CHECK:         ^bb3:
// CHECK:           %[[VAL_13:.*]] = llhd.prb %[[VAL_3]] : !llhd.sig<i1>
// CHECK:           llhd.store %[[VAL_8]], %[[VAL_13]] : !llhd.ptr<i1>
// CHECK:           llhd.store %[[VAL_8]], %[[VAL_13]] : !llhd.ptr<i1>
// CHECK:           %[[VAL_14:.*]] = llhd.prb %[[VAL_1]] : !llhd.sig<i1>
// CHECK:           %[[VAL_15:.*]] = llhd.neq %[[VAL_14]], %[[VAL_5]] : i1
// CHECK:           %[[VAL_16:.*]] = llhd.and %[[VAL_11]], %[[VAL_15]] : i1
// CHECK:           %[[VAL_17:.*]] = llhd.prb %[[VAL_0]] : !llhd.sig<i1>
// CHECK:           %[[VAL_18:.*]] = llhd.eq %[[VAL_17]], %[[VAL_5]] : i1
// CHECK:           %[[VAL_19:.*]] = llhd.and %[[VAL_18]], %[[VAL_12]] : i1
// CHECK:           %[[VAL_20:.*]] = llhd.or %[[VAL_16]], %[[VAL_19]] : i1
// CHECK:           %[[VAL_21:.*]] = llhd.neq %[[VAL_17]], %[[VAL_5]] : i1
// CHECK:           %[[VAL_22:.*]] = llhd.not %[[VAL_21]] : i1
// CHECK:           %[[VAL_23:.*]] = llhd.neq %[[VAL_22]], %[[VAL_5]] : i1
// CHECK:           %[[VAL_24:.*]] = llhd.prb %[[VAL_2]] : !llhd.sig<i1>
// CHECK:           cond_br %[[VAL_20]], ^bb4, ^bb2
// CHECK:         ^bb4:
// CHECK:           cond_br %[[VAL_23]], ^bb6, ^bb5
// CHECK:         ^bb5:
// CHECK:           llhd.drv %[[VAL_3]], %[[VAL_24]] after %[[VAL_6]] : !llhd.sig<i1>
// CHECK:           %[[VAL_25:.*]] = llhd.load %[[VAL_8]] : !llhd.ptr<i1>
// CHECK:           llhd.drv %[[VAL_4]], %[[VAL_25]] after %[[VAL_6]] : !llhd.sig<i1>
// CHECK:           br ^bb1
// CHECK:         ^bb6:
// CHECK:           llhd.drv %[[VAL_3]], %[[VAL_5]] after %[[VAL_6]] : !llhd.sig<i1>
// CHECK:           llhd.drv %[[VAL_4]], %[[VAL_5]] after %[[VAL_6]] : !llhd.sig<i1>
// CHECK:           br ^bb1
// CHECK:         }
llhd.proc @complicated(%rst_ni: !llhd.sig<i1>, %clk_i: !llhd.sig<i1>, %async_ack_i: !llhd.sig<i1>) -> (%ack_src_q: !llhd.sig<i1> , %ack_q: !llhd.sig<i1> ) {
  // TR: -1
  br ^0
^0:
  // TR: 1
  %1 = llhd.prb %ack_src_q : !llhd.sig<i1>
  %ack_src_q_shadow = llhd.var %1 : i1
  br ^init
^init:
  // TR: 2
  %clk_i_prb = llhd.prb %clk_i : !llhd.sig<i1>
  %rst_ni_prb = llhd.prb %rst_ni : !llhd.sig<i1>
  llhd.wait (%clk_i, %rst_ni : !llhd.sig<i1>, !llhd.sig<i1>), ^check
^check:
  // TR: 0
  %2 = llhd.prb %ack_src_q : !llhd.sig<i1>
  llhd.store %ack_src_q_shadow, %2 : !llhd.ptr<i1>
  llhd.store %ack_src_q_shadow, %2 : !llhd.ptr<i1>
  %clk_i_prb1 = llhd.prb %clk_i : !llhd.sig<i1>
  %3 = llhd.const 0 : i1
  %4 = llhd.eq %clk_i_prb, %3 : i1
  %5 = llhd.neq %clk_i_prb1, %3 : i1
  %posedge = llhd.and %4, %5 : i1
  %rst_ni_prb1 = llhd.prb %rst_ni : !llhd.sig<i1>
  %6 = llhd.neq %rst_ni_prb, %3 : i1
  %7 = llhd.eq %rst_ni_prb1, %3 : i1
  %negedge = llhd.and %7, %6 : i1
  %event_or = llhd.or %posedge, %negedge : i1
  cond_br %event_or, ^event, ^init
^event:
  // TR: 0
  %8 = llhd.neq %rst_ni_prb1, %3 : i1
  %9 = llhd.not %8 : i1
  %10 = llhd.neq %9, %3 : i1
  %11 = llhd.const #llhd.time<0s, 1d, 0e> : !llhd.time
  cond_br %10, ^if_true, ^if_false
^if_false:
  // TR: 0
  %async_ack_i_prb = llhd.prb %async_ack_i : !llhd.sig<i1>
  llhd.drv %ack_src_q, %async_ack_i_prb after %11 : !llhd.sig<i1>
  %ack_src_q_shadow_ld = llhd.load %ack_src_q_shadow : !llhd.ptr<i1>
  llhd.drv %ack_q, %ack_src_q_shadow_ld after %11 : !llhd.sig<i1>
  br ^0
^if_true:
  // TR: 0
  llhd.drv %ack_src_q, %3 after %11 : !llhd.sig<i1>
  llhd.drv %ack_q, %3 after %11 : !llhd.sig<i1>
  br ^0
}
