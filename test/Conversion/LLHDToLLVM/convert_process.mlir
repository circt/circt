// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: circt-opt %s --convert-llhd-to-llvm --split-input-file | FileCheck %s

// CHECK-LABEL: @dummy_i1
func @dummy_i1 (%0 : i1) {
  return
}

// CHECK-LABEL: @dummy_i32
func @dummy_i32 (%0 : i32)  {
  return
}

// CHECK-LABEL: @dummy_time
func @dummy_time (%0 : !llhd.time) {
  return
}

// CHECK-LABEL: @dummy_ptr
func @dummy_ptr(%0 : !llhd.ptr<i32>) {
  return
}

// CHECK-LABEL: @dummy_subsig
func @dummy_subsig(%0 : !llhd.sig<i10>) {
  return
}

// CHECK-LABEL:   llvm.func @convert_persistent_value(
// CHECK-SAME:                                        %[[VAL_0:.*]]: !llvm.ptr<i8>,
// CHECK-SAME:                                        %[[VAL_1:.*]]: !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>,
// CHECK-SAME:                                        %[[VAL_2:.*]]: !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>) {
// CHECK:           %[[VAL_3:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_4:.*]] = llvm.getelementptr %[[VAL_2]]{{\[}}%[[VAL_3]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_5:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_6:.*]] = llvm.getelementptr %[[VAL_2]]{{\[}}%[[VAL_5]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_7:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_8:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_9:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_7]], %[[VAL_8]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_10:.*]] = llvm.load %[[VAL_9]] : !llvm.ptr<i32>
// CHECK:           llvm.br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_11:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_12:.*]] = llvm.icmp "eq" %[[VAL_10]], %[[VAL_11]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_12]], ^bb2, ^bb5
// CHECK:         ^bb2:
// CHECK:           llvm.br ^bb3
// CHECK:         ^bb3:
// CHECK:           %[[VAL_13:.*]] = llvm.mlir.constant(false) : !llvm.i1
// CHECK:           %[[VAL_14:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_15:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_16:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_17:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_14]], %[[VAL_15]], %[[VAL_16]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_13]], %[[VAL_17]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_18:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_19:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_20:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_21:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_22:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_19]], %[[VAL_20]], %[[VAL_21]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_18]], %[[VAL_22]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_23:.*]] = llvm.mlir.constant(dense<[0, 0, 1]> : vector<3xi64>) : !llvm.array<3 x i64>
// CHECK:           %[[VAL_24:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_25:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_26:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_27:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_24]], %[[VAL_25]], %[[VAL_26]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<array<3 x i64>>
// CHECK:           llvm.store %[[VAL_23]], %[[VAL_27]] : !llvm.ptr<array<3 x i64>>
// CHECK:           %[[VAL_28:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_29:.*]] = llvm.alloca %[[VAL_28]] x !llvm.i32 {alignment = 4 : i64} : (!llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_18]], %[[VAL_29]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_30:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_31:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_32:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_33:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_30]], %[[VAL_31]], %[[VAL_32]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_34:.*]] = llvm.load %[[VAL_29]] : !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_34]], %[[VAL_33]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_35:.*]] = llvm.mlir.constant(0 : index) : !llvm.i64
// CHECK:           %[[VAL_36:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_37:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_38:.*]] = llvm.getelementptr %[[VAL_6]]{{\[}}%[[VAL_36]], %[[VAL_36]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<i8>>
// CHECK:           %[[VAL_39:.*]] = llvm.load %[[VAL_38]] : !llvm.ptr<ptr<i8>>
// CHECK:           %[[VAL_40:.*]] = llvm.getelementptr %[[VAL_6]]{{\[}}%[[VAL_36]], %[[VAL_37]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_41:.*]] = llvm.load %[[VAL_40]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_42:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_43:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_44:.*]] = llvm.getelementptr %[[VAL_6]]{{\[}}%[[VAL_36]], %[[VAL_42]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_45:.*]] = llvm.load %[[VAL_44]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_46:.*]] = llvm.getelementptr %[[VAL_6]]{{\[}}%[[VAL_36]], %[[VAL_43]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_47:.*]] = llvm.load %[[VAL_46]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_48:.*]] = llvm.add %[[VAL_41]], %[[VAL_35]] : !llvm.i64
// CHECK:           %[[VAL_49:.*]] = llvm.ptrtoint %[[VAL_39]] : !llvm.ptr<i8> to !llvm.i64
// CHECK:           %[[VAL_50:.*]] = llvm.mlir.constant(8 : i64) : !llvm.i64
// CHECK:           %[[VAL_51:.*]] = llvm.udiv %[[VAL_48]], %[[VAL_50]] : !llvm.i64
// CHECK:           %[[VAL_52:.*]] = llvm.add %[[VAL_49]], %[[VAL_51]] : !llvm.i64
// CHECK:           %[[VAL_53:.*]] = llvm.inttoptr %[[VAL_52]] : !llvm.i64 to !llvm.ptr<i8>
// CHECK:           %[[VAL_54:.*]] = llvm.urem %[[VAL_48]], %[[VAL_50]] : !llvm.i64
// CHECK:           %[[VAL_55:.*]] = llvm.mlir.undef : !llvm.struct<(ptr<i8>, i64, i64, i64)>
// CHECK:           %[[VAL_56:.*]] = llvm.insertvalue %[[VAL_53]], %[[VAL_55]][0 : i32] : !llvm.struct<(ptr<i8>, i64, i64, i64)>
// CHECK:           %[[VAL_57:.*]] = llvm.insertvalue %[[VAL_54]], %[[VAL_56]][1 : i32] : !llvm.struct<(ptr<i8>, i64, i64, i64)>
// CHECK:           %[[VAL_58:.*]] = llvm.insertvalue %[[VAL_45]], %[[VAL_57]][2 : i32] : !llvm.struct<(ptr<i8>, i64, i64, i64)>
// CHECK:           %[[VAL_59:.*]] = llvm.insertvalue %[[VAL_47]], %[[VAL_58]][3 : i32] : !llvm.struct<(ptr<i8>, i64, i64, i64)>
// CHECK:           %[[VAL_60:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_61:.*]] = llvm.alloca %[[VAL_60]] x !llvm.struct<(ptr<i8>, i64, i64, i64)> {alignment = 4 : i64} : (!llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           llvm.store %[[VAL_59]], %[[VAL_61]] : !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_62:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_63:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_64:.*]] = llvm.mlir.constant(4 : i32) : !llvm.i32
// CHECK:           %[[VAL_65:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_62]], %[[VAL_63]], %[[VAL_64]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_66:.*]] = llvm.load %[[VAL_61]] : !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           llvm.store %[[VAL_66]], %[[VAL_65]] : !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           llvm.br ^bb4
// CHECK:         ^bb4:
// CHECK:           %[[VAL_67:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_68:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_69:.*]] = llvm.mlir.constant(4 : i32) : !llvm.i32
// CHECK:           %[[VAL_70:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_67]], %[[VAL_68]], %[[VAL_69]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_71:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_72:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_73:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_74:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_71]], %[[VAL_72]], %[[VAL_73]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_75:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_76:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_77:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_78:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_75]], %[[VAL_76]], %[[VAL_77]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<array<3 x i64>>
// CHECK:           %[[VAL_79:.*]] = llvm.load %[[VAL_78]] : !llvm.ptr<array<3 x i64>>
// CHECK:           %[[VAL_80:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_81:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_82:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_83:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_80]], %[[VAL_81]], %[[VAL_82]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_84:.*]] = llvm.load %[[VAL_83]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_85:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_86:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_87:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_88:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_85]], %[[VAL_86]], %[[VAL_87]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<2 x i1>>, struct<(i1, i32, array<3 x i64>, i32, struct<(ptr<i8>, i64, i64, i64)>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           %[[VAL_89:.*]] = llvm.load %[[VAL_88]] : !llvm.ptr<i1>
// CHECK:           llvm.call @dummy_i1(%[[VAL_89]]) : (!llvm.i1) -> ()
// CHECK:           llvm.call @dummy_i32(%[[VAL_84]]) : (!llvm.i32) -> ()
// CHECK:           llvm.call @dummy_time(%[[VAL_79]]) : (!llvm.array<3 x i64>) -> ()
// CHECK:           llvm.call @dummy_ptr(%[[VAL_74]]) : (!llvm.ptr<i32>) -> ()
// CHECK:           llvm.call @dummy_subsig(%[[VAL_70]]) : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>) -> ()
// CHECK:           llvm.br ^bb4
// CHECK:         ^bb5:
// CHECK:           llvm.return
// CHECK:         }
llhd.proc @convert_persistent_value () -> (%out0 : !llhd.sig<i1>, %out1 : !llhd.sig<i32>) {
  br ^entry
^entry:
  %0 = llhd.const 0 : i1
  %1 = llhd.const 0 : i32
  %2 = llhd.const #llhd.time<0ns, 0d, 1e> : !llhd.time
  %var = llhd.var %1 : i32
  %subsig = llhd.extract_slice %out1, 0 : !llhd.sig<i32> -> !llhd.sig<i10>
  br ^resume
^resume:
  call @dummy_i1(%0) : (i1) -> ()
  call @dummy_i32(%1) : (i32) -> ()
  call @dummy_time(%2) : (!llhd.time) -> ()
  call @dummy_ptr(%var) : (!llhd.ptr<i32>) -> ()
  call @dummy_subsig(%subsig) : (!llhd.sig<i10>) -> ()
  br ^resume
}

// CHECK-LABEL:   llvm.func @convert_resume(
// CHECK-SAME:                              %[[VAL_0:.*]]: !llvm.ptr<i8>,
// CHECK-SAME:                              %[[VAL_1:.*]]: !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>,
// CHECK-SAME:                              %[[VAL_2:.*]]: !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>) {
// CHECK:           %[[VAL_3:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_4:.*]] = llvm.getelementptr %[[VAL_2]]{{\[}}%[[VAL_3]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_5:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_6:.*]] = llvm.getelementptr %[[VAL_2]]{{\[}}%[[VAL_5]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_7:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_8:.*]] = llvm.getelementptr %[[VAL_2]]{{\[}}%[[VAL_7]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32) -> !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>
// CHECK:           %[[VAL_9:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_10:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_11:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_9]], %[[VAL_10]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_12:.*]] = llvm.load %[[VAL_11]] : !llvm.ptr<i32>
// CHECK:           llvm.br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_13:.*]] = llvm.mlir.constant(4 : i32) : !llvm.i32
// CHECK:           %[[VAL_14:.*]] = llvm.icmp "eq" %[[VAL_12]], %[[VAL_13]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_14]], ^bb11, ^bb2
// CHECK:         ^bb2:
// CHECK:           %[[VAL_15:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_16:.*]] = llvm.icmp "eq" %[[VAL_12]], %[[VAL_15]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_16]], ^bb10, ^bb3
// CHECK:         ^bb3:
// CHECK:           %[[VAL_17:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_18:.*]] = llvm.icmp "eq" %[[VAL_12]], %[[VAL_17]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_18]], ^bb9, ^bb4
// CHECK:         ^bb4:
// CHECK:           %[[VAL_19:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_20:.*]] = llvm.icmp "eq" %[[VAL_12]], %[[VAL_19]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_20]], ^bb8, ^bb5
// CHECK:         ^bb5:
// CHECK:           %[[VAL_21:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_22:.*]] = llvm.icmp "eq" %[[VAL_12]], %[[VAL_21]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_22]], ^bb6, ^bb12
// CHECK:         ^bb6:
// CHECK:           llvm.br ^bb7
// CHECK:         ^bb7:
// CHECK:           %[[VAL_23:.*]] = llvm.mlir.constant(dense<[0, 0, 1]> : vector<3xi64>) : !llvm.array<3 x i64>
// CHECK:           %[[VAL_24:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_25:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_26:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_27:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_24]], %[[VAL_25]], %[[VAL_26]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<array<3 x i64>>
// CHECK:           llvm.store %[[VAL_23]], %[[VAL_27]] : !llvm.ptr<array<3 x i64>>
// CHECK:           %[[VAL_28:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_29:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_9]], %[[VAL_10]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_28]], %[[VAL_29]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_30:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_31:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_32:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_30]], %[[VAL_31]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_33:.*]] = llvm.load %[[VAL_32]] : !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_34:.*]] = llvm.mlir.constant(false) : !llvm.i1
// CHECK:           %[[VAL_35:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_36:.*]] = llvm.getelementptr %[[VAL_33]]{{\[}}%[[VAL_30]], %[[VAL_35]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_34]], %[[VAL_36]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_37:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_38:.*]] = llvm.getelementptr %[[VAL_33]]{{\[}}%[[VAL_30]], %[[VAL_37]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_34]], %[[VAL_38]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_39:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_40:.*]] = llvm.getelementptr %[[VAL_33]]{{\[}}%[[VAL_30]], %[[VAL_39]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_34]], %[[VAL_40]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_41:.*]] = llvm.bitcast %[[VAL_1]] : !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>> to !llvm.ptr<i8>
// CHECK:           %[[VAL_42:.*]] = llvm.extractvalue %[[VAL_23]][0 : i32] : !llvm.array<3 x i64>
// CHECK:           %[[VAL_43:.*]] = llvm.extractvalue %[[VAL_23]][1 : i32] : !llvm.array<3 x i64>
// CHECK:           %[[VAL_44:.*]] = llvm.extractvalue %[[VAL_23]][2 : i32] : !llvm.array<3 x i64>
// CHECK:           %[[VAL_45:.*]] = llvm.call @llhd_suspend(%[[VAL_0]], %[[VAL_41]], %[[VAL_42]], %[[VAL_43]], %[[VAL_44]]) : (!llvm.ptr<i8>, !llvm.ptr<i8>, !llvm.i64, !llvm.i64, !llvm.i64) -> !llvm.void
// CHECK:           llvm.return
// CHECK:         ^bb8:
// CHECK:           %[[VAL_46:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_47:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_9]], %[[VAL_10]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_46]], %[[VAL_47]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_48:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_49:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_50:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_48]], %[[VAL_49]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_51:.*]] = llvm.load %[[VAL_50]] : !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_52:.*]] = llvm.mlir.constant(false) : !llvm.i1
// CHECK:           %[[VAL_53:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_54:.*]] = llvm.getelementptr %[[VAL_51]]{{\[}}%[[VAL_48]], %[[VAL_53]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_52]], %[[VAL_54]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_55:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_56:.*]] = llvm.getelementptr %[[VAL_51]]{{\[}}%[[VAL_48]], %[[VAL_55]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_52]], %[[VAL_56]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_57:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_58:.*]] = llvm.getelementptr %[[VAL_51]]{{\[}}%[[VAL_48]], %[[VAL_57]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_52]], %[[VAL_58]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_59:.*]] = llvm.getelementptr %[[VAL_4]]{{\[}}%[[VAL_48]], %[[VAL_49]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_60:.*]] = llvm.load %[[VAL_59]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_61:.*]] = llvm.mlir.constant(true) : !llvm.i1
// CHECK:           %[[VAL_62:.*]] = llvm.getelementptr %[[VAL_51]]{{\[}}%[[VAL_48]], %[[VAL_60]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i64) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_61]], %[[VAL_62]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_63:.*]] = llvm.getelementptr %[[VAL_8]]{{\[}}%[[VAL_48]], %[[VAL_49]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_64:.*]] = llvm.load %[[VAL_63]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_65:.*]] = llvm.mlir.constant(true) : !llvm.i1
// CHECK:           %[[VAL_66:.*]] = llvm.getelementptr %[[VAL_51]]{{\[}}%[[VAL_48]], %[[VAL_64]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i64) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_65]], %[[VAL_66]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_67:.*]] = llvm.bitcast %[[VAL_1]] : !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>> to !llvm.ptr<i8>
// CHECK:           llvm.return
// CHECK:         ^bb9:
// CHECK:           %[[VAL_68:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_69:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_70:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_71:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_68]], %[[VAL_69]], %[[VAL_70]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<array<3 x i64>>
// CHECK:           %[[VAL_72:.*]] = llvm.load %[[VAL_71]] : !llvm.ptr<array<3 x i64>>
// CHECK:           %[[VAL_73:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_74:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_9]], %[[VAL_10]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_73]], %[[VAL_74]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_75:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_76:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_77:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_75]], %[[VAL_76]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_78:.*]] = llvm.load %[[VAL_77]] : !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_79:.*]] = llvm.mlir.constant(false) : !llvm.i1
// CHECK:           %[[VAL_80:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_81:.*]] = llvm.getelementptr %[[VAL_78]]{{\[}}%[[VAL_75]], %[[VAL_80]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_79]], %[[VAL_81]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_82:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_83:.*]] = llvm.getelementptr %[[VAL_78]]{{\[}}%[[VAL_75]], %[[VAL_82]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_79]], %[[VAL_83]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_84:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_85:.*]] = llvm.getelementptr %[[VAL_78]]{{\[}}%[[VAL_75]], %[[VAL_84]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_79]], %[[VAL_85]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_86:.*]] = llvm.getelementptr %[[VAL_6]]{{\[}}%[[VAL_75]], %[[VAL_76]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_87:.*]] = llvm.load %[[VAL_86]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_88:.*]] = llvm.mlir.constant(true) : !llvm.i1
// CHECK:           %[[VAL_89:.*]] = llvm.getelementptr %[[VAL_78]]{{\[}}%[[VAL_75]], %[[VAL_87]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i64) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_88]], %[[VAL_89]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_90:.*]] = llvm.bitcast %[[VAL_1]] : !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>> to !llvm.ptr<i8>
// CHECK:           %[[VAL_91:.*]] = llvm.extractvalue %[[VAL_72]][0 : i32] : !llvm.array<3 x i64>
// CHECK:           %[[VAL_92:.*]] = llvm.extractvalue %[[VAL_72]][1 : i32] : !llvm.array<3 x i64>
// CHECK:           %[[VAL_93:.*]] = llvm.extractvalue %[[VAL_72]][2 : i32] : !llvm.array<3 x i64>
// CHECK:           %[[VAL_94:.*]] = llvm.call @llhd_suspend(%[[VAL_0]], %[[VAL_90]], %[[VAL_91]], %[[VAL_92]], %[[VAL_93]]) : (!llvm.ptr<i8>, !llvm.ptr<i8>, !llvm.i64, !llvm.i64, !llvm.i64) -> !llvm.void
// CHECK:           llvm.return
// CHECK:         ^bb10:
// CHECK:           %[[VAL_95:.*]] = llvm.mlir.constant(4 : i32) : !llvm.i32
// CHECK:           %[[VAL_96:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_9]], %[[VAL_10]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_95]], %[[VAL_96]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_97:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_98:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_99:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_97]], %[[VAL_98]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_100:.*]] = llvm.load %[[VAL_99]] : !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_101:.*]] = llvm.getelementptr %[[VAL_4]]{{\[}}%[[VAL_97]], %[[VAL_98]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_102:.*]] = llvm.load %[[VAL_101]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_103:.*]] = llvm.mlir.constant(true) : !llvm.i1
// CHECK:           %[[VAL_104:.*]] = llvm.getelementptr %[[VAL_100]]{{\[}}%[[VAL_97]], %[[VAL_102]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i64) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_103]], %[[VAL_104]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_105:.*]] = llvm.getelementptr %[[VAL_8]]{{\[}}%[[VAL_97]], %[[VAL_98]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_106:.*]] = llvm.load %[[VAL_105]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_107:.*]] = llvm.mlir.constant(true) : !llvm.i1
// CHECK:           %[[VAL_108:.*]] = llvm.getelementptr %[[VAL_100]]{{\[}}%[[VAL_97]], %[[VAL_106]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i64) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_107]], %[[VAL_108]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_109:.*]] = llvm.getelementptr %[[VAL_6]]{{\[}}%[[VAL_97]], %[[VAL_98]]] : (!llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i64>
// CHECK:           %[[VAL_110:.*]] = llvm.load %[[VAL_109]] : !llvm.ptr<i64>
// CHECK:           %[[VAL_111:.*]] = llvm.mlir.constant(true) : !llvm.i1
// CHECK:           %[[VAL_112:.*]] = llvm.getelementptr %[[VAL_100]]{{\[}}%[[VAL_97]], %[[VAL_110]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i64) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_111]], %[[VAL_112]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_113:.*]] = llvm.bitcast %[[VAL_1]] : !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>> to !llvm.ptr<i8>
// CHECK:           llvm.return
// CHECK:         ^bb11:
// CHECK:           %[[VAL_114:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_115:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_116:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_114]], %[[VAL_115]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<3 x i1>>, struct<(array<3 x i64>)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_117:.*]] = llvm.load %[[VAL_116]] : !llvm.ptr<ptr<array<3 x i1>>>
// CHECK:           %[[VAL_118:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_119:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i1
// CHECK:           %[[VAL_120:.*]] = llvm.getelementptr %[[VAL_117]]{{\[}}%[[VAL_114]], %[[VAL_118]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_119]], %[[VAL_120]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_121:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_122:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i1
// CHECK:           %[[VAL_123:.*]] = llvm.getelementptr %[[VAL_117]]{{\[}}%[[VAL_114]], %[[VAL_121]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_122]], %[[VAL_123]] : !llvm.ptr<i1>
// CHECK:           %[[VAL_124:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_125:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i1
// CHECK:           %[[VAL_126:.*]] = llvm.getelementptr %[[VAL_117]]{{\[}}%[[VAL_114]], %[[VAL_124]]] : (!llvm.ptr<array<3 x i1>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_125]], %[[VAL_126]] : !llvm.ptr<i1>
// CHECK:           llvm.return
// CHECK:         ^bb12:
// CHECK:           llvm.return
// CHECK:         }
llhd.proc @convert_resume (%in0 : !llhd.sig<i1>, %in1 : !llhd.sig<i32>) -> (%out0 : !llhd.sig<i20>) {
    br ^wait_timed
^wait_timed:
    %t = llhd.const #llhd.time<0ns, 0d, 1e> : !llhd.time
    llhd.wait for %t, ^wait_observe
^wait_observe:
    llhd.wait (%in0, %out0 : !llhd.sig<i1>, !llhd.sig<i20>), ^wait_timed_observe
^wait_timed_observe:
    llhd.wait for %t, (%in1 : !llhd.sig<i32>), ^wait_observe_all
^wait_observe_all:
    llhd.wait (%in0, %out0, %in1 : !llhd.sig<i1>, !llhd.sig<i20>, !llhd.sig<i32>), ^end
^end:
    llhd.halt
}


// CHECK-LABEL:   llvm.func @convert_persistent_block_argument(
// CHECK-SAME:                                                 %[[VAL_0:.*]]: !llvm.ptr<i8>,
// CHECK-SAME:                                                 %[[VAL_1:.*]]: !llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>,
// CHECK-SAME:                                                 %[[VAL_2:.*]]: !llvm.ptr<struct<(ptr<i8>, i64, i64, i64)>>) {
// CHECK:           %[[VAL_3:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_4:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_5:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_3]], %[[VAL_4]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_6:.*]] = llvm.load %[[VAL_5]] : !llvm.ptr<i32>
// CHECK:           llvm.br ^bb1
// CHECK:         ^bb1:
// CHECK:           %[[VAL_7:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_8:.*]] = llvm.icmp "eq" %[[VAL_6]], %[[VAL_7]] : !llvm.i32
// CHECK:           llvm.cond_br %[[VAL_8]], ^bb2, ^bb6
// CHECK:         ^bb2:
// CHECK:           llvm.br ^bb3
// CHECK:         ^bb3:
// CHECK:           %[[VAL_9:.*]] = llvm.mlir.constant(false) : !llvm.i1
// CHECK:           %[[VAL_10:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           llvm.br ^bb4(%[[VAL_9]], %[[VAL_10]] : !llvm.i1, !llvm.i32)
// CHECK:         ^bb4(%[[VAL_11:.*]]: !llvm.i1, %[[VAL_12:.*]]: !llvm.i32):
// CHECK:           %[[VAL_13:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_14:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_15:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_16:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_13]], %[[VAL_14]], %[[VAL_15]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           llvm.store %[[VAL_12]], %[[VAL_16]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_17:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_18:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_19:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_20:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_17]], %[[VAL_18]], %[[VAL_19]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           llvm.store %[[VAL_11]], %[[VAL_20]] : !llvm.ptr<i1>
// CHECK:           llvm.br ^bb5
// CHECK:         ^bb5:
// CHECK:           %[[VAL_21:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_22:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_23:.*]] = llvm.mlir.constant(1 : i32) : !llvm.i32
// CHECK:           %[[VAL_24:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_21]], %[[VAL_22]], %[[VAL_23]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i32>
// CHECK:           %[[VAL_25:.*]] = llvm.load %[[VAL_24]] : !llvm.ptr<i32>
// CHECK:           %[[VAL_26:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_27:.*]] = llvm.mlir.constant(3 : i32) : !llvm.i32
// CHECK:           %[[VAL_28:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_29:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_26]], %[[VAL_27]], %[[VAL_28]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>, !llvm.i32, !llvm.i32, !llvm.i32) -> !llvm.ptr<i1>
// CHECK:           %[[VAL_30:.*]] = llvm.load %[[VAL_29]] : !llvm.ptr<i1>
// CHECK:           llvm.call @dummy_i1(%[[VAL_30]]) : (!llvm.i1) -> ()
// CHECK:           llvm.call @dummy_i32(%[[VAL_25]]) : (!llvm.i32) -> ()
// CHECK:           %[[VAL_31:.*]] = llvm.mlir.constant(0 : i32) : !llvm.i32
// CHECK:           %[[VAL_32:.*]] = llvm.mlir.constant(2 : i32) : !llvm.i32
// CHECK:           %[[VAL_33:.*]] = llvm.getelementptr %[[VAL_1]]{{\[}}%[[VAL_31]], %[[VAL_32]]] : (!llvm.ptr<struct<(ptr<i8>, i32, ptr<array<0 x i1>>, struct<(i1, i32)>)>>, !llvm.i32, !llvm.i32) -> !llvm.ptr<ptr<array<0 x i1>>>
// CHECK:           %[[VAL_34:.*]] = llvm.load %[[VAL_33]] : !llvm.ptr<ptr<array<0 x i1>>>
// CHECK:           llvm.return
// CHECK:         ^bb6:
// CHECK:           llvm.return
// CHECK:         }
llhd.proc @convert_persistent_block_argument () -> () {
    br ^entry
^entry:
    %0 = llhd.const 0 : i1
    %1 = llhd.const 0 : i32
    br ^argBB(%0, %1 : i1, i32)
^argBB(%i : i1, %j : i32):
    br ^end
^end:
    call @dummy_i1(%i) : (i1) -> ()
    call @dummy_i32(%j) : (i32) -> ()
    llhd.halt
}
