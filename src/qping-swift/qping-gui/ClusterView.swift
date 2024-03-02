//
//  ClusterView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI


struct ClusterView: View {
    @EnvironmentObject  var appData: AppData
    
   // var selectedCluster: ClusterK8SData?
    
    let step = 100
    let range = 100...1000
    @State var nodes = ["node 1","node 2","node 3"]
   // @State private var isEditing = false
    @State var nodeSelected = "node 1"
   // @State private var myColourIndex = 1
      @State private var myColour = "Green"
    var body: some View {
        
        if let selectedCluster = appData.selectedCluster {
            //   if let isClusterRunning = (appData.clusterRunning != nil) ? true : false {
            
            HStack{
                Text("Cluster: \(selectedCluster.name)").multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                   // .frame(maxWidth: .infinity)
                 
                Picker("Node:", selection:  $nodeSelected) {
                    ForEach(nodes, id: \.self) { colour in
                        Text(colour)
                    }.onAppear(perform: {
                        nodes = [selectedCluster.node1IP,selectedCluster.node2IP,selectedCluster.node3IP]
                        nodeSelected = selectedCluster.node1IP
                    })
                    
                }.padding(EdgeInsets(top: 0.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
                   // .frame(maxWidth: .infinity)
                  
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
                    appData.clusterRunning = ClusterK8S(clusterData: selectedCluster, appData: appData)
                    
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
                
            }.background(Color("backgroundCluster")).cornerRadius(5)//.shadow(color: Color.gray, radius: 3)
               // .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
            
            if appData.runPing && (appData.clusterRunning!.id != selectedCluster.id) {
                Spacer()
                Text("Another cluster running. Please stop it first.")
                Spacer()
            }
            else
            {
                DetailClusterView(cluster: selectedCluster)
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
