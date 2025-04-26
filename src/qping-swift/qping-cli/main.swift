//
//  main.swift
//
//
//  Created by Alejandro Garcia on 16/5/23.
//

import Foundation
import Network


/// Struct for RTT QUIC. Estructura de mensaje de comunicacion entre cliente y servidor.
struct RTTQUIC: Codable  {
    /// id del mensaje
    var Id:                Int64 = 0
    
    /// local time at client microseconds
    var Time_client:       Int = 0
    
    /// local time at server microseconds
    var Time_server:       Int = 0
    
    /// len payload data
    var LenPayload:        Int = 0
    
    /// len data readed on server side for payload (for MTU discovery?)
    var LenPayloadReaded:  Int = 0
    
    /// data of payload
    var Data:              Data?
}

///Enum errores
enum QError: Error {
    case invalidAddress(error: String)
    case invalidPort(error: String)
    case generic(error: String)
}

/// QPiong struct containing global parameters and variables.
struct QPing {

    /// Default port used for qping. 25450. Adapated to kubernetes cluster.
    static let portDefault = "25450"
    ///Program name
    static let Program = "qping"
    /// Nombre del programa
    //Version
    static let Version = "0.3.0"
    /// Version actual
    /// Longitud en bytes maximo del mensaje
    static let maxMessage = 2024
    /// The UDP maximum package size is 64K 65536
    static let MTU = 65536
    /// Max num of lines to show in GUI interface (really are characters)
    static let Max_Lines_GUI_QPing = 150
    //var handleClosure: (String) -> Void?  /// Closure for mensage reception, to pass to GUI
    //var handleDataClosure: (Double, Double) -> Void? /// Closure for data reception, to pass to GUI
    //var remoteAddr: String /// Remote address to connect
    /// Default message
    static let mensaje = "qping client mensaje"
    /// Mensaje standar
    static let mensaje_data = "mensaje".data(using: .utf8)
    /// QClient instance
    static var qclient: QClient?
    /// QServer instance
    static var qserver: QServer?
    /// Estado de nwConnection. //TODO: de client or server???
    static var estado = NWConnection.State.cancelled
    /// Time delayed to wait and send for a query in ms
    static let DELAY_LOOP_SERVER_ns: UInt64 = 1000000000 * 10
    /// Time out de la conexion. 1min
    static let CONNECTION_TIMEOUT = 1000 * 60 * 1
    /// 1SEG in nano
    static let DELAY_1SEG_ns: UInt64 = 1000000000
    /// client loop for  conditional exit
    static var clientLoop = true
    ///JSON Encoder
    static let encoder = JSONEncoder()
    ///JSON Decoder
    static let decoder = JSONDecoder()

}

// Esto es Swift!!  Podemos comenzar desde el principio a escribir el programa!!
// Main
do {
    print("\(QPing.Program) \(QPing.Version)")
    if CommandLine.arguments.count < 2 {
        uso()
        exit(-1)
    }

    let firstArgument = CommandLine.arguments[1]
    switch (firstArgument) {
    case "server":  //Server mode
        if CommandLine.arguments.count > 2 {
            try await serverLoop(serverport: CommandLine.arguments[2])
        } else {
            try await serverLoop(serverport: String(QPing.portDefault))
        }

    case "help", "-h":  //Help
        help()

    default:
        if CommandLine.arguments.count > 1 {
            try await clientLoop(addr: CommandLine.arguments[1])
        } else {
            uso()
        }

    }
} catch QError.invalidAddress(let error) {
    print("**ERROR** >> \(error). Please enter a valid address.\n\n")
    uso()
    exit(-1)
} catch QError.invalidPort(let error) {
    print("**ERROR** >> \(error). Please enter a valid port number.\n\n")
    uso()
    exit(-1)
} catch {
    print("Unexpected error: \(error).\n\n")
    uso()
    exit(-1)
}

/// Act as Server. Start the server loop, create a QServer to respond with time to measure rtt time
@MainActor
func serverLoop(serverport: String) async throws {

    print("\(TimeNow()) qping server loop")

    guard let port = UInt16(serverport) else {
        throw QError.invalidPort(
            error: "invalid port error: \(serverport) not valid"
        )
    }

    print("\(TimeNow()) Starting qping QUIC server on port: \(port)")

    // Iniciar QServer
    QPing.qserver = QServer(port: port)
    guard let qserver = QPing.qserver else {
        throw QError.generic(error: "Internal error creating qping server") //TODO: Especificar error. Throw?
    }
        
    try qserver.start(
        handleStateChanged: handleServerStateChanged,
        handleNewConnection: handleNewConnectionInServer
    )

    while true {  //Server espera hasta la finalización, esto hay que hacerlo en bucle porque swift no bloquea las llamadas y no se gestiona con async, utiliza threads y handles con los cambios de estado o lectura de datos. Otra alternativa más tipo go??
        switch qserver.state {
        case .ready:
            // RunLoop.current.run(until: .now + 30)  //segundos
            //Espera delaySend ms
            //try await Task.sleep( for: .milliseconds(QPing.delaySendms), tolerance: .seconds(30)           )
            try await Task.sleep(nanoseconds: QPing.DELAY_LOOP_SERVER_ns)
            
            //TODO: Chequear estado del listener
            print(
                "\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.clientsConnectionsNumber())"
            )

        case .cancelled:
            //Server cancelled, exit
            print(
                "\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.clientsConnectionsNumber())"
            )
            exit(0)

        case .failed:
            //Server cancelled, exit
            print(
                "\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.clientsConnectionsNumber())"
            )
            exit(-1)

        default:
            try await Task.sleep(nanoseconds: QPing.DELAY_1SEG_ns)  //nanosegundos

        }
    }
}


/// CLIENTLOOP: Run the Q in client mode, start a continuos loop running till finish the connection. Use var loop to false to exit from the loop.
// @Sendable
@MainActor
func clientLoop(addr: String) async throws {

    printQ("qping client loop")

    //Split addr en hostname and port
    let addr_split = addr.split(separator: ":")

    if addr_split.count < 2 {
        throw QError.invalidAddress(error: "invalid address: " + addr)
    }

    let hostname = String(addr_split[0])

    guard let port = UInt16(addr_split[1]) else {
        throw QError.invalidPort(error: "invalid port \(addr_split[1])")
    }

    //Cliente qping
    QPing.qclient = QClient(
        host: hostname,
        port: port,
        handleClientConnectionStateChanged: clientHandleConnectionStateChanged,
        handleClientReceiveData: clientHandleReceiveData
    )
    //TODO: <<<>>> gestionar estado
    guard let qclient = QPing.qclient else {
        throw QError.generic(error: "Internal error creating qping client")  //TODO: Especificar error. throw?
    }

    //Connect
    qclient.startConnection()

    //id
    var iteration:Int64 = 0
    
    //Bucle
    while QPing.clientLoop {
        //Check network state
        switch qclient.getConnectionState()
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
            let rtt_data = RTTQUIC(
                Id: iteration,
                Time_client: Int(
                    Date().timeIntervalSince1970 * 1000 * 1000
                ),
                Time_server: 0,
                Data: QPing.mensaje_data!
            )

            QPing.encoder.dateEncodingStrategy = .millisecondsSince1970

            let json_data = try QPing.encoder.encode(rtt_data)
            
            //Send data to qping server
            qclient.send(
                data: json_data,
                completion: clientSendCompleted
            )

            iteration += 1

        case .failed(_):
            printQ("\(TimeNow()) connection failed")
            break

        @unknown default:
            printQ("\(TimeNow()) connection failed, unknow state")
        }

        //Espera delaySend ms
        try await Task.sleep(nanoseconds: QPing.DELAY_1SEG_ns)
//
//            for: .milliseconds(QPing.DELAY_LOOP_SERVER_ns),
//            tolerance: .seconds(0.1)
//        )

    }

}

/// SERVER: Handle for server state changed
func handleServerStateChanged(to newState: NWListener.State) {
    switch newState {
    case .ready:
        print(
            TimeNow()
                + " Server status changed to READY. Waiting for qping clients connections..."
        )

    case .failed(let error):
        print(
            TimeNow() + " Server status changed to FAILED, error: \(error.localizedDescription)"
        )
        exit(EXIT_FAILURE)

    case .setup:
        print(TimeNow() + " Server status changed to SETUP...")

    case .cancelled:
        print(TimeNow() + " Server status changed to CANCELLED")

    case .waiting(let error):
        print(
            TimeNow() + "Server status changed to WAITING, error: \(error.localizedDescription)"
        )

    default:
        break
    }
}

///SERVER: Handle for new connection
func handleNewConnectionInServer(_ nwConnection: NWConnection) {

    guard let qserver = QPing.qserver else {
        //throw QError.generic(error: "Internal error creating qping server") //TODO: Especificar error. Throw?
        print("Internal error 290.")
        exit(-1)
    }
    
    let connection = ClientConnection(
        qServer: qserver,
        id: UUID(),
        nwConnection: nwConnection
    )
    
    qserver.addClientConnection(id: connection.id , connection: connection)
    connection.AcceptStream()  //Acepta la conexión
}

/// Uso
func uso() {
    print("Use: qping <ipaddress:port>")
    print("Use: qping server <port>")
    print("Use: qping help | -h")
}

/// Help
func help() {

    print(
        "qping is a test program written in go and swift to verify the functionality and RTT delay of the QUIC Protocol"
    )
    print("")
    print("Use: qping <ipaddress:port>")
    print(
        "qping as a ping QUIC client. It requeries a qping Server to ping for, the client use the replies from the server to measure RTT time"
    )
    print("")
    print("Use: qping server <port>")
    print(
        "qping as a ping QUIC Server. qping act as a server listening for querys from the clients answering with a time mark to measure on the client the RTT "
    )
    print("")
    print("Use: qping help | -h")
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
    
///GENERAL:  function to print by console or send to handled to GUI
@Sendable func printQ(_ cadena: String) {
    print(cadena)

    //Closure
    //GUI? handleClosure(cadena)

    //Closure
    //fhandleDataClosure(cadena)
}

/// CLIENTE: Obtener el estado del envío. SE USA???? TODO
//func getClientState() -> NWConnection.State {
//    if qclient != nil {
//        estado = qclient!.getState()
//    } else {
//        return NWConnection.State.cancelled
//        // failed(<#T##NWError#>())
//    }
//
//    return estado
//}

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
        printQ("* Client connection state changed to WAITING state")
    case .failed(let error):
        printQ("* Client connection state changed to FAILED state")
        clientConnectionFailed(error: error)

    default:
        break
    }
}

///CLIENTE: Handle receive Data
@Sendable func clientHandleReceiveData(
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
            QPing.decoder.dateDecodingStrategy = .millisecondsSince1970
            let rtt_result = try QPing.decoder.decode(
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
        clientConnectionEnded(error: error)
        return
    }

    //Error en la conexion
    if let error = error {
        clientConnectionFailed(error: error)
        return
    }

    //Registrar de nuevo el handler
    //Establecer handle de recepción
    QPing.qclient!.registerReceiveHandler(
        minimumIncompleteLength: 1,
        maximumLength: QPing.MTU,
        completion: clientHandleReceiveData
    )

}

/// CLIENT: Connection failed callback
@Sendable func clientConnectionFailed(error: Error) {

    printQ("connection failed: " + error.localizedDescription)

    //Para loop
    QPing.clientLoop = false
}

/// CLIENT: Connection ended callback
@Sendable func clientConnectionEnded(error: Error?) {
    if error != nil {
        printQ("connection ended: " + error!.localizedDescription)
    } else {
        printQ("connection ended")
    }

    //Para loop
    QPing.clientLoop = false
}

/// CLIENT: Send  callback.
@Sendable func clientSendCompleted(error: Error?) {
    if error != nil {
        printQ("Send error: " + error!.localizedDescription)
        
        //Para loop
        QPing.clientLoop = false
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
