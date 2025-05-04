//
//  DetailClusterView.swift
//  qping-5g
//
//  Created by Alejandro Garcia on 2/3/24.
//

import SwiftUI

struct DetailClusterView: View {
    
    @EnvironmentObject  var qpingAppData: QPingAppData
    
    @State var nodeIP = ""
    @State var QUIC = true
    let step = 100
    let range = 100...1000
    @State var nodeSelected = 0
    let protocols = ["QUIC+UDP", "Only UDP"]
    
    
#if os(iOS)
    let espaciado = 0.0
#endif
    
#if os(macOS)
    let espaciado = 5.0
#endif
    
    var body: some View {
        if let selectedCluster = qpingAppData.selectedCluster {
            VStack{
                HStack{
                    HStack{
                        Picker("Node:", selection:  $nodeSelected) {
                            //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                            //                            Text(colour).tag(id)
                            Text("\(selectedCluster.nodes[0])").tag(0)
                            Text("\(selectedCluster.nodes[1])").tag(1)
                            Text("\(selectedCluster.nodes[2])").tag(2)
                            
                        }
                        .onChange(of: nodeSelected) { newValue in
                            qpingAppData.selectedCluster!.nodeSelected = newValue
                        }
                        
#if os(iOS)
                        .frame(/*idealWidth: 180, maxWidth:200 , */alignment: .leading)
#else
                        .frame(idealWidth: 180, maxWidth:200 , alignment: .leading)
                        .padding(EdgeInsets(top: 0.0,leading: espaciado,bottom: 0.0,trailing: 0.0))
#endif
                        
#if os(iOS)
                        Spacer()
#endif
                        Text("Port: \(selectedCluster.port)")
                        //.multilineTextAlignment(.leading)
                        //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            .frame(maxWidth: 93, alignment: .center)
                        
                    } //Stack
                    HStack{
                        //ProgressView().progressViewStyle(.linear)
                        Picker("", selection: $qpingAppData.selectionProtocol) {
                            ForEach(protocols, id: \.self ) { item  in
                                Text(item)
                            }
                        }
#if os(iOS)
                        .pickerStyle(.automatic)
                        .frame(maxWidth: 93, alignment: .leading)
#else
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 250, alignment: .leading)
#endif
                        
                        
                        Picker("Step:", selection: $qpingAppData.sendInterval) {
                            Text("100 ms").tag(100.0)
                            Text("250 ms").tag(250.0)
                            Text("500 ms").tag(500.0)
                            Text("1 sec").tag(1000.0)
                        }
                        //.padding(EdgeInsets(top: 0.0,leading: 10.0,bottom: 0.0,trailing: 5.0))
                        .onChange(of: qpingAppData.sendInterval){
                            if let cluster = qpingAppData.clusterRunning {
                                cluster.delayms = qpingAppData.sendInterval
                                //setDelay(delay: appData.sendInterval)
                            }
                        }
#if os(iOS)
                        .frame(idealWidth: 90, maxWidth:100 , alignment: .leading)
#endif
#if os(macOS)
                        .frame(idealWidth: 120, maxWidth:160 , alignment: .leading)
#endif
                    } //HStack
                    Spacer()
#if os(iOS)
                    //Buttons on iOS, in macos is in title bar, see RootView.
                    Button(action: {  //STOP CLUSTER QPing **************************
                    qpingAppData.runPing=false
                    // 1. Parar
                    if let cluster = qpingAppData.clusterRunning {
                        stopQClientGUI()
                        
                    }
                    //qpingAppData.clusterRunning = nil
                    
                }  , label: {HStack{
                    Text("Stop")
                    Image(systemName: "stop.fill")}
                    .foregroundColor(Color.red)
                    })
                    
                    .padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: espaciado+15))
                    
                    Spacer()
                    
                    //.background(Color.red)
                    //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                    
                    Button(action: {  // RUN CLUSTER QPing *************************
                        qpingAppData.runPing = true
                        
                        //Para cluster anterior
                        if qpingAppData.clusterRunning != nil {
                            // Parar cluster si estaba corriendo?
                            stopQClientGUI()
                        }
                        
                        //Crear nuevo cluster
                        qpingAppData.clusterRunning = ClusterK8S(clusterData: selectedCluster, appData: qpingAppData)
                        
                        do
                        {
                            //Ejecutar QPing
                            //try qpingData.clusterRunning!.runQPing()
                            try  runQClientGUI( appData: qpingAppData )
                        }
                        catch
                        {
                            qpingAppData.runPing = false
                        }
                    }  , label: {HStack{
                        Text("Start")
                        Image(systemName: "play.fill")}
                    .foregroundColor(Color.green)
                    })
                    //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                    .frame( alignment: .leading)
#endif   //BUttons IOS

                
                }
                .padding(EdgeInsets(top: 5.0,leading: espaciado,bottom: 0.0,trailing: 0.0))
                
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
    }
}



//#Preview {
//    DetailClusterView()
//}
