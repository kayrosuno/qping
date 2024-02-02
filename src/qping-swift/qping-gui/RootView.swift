//
//  RootView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI

struct RootView: View {
    
    //AppData para guardar estado de la aplicacion entre vistas
    @StateObject private var appData = AppData(path: NavigationPath())
   
    
    var body: some View {
        
        NavigationSplitView {
          SideBarView()
        } detail: {
            NavigationStack(path: $appData.path) {
                ClusterView(cluster: appData.selectedCluster)
            }
           
           
            
        }
        //.environmentObject(appData)
        .environment(appData)
        .sheet(isPresented: $appData.showAboutView){ AboutView() }
        .toolbar{
            ToolbarItem()  //Info
            {
                Button(action: {
                    appData.showAboutView = true
                },label: {Image(systemName: "info.circle")})
            }
        }
        .navigationTitle("QPing")
       
        //        NavigationStack (path: $appData.path) {
        //            //  Lo que se ponga abajo solo se muestra en MAC y en iPAD.  en Iphone NO! , en iOS aparece el sidebar
        //            Text("select cluster/node")
        //                .navigationDestination(for: String.self) { textValue in
        //                    DetailView(text: textValue, path: $appData.path)
        //                }
        //                .navigationDestination(for: Int.self) { numberValue in
        //                    Text("Detail with \(numberValue)")
        //                }
        //                .navigationDestination(for: TipoVistaActiva.self) { tipo in
        //                    switch (tipo)
        //                    {
        //                    case TipoVistaActiva.cluster:
        //                        ClusterView()//.onAppear(){appData.path.removeLast()}
        //
        //                    case TipoVistaActiva.latency:
        //                        LatencyView()//.onAppear(){appData.path.removeLast()}
        //
        //
        //                    default:
        //                        Text("Otro")
        //                    }
        //                }
        //                .navigationTitle("QPing")
        //        }
        
    }
}

//#Preview {
//    
//    RootView()
//}
