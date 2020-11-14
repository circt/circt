//===- Server.h - ESI cosim RPC servers -------------------------*- C++ -*-===//
//
// Various classes used to implement the RPC server classes generated by
// CapnProto. Capnp C++ RPC servers are based on 'libkj' and its asyncrony
// model, which is very foreign.
//
//===----------------------------------------------------------------------===//

#ifndef CIRCT_DIALECT_ESI_COSIM_SERVER_H
#define CIRCT_DIALECT_ESI_COSIM_SERVER_H

#include "circt/Dialect/ESI/cosim/CosimDpi.capnp.h"
#include "circt/Dialect/ESI/cosim/Endpoint.h"

namespace std {
class thread;
} // namespace std

namespace circt {
namespace esi {
namespace cosim {

/// Implements the `EsiDpiEndpoint` interface from the RPC schema. Mostly a
/// wrapper around an `Endpoint` object. Whereas the `Endpoint`s are long-lived
/// (associated with the RTL endpoint), this class is constructed/destructed
/// when the client open()s it.
class EndpointServer final
    : public EsiDpiEndpoint<capnp::AnyPointer, capnp::AnyPointer>::Server {
  /// The wrapped endpoint.
  Endpoint &endpoint;
  /// Signals that this endpoint has been opened by a client and hasn't been
  /// closed by said client.
  bool open;

public:
  EndpointServer(Endpoint &ep);
  /// Release the Endpoint should the client disconnect without properly closing
  /// it.
  ~EndpointServer();
  /// Disallow copying as the 'open' variable needs to track the endpoint.
  EndpointServer(const EndpointServer &) = delete;

  /// Implement the EsiDpiEndpoint RPC interface.
  kj::Promise<void> send(SendContext);
  kj::Promise<void> recv(RecvContext);
  kj::Promise<void> close(CloseContext);
};

/// Implements the `CosimDpiServer` interface from the RPC schema.
class CosimServer final : public CosimDpiServer::Server {
  /// The registry of endpoints. The RpcServer class owns this.
  EndpointRegistry *reg;

public:
  CosimServer(EndpointRegistry *reg);

  /// List all the registered interfaces.
  kj::Promise<void> list(ListContext ctxt);
  /// Open a specific interface, locking it in the process.
  kj::Promise<void> open(OpenContext ctxt);
};

/// The main RpcServer. Does not implement any capnp RPC interfaces but contains
/// the capnp main RPC server. We run the capnp server in its own thread to be
/// more responsive to network traffic and so as to not slow down the
/// simulation.
class RpcServer {
public:
  EndpointRegistry endpoints;

  RpcServer();
  ~RpcServer();

  /// Start and stop the server thread.
  void run(uint16_t port);
  void stop();

private:
  /// The thread's main loop function. Exits on shutdown.
  void mainLoop(uint16_t port);

  std::thread *mainThread;
  volatile bool stopSig;
};

} // namespace cosim
} // namespace esi
} // namespace circt

#endif
