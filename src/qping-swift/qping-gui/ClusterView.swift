//
//  ClusterView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI



      


struct ClusterView: View {
    @EnvironmentObject  var appData: AppData
    
    var cluster: ClusterK8S?
    
    let step = 100
    let range = 100...1000
    @State private var isEditing = false
    
    var body: some View {
        if let cluster = cluster {
            HStack(alignment: .center ){
                Text("Cluster: \(cluster.name)").padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 20.0))
               
                Picker("Speed", selection: $appData.sendInterval) {
                    Text("100 ms").tag(100.0)
                    Text("250 ms").tag(250.0)
                    Text("500 ms").tag(500.0)
                    Text("1000 ms").tag(1000.0)
                    }.frame(width: 150)
                    .clipped()
                Button(action: {
                    appData.runPing=false
                    guard let task = appData.qpingTask
                    else{ return }
                    
                    task.cancel()
                    
                }  , label: {Image(systemName: "stop.fill")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                Button(action: {
                    appData.runPing=true
                    if ( appData.qpingTask == nil) {
                        appData.qpingTask = Task {
                            await RunQPing()
                        }
                    }
                }  , label: {Image(systemName: "play.fill")})
                
               // Spacer()
            }.padding(EdgeInsets(top: 5.0,leading: 0.0,bottom: 0.0,trailing: 0.0))
                   
            TabView {
                QPingView()
                    .badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("ping", systemImage: "network")
                    }
                ChartNodeView(name: "Node 1")
                    .badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("Node 1", systemImage: "xserve")
                    }
                ChartNodeView(name: "Node 2")
                    .tabItem {
                        Label("Node 2", systemImage: "xserve")
                    }
                ChartNodeView(name: "Node 3")
                    .tabItem {
                        Label("Node 3", systemImage: "xserve")
                    }
            }
        }
        else{
            Text("create or select a cluster/node")
        }
    }
    
    
    func RunQPing() async
    {
        
        var qping: QPingClient?
        
        while(true)
        {
            if(!appData.runPing)
            {
                do{
                    //Espera instrucción....
                    try await Task.sleep(for: .seconds(0.5), tolerance: .seconds(0.1))
                }
                catch
                {
                    appData.qpingDataNode1.append("Unexpected error: \(error).\n")
                }
            }
            else { //OK, lanzar ping
                
                guard let node1Address = appData.selectedCluster?.node1IP
                else {appData.qpingDataNode1.append("Error: No node address found.\n") ; break }
                
                qping = QPingClient (addr: node1Address+":25450" ,
                                     {(cadena: String) -> Void in appData.qpingDataNode1.append(cadena) } ,
                                     {(a: Double, b: Double) -> Void in print("Time: \(a), Delay: \(b)") })
                
                do{
                    try await qping!.run()
                }
                catch
                {
                    appData.qpingDataNode1.append("Unexpected error: \(error).\n")
                }
                
            }
        }
    }
}

#Preview {
    ClusterView()
}
