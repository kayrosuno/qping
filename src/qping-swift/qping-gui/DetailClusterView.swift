//
//  DetailClusterView.swift
//  qping-5g
//
//  Created by Alejandro Garcia on 2/3/24.
//

import SwiftUI

struct DetailClusterView: View {
    
    @EnvironmentObject  var appData: AppData
    
    var cluster: ClusterK8SData
    @State var nodeIP = ""
    @State var QUIC = true
    let step = 100
    let range = 100...1000
    
    var body: some View {
        if let selectedCluster = appData.selectedCluster {
            
            HStack(alignment: .center ){
                //Text("Step:")
                Picker("Step:", selection: $appData.sendInterval) {
                    Text("100 ms").tag(100.0)
                    Text("250 ms").tag(250.0)
                    Text("500 ms").tag(500.0)
                    Text("1 sec").tag(1000.0)
                }  .padding(EdgeInsets(top: 0.0,leading: 10.0,bottom: 0.0,trailing: 5.0))
                    .onChange(of: appData.sendInterval){
                        if let cluster = appData.clusterRunning {
                            cluster.setDelay(delay: appData.sendInterval)
                        }
                    }
                    .frame(maxWidth: 150)
                
                Toggle("QUIC/UDP", isOn: $QUIC)
                Text("Port: \(selectedCluster.port)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                
                
            
                
                // Spacer()
            }.padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 0.0))
            //ProgressView().progressViewStyle(.linear)
            TabView {
                QPingView(selectedCluster: cluster)
                //.badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("ping", systemImage: "network")
                    }
                ChartNodeView(name: cluster.name)
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
}


//#Preview {
//    DetailClusterView()
//}
