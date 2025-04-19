//
//  Utilidades.swift
//  qs1
//
//  Created by Alejandro Garcia on 12/6/23.
//


import Foundation



/// Devuelve un time en uSec, el tiempo del sistema en uSec. Utilizar para comparar tiempo en usec.
/// El time es la cantidad de tiempo que el sistema esta awake.
/// https://developer.apple.com/forums/thread/101874
/// https://forums.swift.org/t/recommended-way-to-measure-time-in-swift/33326
func uptime()  -> Double
{
    return ProcessInfo.processInfo.systemUptime
}

/// Devuelve el time en HH:mm:ss. Utilizar para formatear tiempo para logs.
func TimeNow() -> String
{
    
    // 1. Choose a date
    let today = Date()
    
    let df = DateFormatter()
   // df.dateFormat = "y-MM-dd H:mm:ss.SSSS"
    df.dateFormat = "H:mm:ss.SSSS"
    
   
    return df.string(from: today)
}


