//
//  QPingClient.swift
//  qping
//
//  Cliente ping que utiliza QPing
//
//  Created by Alejandro Garcia on 6/2/24.
//

import Foundation
import Network

/// Start a qping client to send data to remote
/// addr: String with external direction in format server:port
/// handle: function handle to receive String with the ping info in string formart. this is similiar to excute on console.
/// handleData: function han
/// dle to receive String with the ping info. Data with the information to plotter.
@available(macOS 12, *)
@available(iOS 15, *)

final class QPingClient: Sendable {

    /// Closure for mensage reception, to pass to GUI
    private var handleClosure: (String) -> Void?

    /// Closure for data reception, to pass to GUI
    private var handleDataClosure: (Double, Double) -> Void?

    /// Remote address to connect
    private var remoteAddr: String

    //Mensaje standar
    private let mensaje = "qping client mensaje"
    private let mensaje_data = "mensaje".data(using: .utf8)

    /// Variable Bucle
    private var loop = true

    // QClient
    private var qclient: QClient?

    // Estado
    private var estado = NWConnection.State.cancelled

    /// Iteracion
    private var id = 1

    /// Time delayed to wait and send for a query in ms
    var delaySend = 1000.0

    /// Init the class with
    /// remoteAddr: the remote address to connect to in format ip:port
    /// sendCommentsTo:    handle to receive string with inforamtion regarding ther state of the connection and the inforamtion of the ping, as executed the client in a terminal
    /// sendDataTo: handle to recive the data of the RTT, first param is time, second delay in ms
    init(
        remoteAddr: String,
        sendCommentsTo handle: @escaping (String) -> Void?,
        sendDataTo handleData: @escaping (Double, Double) -> Void?
    ) {
        handleClosure = handle
        handleDataClosure = handleData
        self.remoteAddr = remoteAddr
    }

    func setDelay(delay: Double) {
        self.delaySend = delay
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

    /// Stop
    func stop() {
        qclient!.stopConnection()

    }

    ///
    /// Run the Q in client mode, start a continuos loop running till finish the connection. Use var loop to false to exit from the loop.
    // @Sendable
    func run() async throws {
        printQ("qping client mode")

        //Split addr en hostname and port
        let addr_split = remoteAddr.split(separator: ":")

        if addr_split.count < 2 {
            throw QError.invalidAddress(error: "invalid address: " + remoteAddr)
        }

        let hostname = String(addr_split[0])

        guard let port = UInt16(addr_split[1]) else {
            throw QError.invalidAddress(error: "invalid port error")
        }

        //Cliente qping
        qclient = QClient(
            host: hostname,
            port: port,
            handleConnectionStateChanged: HandleConnectionStateChanged,
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

    ///Handle estado conexion
    func HandleConnectionStateChanged(to state: NWConnection.State) {
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
                SendData(timeReceive: uptime(), rtt: Double(rtt_time))

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

    /// function to print by console or send to handled
    @Sendable func printQ(_ cadena: String) {
        print(cadena)

        //Closure
        handleClosure(cadena)

        //Closure
        //fhandleDataClosure(cadena)
    }

    /// function to print by console or send to handled
    @Sendable func SendData(timeReceive: Double, rtt: Double) {

        //Closure
        //handleClosure(cadena+"\n")

        //Closure
        handleDataClosure(timeReceive, rtt)
    }
}
