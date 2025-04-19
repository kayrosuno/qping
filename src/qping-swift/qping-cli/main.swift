//
//  main.swift
//  qserver
//
//  Created by Alejandro Garcia on 16/5/23.
//

import Foundation
import Network


let portDefault = "25450"   /// Default port used for qping. 25450
let Program = "qping"       /// Nombre del programa
let Version = "0.3.0"       /// Version actual
let maxMessage = 2024       /// Longitud en bytes maximo del mensaje
let MTU = 65536             /// The UDP maximum package size is 64K 65536
let Max_Lines_QPing = 150   /// Max num of lines to show in GUI interface (really are characters)
var handleClosure: (String) -> Void?  /// Closure for mensage reception, to pass to GUI
//var handleDataClosure: (Double, Double) -> Void? /// Closure for data reception, to pass to GUI
//var remoteAddr: String /// Remote address to connect
let mensaje = "qping client mensaje"  //Mensaje standar
let mensaje_data = "mensaje".data(using: .utf8)
var qclient: QClient?       /// QClient
var qserver: QServer?       /// QServer
var loop = true             /// Variable Bucle
var estado = NWConnection.State.cancelled  ///Estado de xxxxxxxx-
var id = 1                  /// Iteracion
var delaySend = 1000.0      /// Time delayed to wait and send for a query in ms

/// Struct for RTT QUIC. Estructura de mensaje de comunicacion entre cliente y servidor.
struct RTTQUIC: Codable  {
    var Id:                Int = 0      // id del mensaje
    var Time_client:       Int = 0      // local time at client microseconds
    var Time_server:       Int = 0      // local time at server microseconds
    var LenPayload:        Int = 0      // len payload data
    var LenPayloadReaded:  Int = 0      // len data readed on server side for payload (for MTU discovery?)
    var Data:               Data?       // data of payload
}

// Esto es Swift!!  Podemos comenzar desde el principio a escribir el programa!!
// Main
do
{
    if CommandLine.arguments.count < 2  {
        uso()
        exit(-1)
    }
    
    let firstArgument =  CommandLine.arguments[1]
    switch (firstArgument) {
        case "server": //Server mode
            if CommandLine.arguments.count > 2  {
                try serverLoop(serverport: CommandLine.arguments[2])
            } else {
                try serverLoop(serverport: String(portDefault))
            }
              
       
        case "client": //Client mode
        if CommandLine.arguments.count > 2  {
            try await clientLoop(addr: CommandLine.arguments[2])
        } else {
            uso()
        }
        
        case "help": //Help
            help()
        
        default:
            uso()
    }
} catch {
    print("Unexpected error: \(error).\n\n")
}



/// Act as Server. Start the server loop, create a QServer to respond with time to measure rtt time
func serverLoop(serverport: String) throws {

    print("\(TimeNow()) qping server loop")

    guard let port = UInt16(serverport) else {
        throw fatalError("invalid port error")
    }

    print("\(TimeNow()) Starting ping QUIC server on port: \(port)")

    // Iniciar QServer
    qserver = QServer(port: port)
    try qserver!.ListenAddr(
        handleStateChanged: serverStateChanged,
        handleNewConnection: newConnection
    )

    while loop {  //Server espera hasta la finalización, esto hay que hacerlo en bucle porque swift no bloquea las llamadas y no se gestiona con async, utiliza threads y handles con los cambios de estado o lectura de datos. Otra alternativa más tipo go??
        switch qserver!.state {
        case .ready:
            RunLoop.current.run(until: .now + 30)  //segundos

            //TODO: Chequear estado del listener
            print(
                "\(TimeNow()) Server status: \(qserver!.state) ; online clients: \(qserver!.NumConnection())"
            )

        case .cancelled:
            //Server cancelled, exit
            print(
                "\(TimeNow()) Server status: \(qserver!.state) ; online clients: \(qserver!.NumConnection())"
            )
            exit(0)

        case .failed:
            //Server cancelled, exit
            print(
                "\(TimeNow()) Server status: \(qserver!.state) ; online clients: \(qserver!.NumConnection())"
            )
            exit(-1)

        default:
            RunLoop.current.run(until: .now + 1)  //segundos

        }
    }
}


///
/// Run the Q in client mode, start a continuos loop running till finish the connection. Use var loop to false to exit from the loop.
// @Sendable
func clientLoop(addr: String) async throws {

    printQ("qping client loop")

    //Split addr en hostname and port
    let addr_split = addr.split(separator: ":")

    if addr_split.count < 2 {
        throw QError.invalidAddress(error: "invalid address: " + addr)
    }

    let hostname = String(addr_split[0])

    guard let port = UInt16(addr_split[1]) else {
        throw QError.invalidAddress(error: "invalid port error")
    }

    //Cliente qping
    qclient = QClient(
        host: hostname,
        port: port,
        handleConnectionStateChanged: clientHandleConnectionStateChanged,
        handleReceiveData: HandleReceiveData
    )
    //TODO <<<>>> gestionar estado

    //Connect
    if qclient != nil {
        await qclient!.connect()
    }

    //Bucle
    while loop {
        //Check network state
        switch qclient!.getState()
        {
        case .cancelled:

            printQ("\(TimeNow()) cancelled connection")
            break

        case .setup:
            printQ("\(TimeNow()) setup connection")

        case .waiting(_):
            printQ("\(TimeNow()) waiting connection, reconnecting")

        case .preparing:
            printQ("\(TimeNow()) preparing connection")

        case .ready:

            //Fill rtt
            qclient!.rtt.Id = id
            qclient!.rtt.Data = mensaje_data!
            qclient!.rtt.LenPayload = mensaje_data!.count
            qclient!.rtt.Time_client = Int(
                Date().timeIntervalSince1970 * 1000 * 1000
            )
            // Date(
            // rtt.Time_server = Date()
            // rtt.LenPayloadReaded = 0

            //              let decoder = JSONDecoder()
            //              decoder.dateDecodingStrategy = .millisecondsSince1970
            //              let result = try decoder.decode(PointInTime.self, from: Data(json.utf8))
            //              print(result.date) // 2019-10-03 07:34:56 +0000
            //

            qclient!.encoder.dateEncodingStrategy = .millisecondsSince1970

            let json_data = try qclient!.encoder.encode(qclient!.rtt)
            await qclient!.send(data: json_data, completion: sendCompleted)

            id += 1
        //print("\(TimeNow()) id=\(qclient!.rtt.Id) "+String(data: json_data, encoding: .utf8)!)

        case .failed(_):
            printQ("\(TimeNow()) connection failed")
            break

        @unknown default:
            printQ("\(TimeNow()) connection failed, unknow state")
        }

        //Espera delaySend ms
        try await Task.sleep(
            for: .milliseconds(delaySend),
            tolerance: .seconds(0.1)
        )
    }

}

/// SERVER: Handle for server state changed
func serverStateChanged(to newState: NWListener.State) {
    switch newState {
    case .ready:
        print(TimeNow() + " Server ready.")

    case .failed(let error):
        print(
            TimeNow() + " Server failure, error: \(error.localizedDescription)"
        )
        exit(EXIT_FAILURE)

    case .setup:
        print(TimeNow() + " Server setting...")

    case .cancelled:
        print(TimeNow() + " Server cancelled")

    case .waiting(let error):
        print(
            TimeNow() + "Server waiting, error: \(error.localizedDescription)"
        )

    default:
        break
    }
}

///SERVER: Handle for new connection
func newConnection(_ nwConnection: NWConnection) {

    let connection = ServerConnection(
        qServer: qserver!,
        id: qserver!.nextID,
        nwConnection: nwConnection
    )
    qserver!.nextID += 1
    qserver!.connectionsByID[connection.id] = connection
    connection.AcceptStream()  //Acepta la conexión
}


/// Uso
func uso() {
    print("Use: qping client <ipaddress:port>")
    print("Use: qping server <port>")
    print("Use: qping help")
}


/// Help
func help() {
    
    print("qping is a test program written in go and swift to verify the functionality and RTT delay of the QUIC Protocol")
    print("")
    print("Use: qping client <ipaddress:port>")
    print("qping as a ping QUIC client. It requeries a qping Server to ping for, the client use the replies from the server to measure RTT time")
    print("")
    print("Use: qping server <port>")
    print("qping as a ping QUIC Server. qping act as a server listening for querys from the clients answering with a time mark to measure on the client the RTT ")
    print("")
    print("Use: qping help")
    print("This help")
}


#if os(macOS)
///Secure identity
func getSecIdentity() -> SecIdentity? {

    var identity: SecIdentity?
    let getquery = [kSecClass: kSecClassCertificate,
        kSecAttrLabel: "Apple Development: MANUEL ALEJANDRO GARCIA DOMINGUEZ (A3F723B3BA)",
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
#endif

/// function to print by console or send to handled
@Sendable func printQ(_ cadena: String) {
    print(cadena)

    //Closure
    //GUI? handleClosure(cadena)

    //Closure
    //fhandleDataClosure(cadena)
}

/// Obtener el estado del envío
func getState() -> NWConnection.State {
    if qclient != nil {
        estado = qclient!.getState()
    } else {
        return NWConnection.State.cancelled
        // failed(<#T##NWError#>())
    }

    return estado
}

///// Stop
//func stop() {
//    qclient!.stopConnection()
//
//}



///CLIENTE: Handle estado conexion
func clientHandleConnectionStateChanged(to state: NWConnection.State) {
    switch state {
    case .waiting(_):
        //connectionFailed(error: error)
        printQ("* connection waiting state")
    case .failed(let error):
        connectionFailed(error: error)

    default:
        break
    }
}

///Handle receive Data
@Sendable func HandleReceiveData(
    _ content: Data?,
    _ contentContext: NWConnection.ContentContext?,
    _ isComplete: Bool?,
    _ error: NWError?
) {

    //Procesar datos recibidos de la conexión
    if let data = content, !data.isEmpty {
        //TEST let message = String(data: data, encoding: .utf8)
        // TEST print("<< \(message ?? "-")")  /*data: \(data as NSData)*/
        // Swift.print("#",terminator: "")
        //fflush(__stdoutp)
        //self.send(data: data)

        do {
            qclient!.decoder.dateDecodingStrategy = .millisecondsSince1970
            let rtt_result = try qclient!.decoder.decode(
                RTTQUIC.self,
                from: data
            )

            //rtt_result.Time_server = date_received
            //rtt_result.LenPayloadReaded = data.count
            //let data_string =  String(data: data, encoding: .utf8) ?? "null"
            //let rtt_time = Double(round( rtt_result.Time_server!.timeIntervalSince(rtt_result.Time_client!)*1000 )/1000)

            let rtt_time = rtt_result.Time_server - rtt_result.Time_client

            //let rtt_time = Double( rtt_result.Time_server!.timeIntervalSince(rtt_result.Time_client!))

            // let time_send = rtt_result.Time_client
            // let time_received = rtt_result.Time_server

            /* Time_send=\(time_send) Time_receive=\(time_received) */
            let now = TimeNow()
            printQ("\(now) id=\(rtt_result.Id)  RTT=\(rtt_time)us")
            //GUI?? SendData(timeReceive: uptime(), rtt: Double(rtt_time))

        } catch {
            printQ("Unexpected error: \(error).")
        }
    }

    //Conexión completada/finalizada
    if let complete = isComplete, complete == true {
        connectionEnded(error: error)
        return
    }

    //Error en la conexion
    if let error = error {
        connectionFailed(error: error)
        return
    }

    //Registrar de nuevo el handler
    //Establecer handle de recepción
    qclient!.registerReceiveHandler(
        minimumIncompleteLength: 1,
        maximumLength: MTU,
        completion: HandleReceiveData
    )

}

/// Connection failed callback
@Sendable func connectionFailed(error: Error) {

    printQ("connection failed: " + error.localizedDescription)

    //Para loop
    loop = false
}

/// Connection ended callback
@Sendable func connectionEnded(error: Error?) {
    if error != nil {
        printQ("connection ended: " + error!.localizedDescription)
    } else {
        printQ("connection ended")
    }

    //Para loop
    loop = false
}

/// Send  callback
@Sendable func sendCompleted(error: Error?) {
    if error != nil {
        printQ("Send error: " + error!.localizedDescription)
    }
}


//
///// function to print by console or send to handled
//@Sendable func SendData(timeReceive: Double, rtt: Double) {
//
//    //Closure
//    //handleClosure(cadena+"\n")
//
//    //Closure
//    if handleDataClosure != nil {
//        handleDataClosure(timeReceive, rtt)
//    }
//}
