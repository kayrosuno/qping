//
//  qping_guiApp.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI

@main
struct qping_guiApp: App {
   
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        
        //Otro grupo de ventanas
        WindowGroup("Content") {
            ContentView2()
        }
        
#if os(macOS)
        //Ventana Settings
        Settings() {
            SettingsView()
        }
#endif
    }
}


@Observable
class AppData: Identifiable, ObservableObject {
   
    var showAboutView = false
    var showReloadView = false
    var path: NavigationPath
    var vistaActiva = TipoVistaActiva.root
    var selectedCluster: ClusterK8S?
    var clusters: [ClusterK8S] = [ClusterK8S(id:1,name:"cluster 1",nodes:["nodo_1"],state:1),ClusterK8S(id:2,name:"cluster 2",nodes:["nodo_2"],state:1)]
    //var selectedCluster: Binding<cluster>
    init(path: NavigationPath){
        self.path = path
    }
}


//Clusters/nodes
struct ClusterK8S: Identifiable, Hashable{
    var id: Int
    var name: String
    var nodes: [String]
    var state: Int   //0 Desactivo | 1 Activo
   
}


//Los tipos de VistaActiva
enum TipoVistaActiva
{
    case cluster    //Vista cluster
    case root       //Vista root
    case latency    //Vista latencia
    case bandwith   //Vista BW
    case mtu        //Vista MTU
    
}
