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
    @State private var cluster_name = "cluster"
    @State private var node_ip = "1.1.1.1"
    
    //@State private var selectedCategory: AnimalCategory?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var editorTitle: String {
        appData.editCluster == nil ? "Add Cluster" : "Edit Cluster"
    }
    
    var body: some View {
        //Text("Cluster view detail")
        NavigationStack {
            Form {
                VStack{
                    TextField("Cluster Name:", text: $cluster_name)
                    TextField("Node IP:", text: $node_ip)
                    
                }.padding(EdgeInsets(top: 15.0,leading: 15.0,bottom: 15.0,trailing: 15.0))
            }
            .onAppear {
                
                //Check si editamos o dejamos los valores por defecto
                if let cluster = appData.editCluster {
                    // Edit the incoming cluster
                    cluster_name = cluster.name
                    node_ip = cluster.nodeIP
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
        }//NavigationStack
    }//body
    
    func save() {
        if let cluster = appData.editCluster {
            // Edit the animal.
            cluster.name = cluster_name
            cluster.nodeIP = node_ip
       
            //update!!
            
        } else {
            //Add a new cluster
            let newCluster = ClusterK8S(id: UUID(), name: cluster_name, nodeIP: node_ip, nodes: ["Test"], state: 1)
            modelContext.insert(newCluster)
        }
    }
}//struct

//#Preview {
//    ClusterEditor(cluster: nil)
//}
