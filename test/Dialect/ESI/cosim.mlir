// RUN: circt-opt %s -verify-diagnostics | circt-opt -verify-diagnostics | FileCheck %s
// RUN: circt-translate %s -emit-esi-capnp -verify-diagnostics | FileCheck --check-prefix=CAPNP %s

module {
  rtl.externmodule @Sender() -> ( !esi.channel<si14> { rtl.name = "x"})
  rtl.externmodule @Reciever(%a: !esi.channel<i32>)

  // CHECK-LABEL: rtl.externmodule @Sender() -> (%x: !esi.channel<si14>)
  // CHECK-LABEL: rtl.externmodule @Reciever(!esi.channel<i32> {rtl.name = "a"})

  rtl.module @Top(%clk:i1, %rstn:i1) -> () {
    rtl.instance "recv" @Reciever (%cosimRecv) : (!esi.channel<i32>) -> ()
    // CHECK:  rtl.instance "recv" @Reciever(%0)  : (!esi.channel<i32>) -> ()

    %send.x = rtl.instance "send" @Sender () : () -> (!esi.channel<si14>)
    // CHECK:  %send.x = rtl.instance "send" @Sender() : () -> !esi.channel<si14>

    %cosimRecv = esi.cosim %clk, %rstn, %send.x, 1 {name="TestEP"} : !esi.channel<si14> -> !esi.channel<i32>
    // CHECK:  %0 = esi.cosim %clk, %rstn, %send.x, 1 {name = "TestEP"} : !esi.channel<si14> -> !esi.channel<i32>

    // Ensure that the file hash is deterministic.
    // CAPNP: @0x8bb640ebe6388872;
    // CAPNP-LABEL: struct ESI_i32 @0xa805e789c4c1d78c
    // CAPNP:         i @0 :UInt32;
    // CAPNP-LABEL: struct ESI_si14 @0x01f8421bc3203d9f
    // CAPNP:         i @0 :Int16;
  }
}
