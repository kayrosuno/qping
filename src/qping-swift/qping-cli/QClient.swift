//
//  QClient.swift
//  
//
//  Created by Alejandro Garcia on 16/5/23.
//
//
import Foundation
import Network

/// Clase QClient encapsula las funcionalidades de un cliente utilizando el protocolo QUIC con UDP y con TLS
@available(macOS 12, *)
@available(iOS 15, *)
struct QClient {

    /// remote host
    private let host: NWEndpoint.Host
    /// remote port
    private let port: NWEndpoint.Port
    /// Networking queue for receive events
    private let networkQueue: DispatchQueue
    /// Network connection using QUIC
    private let nwConnection: NWConnection
   

    ///Initialize the network connection, creacte DispatchQueue and nwConnection
    init(
        host: String,
        port: UInt16,
        handleClientConnectionStateChanged: @escaping (NWConnection.State) -> Void,
        handleClientReceiveData: @escaping (
            Data?, NWConnection.ContentContext?, Bool?, NWError?
        )  -> Void
    ) {

        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!

        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.networking")

        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros.uno"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = QPing.CONNECTION_TIMEOUT
        let securityProtocolOptions: sec_protocol_options_t = quicOptions
            .securityProtocolOptions
        sec_protocol_options_set_verify_block(
            securityProtocolOptions,
            {
                (
                    _: sec_protocol_metadata_t,
                    _: sec_trust_t,
                    complete: @escaping sec_protocol_verify_complete_t
                ) in
                complete(true)
            },
            networkQueue
        )
        let quicParameter = NWParameters(quic: quicOptions)

        //Network connection
        nwConnection = NWConnection(
            host: self.host,
            port: self.port,
            using: quicParameter
        )

        //handle de cambio de estado
        nwConnection.stateUpdateHandler = handleClientConnectionStateChanged

        //Establecer la funcion de recepción
        nwConnection.receive(
            minimumIncompleteLength: 1,
            maximumLength: QPing.MTU,
            completion: handleClientReceiveData
        )
    }

    ///Start connection of the internal nwConnection
    func startConnection()  {
        //Iniciar conexion
        nwConnection.start(queue: networkQueue)
    }

    /// Stop internal nwConnection
    func stopConnection() {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
    }
    
    ///Return state of the internal nwConnection
    func getConnectionState() -> NWConnection.State {
        return nwConnection.state
    }

    ///Send data using internal nwConnection
    func send(data: Data, completion: @escaping @Sendable (NWError?) -> Void)
    {
        //TODO: Check state
        nwConnection.send(
            content: data,
            completion: .contentProcessed(completion)
        )
    }

    /// Register  handler for data handler reception
    func registerReceiveHandler(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping @Sendable (
            _ content: Data?, _ contentContext: NWConnection.ContentContext?,
            _ isComplete: Bool, _ error: NWError?
        ) -> Void
    ) {
        self.nwConnection.receive(
            minimumIncompleteLength: minimumIncompleteLength,
            maximumLength: maximumLength,
            completion: completion
        )
    }

}
