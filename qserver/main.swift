//
//  main.swift
//  qserver
//
//  Created by Alejandro Garcia on 16/5/23.
//

import Foundation


var isServer = false

do
{
    if CommandLine.arguments.count < 2
    {
            uso()
            exit(-1)
    }
    
    
    let firstArgument =  CommandLine.arguments[1]
    switch (firstArgument) {
    case "-l":
        isServer = true
    default:
        break
    }
    
    if isServer {
        if let port = UInt16(CommandLine.arguments[2]) {
            //print("Starting as server on port: \(port)")
            let qserver = QServer(port: port)
            try qserver.start()
            
          
        
            while (true)
            {
                //Thread.sleep(forTimeInterval: TimeInterval(1))
                RunLoop.current.run(until: .now + 30) //segundos
                
                
                //TODO: Chequear estado del listener
                
                // 1. Choose a date
                let today = Date()
                // 2. Pick the date components
                let hours   = (Calendar.current.component(.hour, from: today))
                let minutes = (Calendar.current.component(.minute, from: today))
                let seconds = (Calendar.current.component(.second, from: today))
                // 3. Show the time
                //print("\u{1B}[1A\u{1B}[K\(hours):\(minutes):\(seconds) Server status: \(qserver.state)")
                print("\(hours):\(minutes):\(seconds) Server status: \(qserver.state)")
               // fflush(__stdoutp)
                
            }
            
        } else {
            print("Error invalid port")
        }
    }
}
catch
{
    print("Unexpected error: \(error).\n\n")
}



func uso()
{
    print("Use: qserver -l <port number>")
}
