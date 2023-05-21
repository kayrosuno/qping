//
//  main.swift
//  qs1
//
//  Created by Alejandro Garcia on 15/5/23.
//

import Foundation
import Network


///Clase QServer. Escucha por conexiones QUIC.
class QServer{
    let program = "QServer"
    let version = "0.1"
    
    ///port de escucha
    let port: NWEndpoint.Port

    ///Opciones de creación de la conexion
    //private let options: NWParameters

    ///Listener de escucha
    private let listener: NWListener
    
    ///networking queue
    private let networkQueue: DispatchQueue
    
    ///Estado del listener de escucha
    var state: NWListener.State {get{return listener.state}}
    
    ///Tupla de seguimiento de conexiones activas
    private var connectionsByID: [Int: ServerConnection] = [:]
    
    ///Contador de conexiones
    private var nextID: Int = 0
    
    /// init
    init(port: UInt16)
    {
        print("--------------------------------------")
        print(program)
        print(version)
        print("--------------------------------------")
        
        self.port = NWEndpoint.Port(rawValue: port)!
        
        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.networking")
        
        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = 1000 * 60 * 10  //10 min
        let securityProtocolOptions: sec_protocol_options_t = quicOptions.securityProtocolOptions
        sec_protocol_options_set_verify_block(securityProtocolOptions,
                                              { (_: sec_protocol_metadata_t,
                                                 _: sec_trust_t,
                                                 complete: @escaping sec_protocol_verify_complete_t) in
            complete(true)
        }, networkQueue)
        
        //CA
        var identity: SecIdentity?
        let getquery = [kSecClass: kSecClassCertificate,
            kSecAttrLabel: "Apple Development: alejandro.garciad75@icloud.com (A3F723B3BA)",
            kSecReturnRef: true] as NSDictionary

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status != errSecSuccess  {
            // handle error …
            print("Error, certificado no encontrado")
        }
        let certificate = item as! SecCertificate

        let identityStatus = SecIdentityCreateWithCertificate(nil, certificate, &identity)
        if identityStatus != errSecSuccess  {
            // handle error …
            print("Error, certificado no creado")
         }
   
        if let secIdentity = sec_identity_create(identity!) {
                sec_protocol_options_set_min_tls_protocol_version(
                    quicOptions.securityProtocolOptions, .TLSv12)
                sec_protocol_options_set_local_identity(
                    quicOptions.securityProtocolOptions, secIdentity)
        }
        
        let quicParameter = NWParameters(quic: quicOptions)
  
        
        //Inicializa el listener con los parametros de options y el port
        listener = try! NWListener(using: quicParameter, on: self.port)
        
        
    }
    
    /// Start server
    func start() throws
    {
        print("Server starting...")
        listener.stateUpdateHandler = self.stateChanged(to:)
        listener.newConnectionHandler = self.newConnection(_:)
        listener.start(queue: .main)
    }
    
    /// server state changed
    private func stateChanged(to newState: NWListener.State) {
           switch newState {
           case .ready:
               
               //print("Server ready on \(self.listener.debugDescription).")
               if let port = self.listener.port {
                   print("Server ready on port \(port.debugDescription).")
               }
               else
               {
                   print("Server ready")
               }
               
           case .failed(let error):
               print("Server failure, error: \(error.localizedDescription)")
               exit(EXIT_FAILURE)
           case .setup:
               print("Server setting...")
           case .cancelled:
               print("Server cancelled")
           case .waiting(let error):
               print("Server waiting, error: \(error.localizedDescription)")
               
           default:
               break
           }
    }
    
    
    ///Conexion aceptada
    private func newConnection(_ nwConnection: NWConnection) {
  
        let connection = ServerConnection(qServer: self, id: nextID, nwConnection: nwConnection)
        nextID += 1
        
        self.connectionsByID[connection.id] = connection
        
        //Inicia la conexión y envía mensaje de bienvenida
        connection.startConnection()
        connection.send(data: "\(program) \(version) | Welcome you are connection: \(connection.id)".data(using: .utf8)!)
        //print("server did open connection \(connection.id)")
    }
    
    ///Conexión parada. Cambio de estado.
    private  func connectionStopped(_ connection: ServerConnection) {
            connectionsByID.removeValue(forKey: connection.id)
            print("server did close connection \(connection.id)")
    }

    ///Stop el server
    func stop() {
            self.listener.stateUpdateHandler = nil
            self.listener.newConnectionHandler = nil
            self.listener.cancel()
            for connection in self.connectionsByID.values {
                connection.stopConnection()
            }
            connectionsByID.removeAll()
    }
    
    
    ///Broadcast to other clients
    func broadcast(clientId: Int, content: Data) {
        
        for connection in connectionsByID
        {
            //Check is other client
            if connection.key != clientId && connection.value.nwConnection.state == NWConnection.State.ready
            {
                let stringData = "[#\(clientId)] "+String(decoding: content, as: UTF8.self)
                 
                connection.value.nwConnection.send(content: stringData.data(using: .utf8)!,
                                                   completion: .contentProcessed( { error in
                    if let error = error {
                        print("Error sending data to connection \(connection.key): \(error.localizedDescription))")
                    }
                }))
                
            }
        }
    }
    
    
    
    func getSecIdentity() -> SecIdentity? {

        var identity: SecIdentity?
        let getquery = [kSecClass: kSecClassCertificate,
            kSecAttrLabel: "Apple Development: alejandro.garciad75@icloud.com (A3F723B3BA)",
            kSecReturnRef: true] as NSDictionary

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            // handle error …
            return identity
        }
        let certificate = item as! SecCertificate

        let identityStatus = SecIdentityCreateWithCertificate(nil, certificate, &identity)
        guard identityStatus == errSecSuccess else {
            // handle error …
            return identity
        }
        
        return identity
    }
    
}
