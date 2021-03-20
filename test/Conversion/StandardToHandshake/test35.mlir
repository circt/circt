// NOTE: Assertions have been autogenerated by utils/update_mlir_test_checks.py
// RUN: circt-opt -create-dataflow %s | FileCheck %s
  func @test() {
// CHECK:       module {

// CHECK-LABEL:   handshake.func @test(
// CHECK-SAME:                         %[[VAL_0:.*]]: none, ...) -> none {
// CHECK:           %[[VAL_1:.*]]:3 = "handshake.memory"(%[[VAL_2:.*]]#0, %[[VAL_2]]#1, %[[VAL_3:.*]]) {id = 1 : i32, ld_count = 1 : i32, lsq = false, st_count = 1 : i32, type = memref<10xf32>} : (f32, index, index) -> (f32, none, none)
// CHECK:           %[[VAL_4:.*]]:3 = "handshake.memory"(%[[VAL_5:.*]]#0, %[[VAL_5]]#1, %[[VAL_6:.*]]) {id = 0 : i32, ld_count = 1 : i32, lsq = false, st_count = 1 : i32, type = memref<10xf32>} : (f32, index, index) -> (f32, none, none)
// CHECK:           %[[VAL_7:.*]]:3 = "handshake.fork"(%[[VAL_0]]) {control = true} : (none) -> (none, none, none)
// CHECK:           %[[VAL_8:.*]]:3 = "handshake.fork"(%[[VAL_7]]#2) {control = true} : (none) -> (none, none, none)
// CHECK:           %[[VAL_9:.*]] = "handshake.join"(%[[VAL_8]]#2, %[[VAL_4]]#2, %[[VAL_1]]#1) {control = true} : (none, none, none) -> none
// CHECK:           %[[VAL_10:.*]] = "handshake.constant"(%[[VAL_8]]#1) {value = 0 : index} : (none) -> index
// CHECK:           %[[VAL_11:.*]] = "handshake.constant"(%[[VAL_8]]#0) {value = 10 : index} : (none) -> index
// CHECK:           %[[VAL_12:.*]]:3 = "handshake.fork"(%[[VAL_11]]) {control = false} : (index) -> (index, index, index)
// CHECK:           %[[VAL_13:.*]], %[[VAL_6]] = "handshake.load"(%[[VAL_12]]#0, %[[VAL_4]]#0, %[[VAL_7]]#1) : (index, f32, none) -> (f32, index)
// CHECK:           %[[VAL_14:.*]]:2 = "handshake.fork"(%[[VAL_13]]) {control = false} : (f32) -> (f32, f32)
// CHECK:           %[[VAL_2]]:2 = "handshake.store"(%[[VAL_14]]#1, %[[VAL_12]]#1, %[[VAL_7]]#0) : (f32, index, none) -> (f32, index)
// CHECK:           %[[VAL_15:.*]] = "handshake.branch"(%[[VAL_9]]) {control = true} : (none) -> none
// CHECK:           %[[VAL_16:.*]] = "handshake.branch"(%[[VAL_10]]) {control = false} : (index) -> index
// CHECK:           %[[VAL_17:.*]] = "handshake.branch"(%[[VAL_12]]#2) {control = false} : (index) -> index
// CHECK:           %[[VAL_18:.*]] = "handshake.branch"(%[[VAL_14]]#0) {control = false} : (f32) -> f32
// CHECK:           %[[VAL_19:.*]] = "handshake.mux"(%[[VAL_20:.*]]#2, %[[VAL_21:.*]], %[[VAL_17]]) : (index, index, index) -> index
// CHECK:           %[[VAL_22:.*]]:2 = "handshake.fork"(%[[VAL_19]]) {control = false} : (index) -> (index, index)
// CHECK:           %[[VAL_23:.*]] = "handshake.mux"(%[[VAL_20]]#1, %[[VAL_24:.*]], %[[VAL_18]]) : (index, f32, f32) -> f32
// CHECK:           %[[VAL_25:.*]]:2 = "handshake.control_merge"(%[[VAL_26:.*]], %[[VAL_15]]) {control = true} : (none, none) -> (none, index)
// CHECK:           %[[VAL_20]]:3 = "handshake.fork"(%[[VAL_25]]#1) {control = false} : (index) -> (index, index, index)
// CHECK:           %[[VAL_27:.*]] = "handshake.mux"(%[[VAL_20]]#0, %[[VAL_28:.*]], %[[VAL_16]]) : (index, index, index) -> index
// CHECK:           %[[VAL_29:.*]]:2 = "handshake.fork"(%[[VAL_27]]) {control = false} : (index) -> (index, index)
// CHECK:           %[[VAL_30:.*]] = cmpi slt, %[[VAL_29]]#1, %[[VAL_22]]#1 : index
// CHECK:           %[[VAL_31:.*]]:4 = "handshake.fork"(%[[VAL_30]]) {control = false} : (i1) -> (i1, i1, i1, i1)
// CHECK:           %[[VAL_32:.*]], %[[VAL_33:.*]] = "handshake.conditional_branch"(%[[VAL_31]]#3, %[[VAL_22]]#0) {control = false} : (i1, index) -> (index, index)
// CHECK:           "handshake.sink"(%[[VAL_33]]) : (index) -> ()
// CHECK:           %[[VAL_34:.*]], %[[VAL_35:.*]] = "handshake.conditional_branch"(%[[VAL_31]]#2, %[[VAL_23]]) {control = false} : (i1, f32) -> (f32, f32)
// CHECK:           "handshake.sink"(%[[VAL_35]]) : (f32) -> ()
// CHECK:           %[[VAL_36:.*]], %[[VAL_37:.*]] = "handshake.conditional_branch"(%[[VAL_31]]#1, %[[VAL_25]]#0) {control = true} : (i1, none) -> (none, none)
// CHECK:           %[[VAL_38:.*]], %[[VAL_39:.*]] = "handshake.conditional_branch"(%[[VAL_31]]#0, %[[VAL_29]]#0) {control = false} : (i1, index) -> (index, index)
// CHECK:           "handshake.sink"(%[[VAL_39]]) : (index) -> ()
// CHECK:           %[[VAL_40:.*]] = "handshake.merge"(%[[VAL_38]]) : (index) -> index
// CHECK:           %[[VAL_41:.*]] = "handshake.merge"(%[[VAL_34]]) : (f32) -> f32
// CHECK:           %[[VAL_42:.*]]:2 = "handshake.fork"(%[[VAL_41]]) {control = false} : (f32) -> (f32, f32)
// CHECK:           %[[VAL_43:.*]] = "handshake.merge"(%[[VAL_32]]) : (index) -> index
// CHECK:           %[[VAL_44:.*]]:2 = "handshake.control_merge"(%[[VAL_36]]) {control = true} : (none) -> (none, index)
// CHECK:           %[[VAL_45:.*]]:3 = "handshake.fork"(%[[VAL_44]]#0) {control = true} : (none) -> (none, none, none)
// CHECK:           %[[VAL_46:.*]]:2 = "handshake.fork"(%[[VAL_45]]#2) {control = true} : (none) -> (none, none)
// CHECK:           %[[VAL_47:.*]] = "handshake.join"(%[[VAL_46]]#1, %[[VAL_4]]#1, %[[VAL_1]]#2) {control = true} : (none, none, none) -> none
// CHECK:           "handshake.sink"(%[[VAL_44]]#1) : (index) -> ()
// CHECK:           %[[VAL_48:.*]] = "handshake.constant"(%[[VAL_46]]#0) {value = 1 : index} : (none) -> index
// CHECK:           %[[VAL_49:.*]] = addi %[[VAL_40]], %[[VAL_48]] : index
// CHECK:           %[[VAL_50:.*]]:3 = "handshake.fork"(%[[VAL_49]]) {control = false} : (index) -> (index, index, index)
// CHECK:           %[[VAL_51:.*]], %[[VAL_3]] = "handshake.load"(%[[VAL_50]]#2, %[[VAL_1]]#0, %[[VAL_45]]#0) : (index, f32, none) -> (f32, index)
// CHECK:           %[[VAL_52:.*]] = addf %[[VAL_42]]#1, %[[VAL_51]] : f32
// CHECK:           %[[VAL_5]]:2 = "handshake.store"(%[[VAL_52]], %[[VAL_50]]#1, %[[VAL_45]]#1) : (f32, index, none) -> (f32, index)
// CHECK:           %[[VAL_24]] = "handshake.branch"(%[[VAL_42]]#0) {control = false} : (f32) -> f32
// CHECK:           %[[VAL_21]] = "handshake.branch"(%[[VAL_43]]) {control = false} : (index) -> index
// CHECK:           %[[VAL_26]] = "handshake.branch"(%[[VAL_47]]) {control = true} : (none) -> none
// CHECK:           %[[VAL_28]] = "handshake.branch"(%[[VAL_50]]#0) {control = false} : (index) -> index
// CHECK:           %[[VAL_53:.*]]:2 = "handshake.control_merge"(%[[VAL_37]]) {control = true} : (none) -> (none, index)
// CHECK:           "handshake.sink"(%[[VAL_53]]#1) : (index) -> ()
// CHECK:           handshake.return %[[VAL_53]]#0 : none
// CHECK:         }
// CHECK:       }

    %10 = memref.alloc() : memref<10xf32>
    %11 = memref.alloc() : memref<10xf32>
    %c0 = constant 0 : index
    %c10 = constant 10 : index
    %5 = memref.load %10[%c10] : memref<10xf32>
    memref.store %5, %11[%c10] : memref<10xf32>
    br ^bb1(%c0 : index)
  ^bb1(%1: index):      // 2 preds: ^bb0, ^bb2
    %2 = cmpi slt, %1, %c10 : index
    cond_br %2, ^bb2, ^bb3
  ^bb2: // pred: ^bb1
    %c1 = constant 1 : index
    %3 = addi %1, %c1 : index
    %7 = memref.load %11[%3] : memref<10xf32>
    %8 = addf %5, %7 : f32
    memref.store %8, %10[%3] : memref<10xf32>
    br ^bb1(%3 : index)
  ^bb3: // pred: ^bb1
    return
  }
