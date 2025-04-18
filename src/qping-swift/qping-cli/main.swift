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
var qserver: QServer?       /// QServer

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
              
        case "help": //Help
            help()
        default:
        let qclient =  QPingClient(remoteAddr: CommandLine.arguments[1],sendCommentsTo: {_ in },sendDataTo: {_,_ in })
        try await qclient.run()
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
        handleStateChanged: stateChanged,
        handleNewConnection: newConnection
    )

    while true {  //Server espera hasta la finalización, esto hay que hacerlo en bucle porque swift no bloquea las llamadas y no se gestiona con async, utiliza threads y handles con los cambios de estado o lectura de datos. Otra alternativa más tipo go??
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

/// Handle for server state changed
func stateChanged(to newState: NWListener.State) {
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

///Handle for new connection
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
    print("Use: qping <ipaddress:port>")
    print("Use: qping server <port>")
    print("Use: qping help")
}


/// Help
func help() {
    
    print("qping is a test program written in go and swift to verify the functionality of the QUIC Protocol")
    print("")
    print("Use: qping <ipaddress:port>")
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

