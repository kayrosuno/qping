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
                switch(qserver.state)
                {
                case .ready:
                    
                    
                    //Thread.sleep(forTimeInterval: TimeInterval(1))
                    RunLoop.current.run(until: .now + 30) //segundos
                    
                    
                    //TODO: Chequear estado del listener
                   
                    // 3. Show the time
                    //print("\u{1B}[1A\u{1B}[K\(hours):\(minutes):\(seconds) Server status: \(qserver.state)")
                    print("\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.NumConnection())")
                    // fflush(__stdoutp)
                    
                default:
                    RunLoop.current.run(until: .now + 1) //segundos
                    
                }
            }
        }
        else {
            print("Error invalid port")
        }
    }
}
catch
{
    print("Unexpected error: \(error).\n\n")
}


// Uso
func uso()
{
    print("Use: qserver -l <port number>")
}
