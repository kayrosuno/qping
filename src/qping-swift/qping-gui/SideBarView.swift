//
//  SideBarView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI
import SwiftData

struct SideBarView: View {
    @EnvironmentObject  var appData: AppData
    @Environment(\.modelContext) private var modelContext
    @State var showSheetClusterEditor = false
    @State var showingAlertDelete = false
    @State var indexSetToDelete = IndexSet()
    @Query var clusters: [ClusterK8SData]
    
    /// Warning de eliminacion de cluster.
    private func removeCluster(at indexSet: IndexSet) {
        
        showingAlertDelete = true
        indexSetToDelete = indexSet
        
    }
    
//    
//        private func removeCluster(index: Int) {
//        let clusterToDelete = clusters[index]
//        if appData.selectedCluster?.persistentModelID == clusterToDelete.persistentModelID {
//            appData.selectedCluster = nil
//        }
//        modelContext.delete(clusterToDelete)
//    }
    
    
    var body: some View {
        //        ZStack
        //        {
        
        VStack{
            VStack(alignment: .center){
                Image("italtel").padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                Text("qping 5g").padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 10.0,trailing: 0.0))
                // .onAppear() {appData.sidebarbackground = self.background()}
            }
           
                
            
                VStack
                {
                    List(selection: $appData.selectedCluster){
                        Section("Cluster kubernetes / node:")
                        {
                            if(clusters.isEmpty) {
                                Text("no cluster or nodes")
                            }
                            else {
                                ForEach(clusters, id: \.self) { cluster in
                                    NavigationLink(cluster.name, value: cluster.id)
                                    //                            .onTapGesture {
                                    //                                appData.selectedCluster = cluster
                                    //                                //Reset path
                                    //                                if(!appData.path.isEmpty){
                                    //                                    appData.path.removeLast()
                                    //                                }
                                    //                                appData.path.append(appData.selectedCluster.id)
                                    //                            }
                                    
                                        .contextMenu {
                                            Button("Edit "+"\(cluster.name)") {
                                                appData.editCluster = cluster
                                                appData.selectedCluster = cluster
                                                showSheetClusterEditor=true  }
                                            Button("Delete "+"\(cluster.name)") {
                                                appData.editCluster = nil
                                                showingAlertDelete = true
                                                appData.selectedCluster = cluster
                                            }
                                        }
                                }
                                .onDelete(perform: removeCluster)
                                .headerProminence(.increased)
                                
                            }
                        
                    }
                        
                    
                    .listStyle(.sidebar)
                    //            .navigationDestination(for: UUID.self) { uuid in
                    //                Text("Detail with \(uuid)")}
                    
                    
                    
                }
                Spacer()
                    HStack {
                        //3D
    #if canImport(UIKit)
                        MetalViewIOS(tipoRender: .Mesh_1)
    #endif
                        
    #if canImport(AppKit)
                        MetalViewMac(tipoRender: .Mesh_1)
    #endif
                    }
            }
                
            HStack{
                Button(action: {
                    appData.editCluster = nil
                    showSheetClusterEditor = true
                }) {
                    Label("Add cluster", systemImage: "plus.circle")
                }.buttonStyle(.plain)
#if os(iOS)
                    .padding(EdgeInsets(top: 0.0,leading: 25.0,bottom: 0.0,trailing: 0.0))
#else
                    .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 0.0))
                    .frame(alignment: .center)
#endif
                    .sheet(isPresented:  $showSheetClusterEditor){ ClusterEditorView()}
                    .alert("WARNING", isPresented: $showingAlertDelete) {
                        Button("Delete", role: .destructive) {
                            
                            // Handle the deletion if the user push delete button doing a long click or right click
                            if appData.selectedCluster != nil {
                                modelContext.delete(appData.selectedCluster!)
                                
                                //Reset path
                                if(!appData.path.isEmpty){
                                    appData.path.removeLast()
                                }
                                appData.path.append(appData.selectedCluster!.name) //Se pasa el String para que lo muestre el NavigationStack utilizando el .navigationDestination de tipo String
                                
                            }
                            
                            // Handle the deletion if the user do a swipe on the list
                            for index in indexSetToDelete {
                                let clusterToDelete = clusters[index]
                                if appData.selectedCluster?.persistentModelID == clusterToDelete.persistentModelID {
                                    appData.selectedCluster = nil
                                }
                                modelContext.delete(clusterToDelete)
                            }
                            
                            indexSetToDelete = IndexSet() //indexSet vacio
                            
                            
                            
                        }
                        Button("Cancel", role:.cancel) {
                            // Dismiss. do nothing.
                        }
                        
                    }  message: {
                        Text("Are you sure to delete this cluster/node?")
                    }
#if os(iOS)
                Spacer()
                Button(action: {
                    appData.showAboutView = true
                },label: {Image(systemName: "info.circle")})
                .sheet(isPresented: $appData.showAboutView){ AboutView() }
                .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 20.0))
#endif
            }
#if os(macOS)
            .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 5.0,trailing: 0.0))
#endif
            
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    @EnvironmentObject  var appData: AppData
    static var previews: some View {
        SideBarView()
    }
}
