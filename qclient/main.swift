//
//  main.swift
//  qclient
//
//  Created by Alejandro Garcia on 16/5/23.
//

import Foundation

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
            try qclient.start()
            
        
           bRun = true
            //Read input text to send
            while(bRun)
            {
                //print("\u{1B}[1A\u{1B}[K#",terminator: "")
                print("#",terminator: "")
                //fflush(__stdoutp)
                if let input = readLine() {
                    qclient.send(data: input.data(using: .utf8)!)
                }
               
            }
            
            
        } else {
            print("Error invalid port")
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
    print("Use: qclient <host> <port number>")
}
    
    



