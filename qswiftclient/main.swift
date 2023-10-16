//
//  main.swift
//  qclient
//
//  Created by Alejandro Garcia on 16/5/23.
//



import Foundation
import Network

let hostname: String
let port: UInt16?
let bRun: Bool

do
{
    if CommandLine.arguments.count < 2
    {
        uso()
        exit(-1)
    }
    
    
    //1º hostname
    if CommandLine.arguments.count == 3
    {
        
        hostname = CommandLine.arguments[1]
    
        //2º
        if let port = UInt16(CommandLine.arguments[2]) {
            //print("Starting as server on port: \(port)")
            let qclient = QClient(host: hostname, port: port)
            try await qclient.connect()
            
        
            var bRun = true
//            var loop = 0
     
            var oldState = qclient.getState()
            var newState = qclient.getState()
            while(bRun)
            {
//                loop += 1
                newState = qclient.getState()
                if (newState != oldState){
                    println("#")
                }
                    
                //Check network state
                switch (newState)
                {
                case .cancelled:
                    println("cancelled connection")
                    bRun=false
                    
                case .setup:
                    print("\(TimeNow()) setup connection")
                    
                case .waiting(_):
                    println("waiting connection, reconnecting")
                case .preparing:
                  //  var s:String="."
                    
                    
//                    for _ in 0...loop
//                    {
//                        s = s + "."
//                    }
                    print("\(TimeNow()) preparing connection")
                    
                    //Swift.print("\n\u{1B}[1A\u{1B}[Kpreparaing connection"+s,terminator: "")
                    //fflush(__stdoutp)
                    //print("\u{1B}[1A\u{1B}[Kpreparing connection"+s,terminator: "")
                 
//                    
//                    if loop > 10
//                    {
//                        loop = 0
//                    }

                case .ready:
                    //print("connection ready")
                    //print("\u{1B}[1A\u{1B}[K#",terminator: "")
                    //print("#",terminator: "")
                    //fflush(__stdoutp)
                    if let input = readLine() {
                        qclient.send(data: input.data(using: .utf8)!)
                    }
                    print("#",terminator: "")
                case .failed(_):
                    println("connection failed")
                    bRun=false
                @unknown default:
                    println("connection failed, unknow state")
                }
                    
               oldState = newState
            }
            
            
        } else {
            println("Error invalid port")
        }
    }
    else {
        uso()
    }
}
catch
{
    uso()
}
    
    
    
func uso()
{
    println("Use: qclient <host> <port number>")
}
    
   

