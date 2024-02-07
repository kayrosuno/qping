//
//  View1.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI


//
//   View para crear o editar cluster. Se edita si el cluster de edición está en la propiedad appData.editCluster, si es nil se añade
//
struct ClusterEditorView: View {
    @EnvironmentObject  var appData: AppData
    @State private var cluster_name = ""
    @State private var node1_ip = ""
    @State private var node2_ip = ""
    @State private var node3_ip = ""
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    private var editorTitle: String {
        appData.editCluster == nil ? "Add Cluster" : "Edit Cluster"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cluster settings:") {
                    VStack{
                        TextField("Cluster Name:", text: $cluster_name)
                        TextField("Node1 IP:", text: $node1_ip)
                        TextField("Node2 IP:", text: $node2_ip)
                        TextField("Node3 IP:", text: $node3_ip)
                        
                    }
#if os(macOS)
                    .padding(EdgeInsets(top: 15.0,leading: 15.0,bottom: 15.0,trailing: 15.0))
#endif
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                //Check si editamos o dejamos los valores por defecto
                if let cluster = appData.editCluster {
                    // Edit the incoming cluster
                    cluster_name = cluster.name
                    node1_ip = cluster.node1IP
                    node2_ip = cluster.node2IP
                    node3_ip = cluster.node3IP
                }
            }
        }
#if os(macOS)
        .frame(width: 400,height: 200,alignment: .leading)
#endif
    }//body
    
    func save() {
        if let cluster = appData.editCluster {
            // Edit the animal.
            cluster.name = cluster_name
            cluster.node1IP = node1_ip
            cluster.node2IP = node2_ip
            cluster.node3IP = node3_ip
            
            //update!!
            
        } else {
            //Add a new cluster
            let newCluster = ClusterK8S(id: UUID(), name: cluster_name, node1IP: node1_ip, node2IP: node2_ip, node3IP: node3_ip)
            modelContext.insert(newCluster)
        }
    }
}//struct

//#Preview {
//    ClusterEditorView()
//}
