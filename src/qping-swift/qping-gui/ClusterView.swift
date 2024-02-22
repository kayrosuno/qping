//
//  ClusterView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI


struct ClusterView: View {
    @EnvironmentObject  var appData: AppData
    
    var cluster: ClusterK8SData?
    
    let step = 100
    let range = 100...1000
    @State private var isEditing = false
    
    var body: some View {
        if let clusterk8sdata = cluster {
            HStack(alignment: .center ){
                Text("Step: ")
                    .padding(EdgeInsets(top: 0.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
//                Text("\(Int(appData.sendInterval))")
//                    .foregroundColor(isEditing ? .red : .blue)
//                    .padding(EdgeInsets(top: 0.0,leading: 5.0,bottom: 0.0,trailing: 20.0))

                                Picker("", selection: $appData.sendInterval) {
                                    Text("100 ms").tag(100.0)
                                    Text("250 ms").tag(250.0)
                                    Text("500 ms").tag(500.0)
                                    Text("1 sec").tag(1000.0)
                                    }
                #if os(macOS)
                                .frame(width: 150)
                #endif
                                    .clipped()
                
//                Slider(
//                    value: $appData.sendInterval,
//                    in: 100...1000,
//                    step: 100
//                ){ /*Text("Send interval:")*/}
//            minimumValueLabel:{Text("100ms")}maximumValueLabel: {Text("1s")}
//            onEditingChanged: { editing in
//                isEditing = editing
//            }
                
                
                Spacer()
                
//                if  appData.qpingTaskSet.count > 0
//                {
//                        ProgressView().progressViewStyle(.circular)
//                            .transition(.opacity)
//                }
                
                if  appData.showProgressQPing
                {
                    ProgressView().progressViewStyle(.circular).fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .transition(.opacity).frame(width: 15, height: 15)
                }
                
                
                Spacer()
                Button(action: {
                    appData.runPing=false
                    
                  
                    // Chequear si ya se ha creado un cluster para guardar los datos.
                    // 1. Parar
                    // 2. Vaciar
                    if let clusterk8s = appData.clusterDictionary[clusterk8sdata.id]
                    {
                        for c in clusterk8s.qpingTaskArray
                        {
                            c.task?.cancel()
                        }
                        
                        //vaciar, nuevo arra
                        clusterk8s.qpingTaskArray = Array()
                        
                    }
                    
                    
                    appData.showProgressQPing = false
                                        
                    
                }  , label: {Image(systemName: "stop.fill")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                Button(action: {
                    appData.runPing = true
                    
                  
                    //Check cluster, parar tareas
                    if let clusterk8s = appData.clusterDictionary[clusterk8sdata.id]
                    {
                        for c in clusterk8s.qpingTaskArray
                        {
                            c.task!.cancel()
                        }
                        
                        //vaciar, nuevo array
                        clusterk8s.qpingTaskArray = Array()
                    }
                    else
                    {
                        //Crear cluster
                        appData.clusterDictionary[clusterk8sdata.id] = ClusterK8S(id: clusterk8sdata.id)
                        
                    }
                    
                    
                    //Crear tarea QPingTask
                    let task = Task {await RunQPing(cluster: ClusterK8S(id: clusterk8sdata.id)) } //Tarea QPing
                    let qpingTask = QPingTask(task)
                    
                    
                    appData.clusterDictionary[clusterk8sdata.id]?.qpingTaskArray.insert(qpingTask, at: 0)
                    
                    
                    
                    appData.maxRTT = 100.0
                    appData.medRTT = 0.0
                    appData.minRTT = 0.0
                    appData.actualRTT = 0.0
                    
                    appData.showProgressQPing = true
                    
                }  , label: {Image(systemName: "play.fill")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                
                Button(action: {
                    
                    appData.clusterDictionary[clusterk8sdata.id]?.qpingDataNodeArray[0]=""
                    appData.qpingDataNode=""
                    
                    
                }  , label: {Image(systemName: "trash")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                
                
                // Spacer()
            }.padding(EdgeInsets(top: 15.0,leading: 0.0,bottom: 0.0,trailing: 0.0))
            //ProgressView().progressViewStyle(.linear)
            TabView {
                QPingView(cluster: clusterk8sdata)
                    //.badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("ping", systemImage: "network")
                    }
                ChartNodeView(name: "Node 1")
                    //.badge(2)  // <- globos con el nº :-)
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
    
    /// Loop para espera de comando start y para ejecucion de qping en loop
    func RunQPing(cluster: ClusterK8S) async
    {
        
        var qping: QPingClient?
        var run = true
        
        while(run)
        {
            if(!appData.runPing)
            {
                do{
                    //Espera instrucción....
                    try await Task.sleep(for: .seconds(0.5), tolerance: .seconds(0.1))
                }
                catch
                {
                    appData.clusterDictionary[cluster.id]?.qpingDataNodeArray[0].append("Unexpected error: \(error).\n")
                    break
                }
            }
            else { //OK, lanzar ping
                
                guard let node1Address = appData.selectedCluster?.node1IP
                else {appData.clusterDictionary[cluster.id]?.qpingDataNodeArray[0].append("Error: No node address found.\n") ; break }
                
                
                guard let clusterPort = appData.selectedCluster?.port
                else {appData.clusterDictionary[cluster.id]?.qpingDataNodeArray[0].append("Error: No port found.\n") ; break }
                
                
                // TODO: quitar puerto a fuego y coger de la app
                qping = QPingClient (remoteAddr: node1Address+":"+clusterPort ,
                                     sendCommentsTo: {(cadena: String) -> Void in
                    appData.clusterDictionary[cluster.id]?.qpingDataNodeArray[0].append(cadena)
                    appData.qpingDataNode.append(cadena)
                } ,
                                     sendDataTo: {(timeReceived: Double, delay: Double) ->Void in
                    
                    if delay < appData.clusterDictionary[cluster.id]!.minRTT
                    {
                        appData.clusterDictionary[cluster.id]!.minRTT = delay
                    }
                    if delay > appData.clusterDictionary[cluster.id]!.maxRTT
                    {
                        appData.clusterDictionary[cluster.id]!.maxRTT = delay
                    }
                    
                    if  appData.minRTT == 0 {
                        appData.minRTT = delay
                        appData.clusterDictionary[cluster.id]!.minRTT = delay
                    }
                        
                    if delay < appData.minRTT
                    {
                        appData.minRTT = delay
                    }
                    if delay > appData.maxRTT
                    {
                        appData.maxRTT = delay
                    }
                    
                    appData.actualRTT = delay
                    appData.medRTT = (appData.medRTT + appData.actualRTT)/2
                    
                    
                    //TODO: desv
                    
                    
                    appData.clusterDictionary[cluster.id]?.qpingDataLatencyArray[0].insert(LatencyPoint(timeReceived: timeReceived, delay: delay)) })
                //Void in print("Time: \(a), Delay: \(b)") })
                qping?.delaySend = Int(appData.sendInterval)
                
                do{
                    try await qping!.run()
                }
                catch
                {
                    if (error is CancellationError)
                    {
                        appData.clusterDictionary[cluster.id]?.qpingDataNodeArray[0].append("Closed connection.\n")
                        break
                    }
                    else
                    {
                        appData.clusterDictionary[cluster.id]?.qpingDataNodeArray[0].append("Unexpected error: \(error).\n")
                        break
                    }
                }
                
            }
        }
    }
}

#Preview {
    ClusterView()
}
