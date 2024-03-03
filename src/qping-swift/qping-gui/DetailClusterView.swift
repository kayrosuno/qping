//
//  DetailClusterView.swift
//  qping-5g
//
//  Created by Alejandro Garcia on 2/3/24.
//

import SwiftUI

struct DetailClusterView: View {
    
    @EnvironmentObject  var appData: AppData
    
    @State var nodeIP = ""
    @State var QUIC = true
    let step = 100
    let range = 100...1000
  
   
    
#if os(iOS)
    let espaciado = 0.0
#endif
    
#if os(macOS)
    let espaciado = 5.0
#endif
    
    var body: some View {
        if let selectedCluster = appData.selectedCluster {
            HStack{
                
                //#if os(macOS)
                //                .padding(EdgeInsets(top: 0.0,leading: espaciado+2,bottom: 0.0,trailing: espaciado))
                //#endif
                //
                //.frame(maxWidth: .infinity)
                
                //Text("Step:")
                Picker("Step:", selection: $appData.sendInterval) {
                    Text("100 ms").tag(100.0)
                    Text("250 ms").tag(250.0)
                    Text("500 ms").tag(500.0)
                    Text("1 sec").tag(1000.0)
                }
                //.padding(EdgeInsets(top: 0.0,leading: 10.0,bottom: 0.0,trailing: 5.0))
                .onChange(of: appData.sendInterval){
                    if let cluster = appData.clusterRunning {
                        cluster.setDelay(delay: appData.sendInterval)
                    }
                }
#if os(iOS)
                .frame(idealWidth: 90, maxWidth:100 , alignment: .leading)
#endif
                
#if os(macOS)
                .frame(idealWidth: 120, maxWidth:180 , alignment: .leading)
                //.padding(EdgeInsets(top: 0.0,leading: espaciado,bottom: 0.0,trailing: 0.0))
#endif
                
                //#if os(macOS)
                Spacer()
                //#endif
                
                
                // .frame(width: .infinity, alignment: .leading)
                
                
                //ProgressView().progressViewStyle(.linear)
                
                Button(action: {   //Trash
                    if let cluster = appData.clusterRunning {
                        // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                        cluster.resetCounter()
                    }
                    appData.actualRTT = 0.0 // Para resfrescar los datos.
                }  , label: {HStack{
                    Text("Clear")
                    Image(systemName: "trash")}
               // .foregroundColor(Color.green)
                })
                //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                //.frame(maxWidth: 150)
                //Spacer()
#if os(iOS)
            .padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: 0))
#endif
                
                Button(action: {  //STOP CLUSTER QPing **************************
                    appData.runPing=false
                    // 1. Parar
                    if let cluster = appData.clusterRunning {
                        cluster.stopQPing()
                        
                    }
                }  , label: {HStack{
                    Text("Stop")
                    Image(systemName: "stop.fill")}
                .foregroundColor(Color.red)
                })
#if os(iOS)
            .padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: espaciado+15))
#endif
                
                //.background(Color.red)
                //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
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
                }  , label: {HStack{
                    Text("Start")
                    Image(systemName: "play.fill")}
                .foregroundColor(Color.green)
                })
                //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
            }
#if os(macOS)
            .padding(EdgeInsets(top: 0.0,leading: espaciado,bottom: 0.0,trailing: espaciado))
#endif
        }
        TabView {
            QPingView()
            //.badge(2)  // <- globos con el nº :-)
                .tabItem {
                    Label("ping", systemImage: "network")
                }
            ChartNodeView()
            //.badge(2)  // <- globos con el nº :-)
                .tabItem {
                    Label("graph", systemImage: "chart.xyaxis.line")
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
//        .overlay(
//                RoundedRectangle(cornerRadius: 9)
//                    .stroke(Color.accentColor, lineWidth: 2)
//            )
    }
}



//#Preview {
//    DetailClusterView()
//}
