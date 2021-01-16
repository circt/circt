// NOTE: Assertions have been autogenerated by utils/update_mlir_test_checks.py
// RUN: circt-opt -create-dataflow %s | FileCheck %s
func @affine_apply_mod(%arg0: index) -> index {
// CHECK:       module {

// CHECK-LABEL:   handshake.func @affine_apply_mod(
// CHECK-SAME:                                     %[[VAL_0:.*]]: index, %[[VAL_1:.*]]: none, ...) -> (index, none) {
// CHECK:           %[[VAL_2:.*]] = "handshake.merge"(%[[VAL_0]]) : (index) -> index
// CHECK:           %[[VAL_3:.*]]:3 = "handshake.fork"(%[[VAL_1]]) {control = true} : (none) -> (none, none, none)
// CHECK:           %[[VAL_4:.*]] = "handshake.constant"(%[[VAL_3]]#1) {value = 42 : index} : (none) -> index
// CHECK:           %[[VAL_5:.*]]:2 = "handshake.fork"(%[[VAL_4]]) {control = false} : (index) -> (index, index)
// CHECK:           %[[VAL_6:.*]] = remi_signed %[[VAL_2]], %[[VAL_5]]#0 : index
// CHECK:           %[[VAL_7:.*]]:3 = "handshake.fork"(%[[VAL_6]]) {control = false} : (index) -> (index, index, index)
// CHECK:           %[[VAL_8:.*]] = "handshake.constant"(%[[VAL_3]]#0) {value = 0 : index} : (none) -> index
// CHECK:           %[[VAL_9:.*]] = cmpi slt, %[[VAL_7]]#2, %[[VAL_8]] : index
// CHECK:           %[[VAL_10:.*]] = addi %[[VAL_7]]#1, %[[VAL_5]]#1 : index
// CHECK:           %[[VAL_11:.*]] = select %[[VAL_9]], %[[VAL_10]], %[[VAL_7]]#0 : index
// CHECK:           handshake.return %[[VAL_11]], %[[VAL_3]]#2 : index, none
// CHECK:         }
// CHECK:       }

    %c42 = constant 42 : index
    %0 = remi_signed %arg0, %c42 : index
    %c0 = constant 0 : index
    %1 = cmpi slt, %0, %c0 : index
    %2 = addi %0, %c42 : index
    %3 = select %1, %2, %0 : index
    return %3 : index
  }
