//
//  RTTQUIC.swift
//  qping
//
//  Created by Alejandro on 27/4/25.
//

import Foundation


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
