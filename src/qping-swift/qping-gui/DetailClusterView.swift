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
  
    @State var nodes = ["node 1","node 2","node 3"]
    @State var nodeSelected = "node 1"
    
#if os(iOS)
    let espaciado = 0.0
#endif
    
#if os(macOS)
    let espaciado = 5.0
#endif
    
    var body: some View {
        if let selectedCluster = appData.selectedCluster {
            HStack{
                Text("Port: \(selectedCluster.port)")
                //.multilineTextAlignment(.leading)
                //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                .frame(maxWidth: 93, alignment: .leading)
                
                Picker("Node:", selection:  $nodeSelected) {
                    ForEach(nodes, id: \.self) { colour in
                        Text(colour)
                    }.onAppear(perform: {
                        nodes = [selectedCluster.node1IP,selectedCluster.node2IP,selectedCluster.node3IP]
                        nodeSelected = selectedCluster.node1IP
                    })
                }
                .frame(idealWidth: 180, maxWidth:200 , alignment: .center)
                
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
                .frame(idealWidth: 90, maxWidth:100 , alignment: .trailing)
#endif
#if os(macOS)
                .frame(idealWidth: 120, maxWidth:180 , alignment: .center)
                .padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: 0.0))
#endif
#if os(macOS)
                Spacer()
#endif
                
         }
#if os(macOS)
            .padding(EdgeInsets(top: 0.0,leading: espaciado,bottom: 0.0,trailing: espaciado))
            #endif
           // .frame(width: .infinity, alignment: .leading)
            
            
            //ProgressView().progressViewStyle(.linear)
            
  
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
}



//#Preview {
//    DetailClusterView()
//}
