//
//  ServerConnection.swift
//  qserver
//
//  Created by Alejandro Garcia on 17/5/23.
//

import Foundation
import Network


/// Conexion al server. Lee los datos enviados por los clientes.
@available(macOS 10.14, *)
class ServerConnection {
  
    /// NWConnection encapsulada
    let nwConnection: NWConnection
    
    /// id interno de conexión
    let id: Int
    
    let qServer: QServer
    
    /// RTT struct
    var rtt: RTTQUIC! = RTTQUIC()
 
    let decoder = JSONDecoder() /// JSONDecoder
    let encoder = JSONEncoder() /// JSONEncoder
    
    ///Init desde NWListener
    init(qServer: QServer, id: Int, nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.id = id
        self.qServer = qServer
    }

    //var didStopCallback: ((Error?) -> Void)? = nil

    ///Iniciar conexión
    func AcceptStream() {
        
        //handle de cambio de estado
        nwConnection.stateUpdateHandler = self.connectionStateChanged(to:)
        
        //Establecer handle de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                           maximumLength: MTU,
                           completion: handleReceiveData)
       
        //Iniciar cola de recepción
        nwConnection.start(queue: .main)
    }
    

    //TODO: sanity check de conexiones, no se eliminan de la tupla de conexiones
    
    ///Cambio estado conexion
    private func connectionStateChanged(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            //connectionFailed(error: error)
            if error != nil {
                print("connection \(id) waiting "+error.localizedDescription)
            } else {
                print("connection \(id) waiting")
            }
//            qServer.connectionsByID.removeValue(forKey: id)
        
        case .ready:
            print("connection \(id) ready")
        
        case .failed(let error):
            connectionFailed(error: error)
//            qServer.connectionsByID.removeValue(forKey: id)
            
        default:
            break
        }
    }


    ///Handle for Receive Data
    ///(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?)
    func handleReceiveData(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool?, _ error: NWError?) {
      
        //Procesar datos recibidos de la conexión
        if let data = content, !data.isEmpty {
           do
           {
               
               let date_received = Date()
               
               decoder.dateDecodingStrategy = .millisecondsSince1970
               var rtt_result = try decoder.decode(RTTQUIC.self, from: data)
               
               rtt_result.Time_server = Int (date_received.timeIntervalSince1970 * 1000 * 1000)
               rtt_result.LenPayloadReaded = data.count
               let data_string =  String(data: data, encoding: .utf8) ?? "null"
               print("\(TimeNow()) connection \(id) << "+data_string)
               
               
               // Send reply
               encoder.dateEncodingStrategy = .millisecondsSince1970
               let reply_data = try encoder.encode(rtt_result)
               self.send(data: reply_data)
              
               //print("\(TimeNow()) id=\(rtt.Id) "+String(data: json_data, encoding: .utf8)!)
               //
               //            let message = String(data: data, encoding: .utf8)
               //            print("\(TimeNow()) <<< connection \(self.id) [\(self.nwConnection.endpoint)] string: \(message ?? "-")")
               //            //self.send(data: data)
               //
               
               //Broadcast to all others client
               //qServer.broadcast(clientId: id, content: data)
               
           } catch {
               print("Unexpected error: \(error).")
           }
        }
        
        //Conexión completada/finalizada
        if let complete = isComplete, complete==true {
            //self.connectionEnded()
            print("\(TimeNow()) connection \(self.id) completed")
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
                           completion: handleReceiveData)
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
    func Close() {
        print("\(TimeNow()) connection \(id) will stop")
    }

    ///Callback conexion fallida
    private func connectionFailed(error: Error) {
        print("\(TimeNow()) connection \(id) did fail, error: \(error)")
        CloseConnection(error: error)
    }

    ///Callback conexion finalizada
    private func connectionEnded() {
        print("\(TimeNow()) connection \(id) did end")
        CloseConnection(error: nil)
    }
    
    ///Parar conexion
    private func CloseConnection(error: Error?) {
        nwConnection.stateUpdateHandler = nil
        nwConnection.forceCancel()
        
        qserver!.connectionsByID[id] = nil
    }
}
