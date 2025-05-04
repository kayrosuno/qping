//
//  RootView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var qpingAppData: QPingAppData

    
//#if os(iOS)
//    let espaciado = 0.0
//#endif
//    
//#if os(macOS)
//    let espaciado = 5.0
//#endif
 
    
    var body: some View {

        NavigationSplitView {
            SideBarView()
        } detail: {
            NavigationStack(path: $qpingAppData.path) {
                ClusterView()
            }
            .navigationDestination(for: String.self) { selection in
                VStack(alignment: .center, spacing: 20) {
                    Text("\(selection) deleted")
                    Text("")
                    Button("OK") { qpingAppData.selectedCluster = nil }
                }
                .navigationBarBackButtonHidden()
            }
        }
        #if os(macOS)
            .sheet(isPresented: $qpingAppData.showAboutView) { AboutView() }
        #endif

        .toolbar {
            ToolbarItem{
                //ProgressBar
                if qpingAppData.runPing {
                    ProgressView()
                        #if os(iOS)
                            .progressViewStyle(.circular)
                        #else
                            .progressViewStyle(.linear)
                            .frame(maxHeight: 5)

                        #endif

                        .transition(.opacity)
//                        .padding(
//                            EdgeInsets(
//                                top: 0.0,
//                                leading: espaciado,
//                                bottom: 0.0,
//                                trailing: espaciado
//                            )
//                        )
                }
                //Spacer()
            }
          
            ToolbarItem{
                Button(action: {  // RUN CLUSTER QPing *************************
                    qpingAppData.runPing = true
                    
                    //Para cluster anterior
                    if qpingAppData.clusterRunning != nil {
                        // Parar cluster si estaba corriendo?
                        stopQClientGUI()
                    }
                    
                    guard let selectedCluster = qpingAppData.selectedCluster else {
                        //Ningun cluster seleccionado.
                        //TODO: popup warning
                        return
                    }
                    //Crear nuevo cluster
                    qpingAppData.clusterRunning = ClusterK8S(clusterData: selectedCluster, appData: qpingAppData)
                    
                    do
                    {
                        //Ejecutar QPing
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
            }
            ToolbarItem {
                Button(action: {  //STOP CLUSTER QPing **************************
                    qpingAppData.runPing=false
                    // 1. Parar
                    if qpingAppData.clusterRunning != nil {
                        stopQClientGUI()
                    }
                    //qpingAppData.clusterRunning = nil
                    
                }  , label: {HStack{
                    Text("Stop")
                    Image(systemName: "stop.fill")}
                .foregroundColor(Color.red)
                })
           
            }
            ToolbarItem {
                Button(
                    action: {
                        qpingAppData.showAboutView = true
                    },
                    label: { Image(systemName: "info.circle") }
                )
            }
           
        }
        .navigationTitle(
            //qpingAppData.selectedCluster?.name ??
            QPing.Program + " "
                + QPing.Version
        )
        // IOS __>    .navigationBarHidden(true)
        .onAppear {
            QPing.qpingAppData = qpingAppData  //Set appData for GUI update
        }
    }
}

//#Preview {
//
//    RootView()
//}
