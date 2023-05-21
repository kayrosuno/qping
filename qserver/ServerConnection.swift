//
//  ServerConnection.swift
//  qserver
//
//  Created by Alejandro Garcia on 17/5/23.
//

import Foundation
import Network

@available(macOS 10.14, *)
class ServerConnection {
    //The TCP maximum package size is 64K 65536
    let MTU = 65536

    
    /// NWConnection encapsulada
    let nwConnection: NWConnection
    
    /// id interno de conexión
    let id: Int
    
    let qServer: QServer

    ///Init desde NWListener 
    init(qServer: QServer, id: Int, nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.id = id
        self.qServer = qServer
    }

    //var didStopCallback: ((Error?) -> Void)? = nil

    ///Iniciar conexiójn
    func startConnection() {
        //print("connection \(id) will start")
        
        //handle de cambio de estado
        nwConnection.stateUpdateHandler = self.connectionStateChanged(to:)
        
        //Establecer handle de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                           maximumLength: MTU,
                           completion: receiveData)
       
        //Iniciar cola de recepción
        nwConnection.start(queue: .main)
    }

    ///Cambio estado conexion
    private func connectionStateChanged(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionFailed(error: error)
        case .ready:
            print("connection \(id) ready")
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
            print("<<< connection \(self.id) [\(self.nwConnection.endpoint)] string: \(message ?? "-")")
            //self.send(data: data)
            
            
            //Broadcast to all others client
            qServer.broadcast(clientId: id, content: data)
        }
        
        //Conexión completada/finalizada
        if let complete = isComplete, complete==true {
            //self.connectionEnded()
            print("connection \(self.id) completed")
            return;
        }
        
        //Error en la conexion
        if let error = error {
            self.connectionFailed(error: error)
            return; //Salimos
        }
        
      
        
        //Registrar de nuevo el handler
        //Establecer handle de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                           maximumLength: MTU,
                           completion: receiveData)
    }

    
    ///Send data
    func send(data: Data) {
        self.nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionFailed(error: error)
                return
            }
            //print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }

    ///Stop connection
    func stopConnection() {
        print("connection \(id) will stop")
    }

    ///Callback conexion fallida
    private func connectionFailed(error: Error) {
        print("connection \(id) did fail, error: \(error)")
        stopConnection(error: error)
    }

    ///Callback conexion finalizada
    private func connectionEnded() {
        print("connection \(id) did end")
        stopConnection(error: nil)
    }
    
    ///Parar conexion
    private func stopConnection(error: Error?) {
        nwConnection.stateUpdateHandler = nil
        nwConnection.forceCancel()
    }
}
