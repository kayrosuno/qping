//
//  Utilidades.swift
//  qs1
//
//  Created by Alejandro Garcia on 12/6/23.
//


import Foundation



//Wrapped de print
func println(_ cadena: String)
{
Swift.print("\n\u{1B}[1A\u{1B}[K"+cadena)
fflush(__stdoutp)
//Swift.print("\n"+cadena)
//Swift.print("#",terminator: "")
//fflush(__stdoutp)
}

//Wrapped de print
func print(_ cadena: String)
{
Swift.print("\u{1B}[1A\u{1B}[K"+cadena)
fflush(__stdoutp)
//Swift.print("\n"+cadena)
//Swift.print("#",terminator: "")
//fflush(__stdoutp)
}



//Devuelve el tiempo del sistema en uSec
func uptime()  -> Double
{
return ProcessInfo.processInfo.systemUptime
}

//Devuelve el time en HH:mm:ss
func TimeNow() -> String
{
    
    // 1. Choose a date
    let today = Date()
    // 2. Pick the date components
    let hours   = (Calendar.current.component(.hour, from: today))
    let minutes = (Calendar.current.component(.minute, from: today))
    let seconds = (Calendar.current.component(.second, from: today))
    
    let sHour = String(hours)
    let sMinutes = String(minutes)
    let sSeconds = String(seconds)
    
    return String(sHour+":"+sMinutes+":"+sSeconds)
}
