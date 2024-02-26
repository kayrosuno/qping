//
//  RootView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject  var appData: AppData
    
    var body: some View {
        
        NavigationSplitView {
            SideBarView()
        } detail: {
            NavigationStack(path: $appData.path) {
                ClusterView(cluster: appData.selectedCluster)
//                Text("***")
              
            }
//            .navigationDestination(for: UUID.self) { selection in
//                //ClusterView(cluster: appData.selectedCluster)
//                Text("AQUI DETALLE CLUSTERVIEW \(selection)")
//            }
                        .navigationDestination(for: String.self) { selection in
                            VStack(alignment: .center, spacing: 20){
                                Text("\(selection) deleted")
                                Text("")
                                Button("OK"){ appData.selectedCluster = nil}
                            }
                            .navigationBarBackButtonHidden()
                        }
            //            .navigationDestination(for: Int.self) { selection in
            //                        Text("AQUI DETALLE CLUSTERVIEW ID \(selection)")
            //            }
        }
        //.environmentObject(appData)
        #if os(macOS)
        .sheet(isPresented: $appData.showAboutView){ AboutView() }
        #endif
        
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
