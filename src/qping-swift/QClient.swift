//
//  QClient.swift
//  qs1
//
//  Created by Alejandro Garcia on 16/5/23.
//

import Foundation
import Network

@available(macOS 10.14, *)
class QClient {
    let program = "QClient"
    let version = "0.1"
    ///port de escucha
    let port: NWEndpoint.Port

    //host remoto
    let host: NWEndpoint.Host
    
    ///Opciones de creación de la conexion
    //let options: NWParameters

    ///networking queue
    let networkQueue: DispatchQueue

    ///Network connection
    let nwConnection: NWConnection
    
    ///The TCP maximum package size is 64K 65536
    let MTU = 65536
    
    /// Time out de la conexion
    let CONNECTION_TIMEOUT = 1000 * 60 * 10  //10 min
    
    ///Inittializing
    init(host: String, port: UInt16) {
        
       
        Swift.print("--------------------------------------")
        Swift.print(program)
        Swift.print(version)
        Swift.print("--------------------------------------")
        
        
        
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
        
        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.networking")
        
        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = CONNECTION_TIMEOUT
        let securityProtocolOptions: sec_protocol_options_t = quicOptions.securityProtocolOptions
        sec_protocol_options_set_verify_block(securityProtocolOptions,
                                              { (_: sec_protocol_metadata_t,
                                                 _: sec_trust_t,
                                                 complete: @escaping sec_protocol_verify_complete_t) in
            complete(true)
        }, networkQueue)
        let quicParameter = NWParameters(quic: quicOptions)
  
       
        //Network connection
        nwConnection = NWConnection(host: self.host, port: self.port, using: quicParameter)
        
        
        //handle de cambio de estado
        nwConnection.stateUpdateHandler = self.connectionStateChanged(to:)
        
        //Establecer la funcion de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                           maximumLength: MTU,
                           completion: receiveData)
        
    }

    ///Iniciar conexion
    func connect() async {
        print("[QClient] Connecting to \(host) \(port)")
        nwConnection.start(queue: networkQueue)
       
    }

    ///Return state connection
    func getState() -> NWConnection.State
    {
        return nwConnection.state
    }
    ///Parar conexion
//    func stop() {
//        nwConnection.cancel()
//    }

    ///Cambio estado conexion
    private func connectionStateChanged(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionFailed(error: error)
        case .ready:
            println("[QClient] connection ready")
            //Enviar info de cliente
            send(data: "\(program) \(version)".data(using: .utf8)!)
        case .failed(let error):
            connectionFailed(error: error)
        default:
            break
        }
    }

    ///Receive Data
    ///(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?)
    func receiveData(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool?,
                     _ error: NWError?) {
      
        //Procesar datos recibidos de la conexión
        if let data = content, !data.isEmpty {
            let message = String(data: data, encoding: .utf8)
            println("[QClient] <<< \(message ?? "-")")  /*data: \(data as NSData)*/
            Swift.print("#",terminator: "")
            fflush(__stdoutp)
            //self.send(data: data)
        }
        
        //Conexión completada/finalizada
        if let complete = isComplete, complete==true {
            self.connectionEnded()
            return;
        }
        
        //Error en la conexion
        if let error = error {
            self.connectionFailed(error: error)
            return;
        }
        
        //Registrar de nuevo el handler
        //Establecer handle de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                           maximumLength: MTU,
                           completion: receiveData)
        
    }
    

    ///Enviar datos
    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionFailed(error: error)
                return
            }
                //print("connection did send, data: \(data as NSData)")
        }))
    }


    //Content processed closure
    func didStopCallback(error: Error?) {
        if error == nil {
            exit(EXIT_SUCCESS)
        } else {
            exit(EXIT_FAILURE)
        }
    }
    
    
    //Parar la conexion
    func stopConnection() {
        println("[QClient] Ending connection")
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
    }

    private func connectionFailed(error: Error) {
        println("[QClient] connection did fail, error: \(error)")
        //self.stopConnection()
        exit(-1)
    }

    private func connectionEnded() {
        println("[QClient] connection did end")
        //self.stopConnection()
        exit(-1)
    }

    
    
    
    //Wrapped de print
//    func print(_ cadena: String)
//    {
//        //Swift.print("\n\u{1B}[1A\u{1B}[K"+cadena)
//        fflush(__stdoutp)
//        Swift.print("\n"+cadena)
//        Swift.print("#",terminator: "")
//        fflush(__stdoutp)
//    }
    

}


