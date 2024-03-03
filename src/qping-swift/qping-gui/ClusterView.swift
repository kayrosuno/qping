//
//  ClusterView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI


struct ClusterView: View {
    @EnvironmentObject  var appData: AppData
     
    let step = 100
    let range = 100...1000
 
    var body: some View {
        
        if let selectedCluster = appData.selectedCluster {
            //   if let isClusterRunning = (appData.clusterRunning != nil) ? true : false {
            
            HStack{
                Text("Cluster: \(selectedCluster.name)")//.multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 7.0,leading: 5.0,bottom: 7.0,trailing: 5.0))
                // .frame(maxWidth: .infinity)
                //.padding()
                
                Spacer()
                
            }.background(Color("backgroundCluster")).cornerRadius(5)//.shadow(color: Color.gray, radius: 3)
            
            if appData.runPing && (appData.clusterRunning!.id != selectedCluster.id) {
                Spacer()
                Text("Another cluster running. Please stop it first.")
                Spacer()
            }
            else
            {
                DetailClusterView()
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
