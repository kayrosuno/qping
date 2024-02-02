//
//  ClusterView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI

struct ClusterView: View {
    var cluster: ClusterK8S?
    
    var body: some View {
        
        if let cluster = cluster {
            Text("Name: \(cluster.name)")
            TabView {
                       View1()
                            .badge(2)
                            .tabItem {
                                Label("Received", systemImage: "tray.and.arrow.down.fill")
                            }
                        View2()
                            .tabItem {
                                Label("Sent", systemImage: "tray.and.arrow.up.fill")
                            }
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
