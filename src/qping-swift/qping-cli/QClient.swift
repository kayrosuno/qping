//
//  QClient.swift
//  qs1
//
//  Created by Alejandro Garcia on 16/5/23.
//
//
import Foundation
import Network

/// Clase QClient encapsula las funcionalidades de un cliente utilizando el protocolo QUIC con UDP y con TLS
@available(macOS 12, *)
@available(iOS 15, *)
class QClient {

    private let port: NWEndpoint.Port   /// port de escucha
    private let host: NWEndpoint.Host   /// host remoto
    var rtt: RTTQUIC! = RTTQUIC()       /// RTT struct
    let encoder = JSONEncoder()         /// Encoder JSON
    let decoder = JSONDecoder()         /// Decoder JSON
    private let networkQueue: DispatchQueue /// Networking queue
    private let nwConnection: NWConnection  /// Network connection
    let CONNECTION_TIMEOUT = 1000 * 60 * 10 /// Time out de la conexion. 10min

    ///Inittializing
    init(
        host: String,
        port: UInt16,
        handleConnectionStateChanged: @escaping (NWConnection.State) -> Void,
        handleReceiveData: @escaping (
            Data?, NWConnection.ContentContext?, Bool?, NWError?
        ) -> Void
    ) {

        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!

        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.networking")

        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros.uno"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = CONNECTION_TIMEOUT
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
        nwConnection.stateUpdateHandler = handleConnectionStateChanged

        //Establecer la funcion de recepción
        nwConnection.receive(
            minimumIncompleteLength: 1,
            maximumLength: MTU,
            completion: handleReceiveData
        )
    }

    ///Iniciar conexion
    func connect() async {
        //Iniciar conexion
        nwConnection.start(queue: networkQueue)
    }

    ///Return state connection
    func getState() -> NWConnection.State {
        return nwConnection.state
    }

    ///Enviar datos
    func send(data: Data, completion: @escaping @Sendable (NWError?) -> Void)
        async
    {
        nwConnection.send(
            content: data,
            completion: .contentProcessed(completion)
        )
    }

    /// Parar la conexion
    func stopConnection() {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
    }

    /// Registrar handler de recepción de datos
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
