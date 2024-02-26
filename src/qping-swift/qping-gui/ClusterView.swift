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
            
            HStack{
                Text("Cluster: \(clusterk8sdata.name)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                Text("Port: \(clusterk8sdata.port)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 20.0,bottom: 5.0,trailing: 5.0))
                Spacer()
            }.background(Color.accentColor).cornerRadius(10)//.shadow(color: Color.gray, radius: 3)
                .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
            
            HStack(alignment: .center ){
                Text("Step: ")
                    .padding(EdgeInsets(top: 0.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
                Picker("", selection: $appData.sendInterval) {
                    Text("100 ms").tag(100.0)
                    Text("250 ms").tag(250.0)
                    Text("500 ms").tag(500.0)
                    Text("1 sec").tag(1000.0)
                }.onChange(of: appData.sendInterval){
                    if let cluster = appData.clusterRunning {
                        cluster.setDelay(delay: appData.sendInterval)
                    }
                }
#if os(macOS)
                .frame(width: 150)
#endif
                
                Spacer()
                
                if  appData.runPing
                {
                    ProgressView().progressViewStyle(.circular).fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .transition(.opacity).frame(width: 15, height: 15)
                }
                
                Spacer()
                Button(action: {  //STOP CLUSTER QPing **************************
                    appData.runPing=false
                    // 1. Parar
                    if let cluster = appData.clusterRunning {
                        cluster.stopQPing()
                        
                    }
                    
                    
                }  , label: {Image(systemName: "stop.fill")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                Button(action: {  // RUN CLUSTER QPing *************************
                    
                    appData.runPing = true
                    
                    //Para cluster anterior
                    if let cluster = appData.clusterRunning {
                        cluster.stopQPing()
                    }


                    //Crear nuevo cluster
                    appData.clusterRunning = ClusterK8S(clusterData: clusterk8sdata, appData: appData)
                    
//                    Task {
                        do
                        {
                            //Ejecutar QPing
                            try appData.clusterRunning!.runQPing()
                        }
                        catch
                        {
                            appData.runPing = false
                        }
                    //}
                 }  , label: {Image(systemName: "play.fill")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                
                Button(action: {   //Trash
                    if let cluster = appData.clusterRunning {
                       // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                        cluster.resetCounter()
                    }
                    appData.actualRTT = 0.0 // Para resfrescar los datos.
                    
                    
                }  , label: {Image(systemName: "trash")}).padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                
                
                // Spacer()
            }.padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 0.0))
            //ProgressView().progressViewStyle(.linear)
            TabView {
                QPingView(cluster: clusterk8sdata)
                //.badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("ping", systemImage: "network")
                    }
                ChartNodeView(name: clusterk8sdata.name)
                //.badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("graph", systemImage: "xserve")
                    }
                //                ChartNodeView(name: "Node 2")
                //                    .tabItem {
                //                        Label("Node 2", systemImage: "xserve")
                //                    }
                //                ChartNodeView(name: "Node 3")
                //                    .tabItem {
                //                        Label("Node 3", systemImage: "xserve")
                //                    }
            }
        }
        
        else{
            Text("create or select a cluster/node")
        }
    }
}


#Preview {
    ClusterView()
}
