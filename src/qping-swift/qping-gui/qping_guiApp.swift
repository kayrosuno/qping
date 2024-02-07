//
//  qping_guiApp.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI
import SwiftData

@main
struct qping_guiApp: App {
    //AppData para guardar estado de la aplicacion entre vistas
    @StateObject private var appData = AppData(path: NavigationPath())
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: [
                    ClusterK8S.self
//                    ,
//                    Latency.self,
//                    LatencyPoint.self
                ])
                .environment(appData)
                
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
    var editCluster: ClusterK8S?
    var clusters: [ClusterK8S] = [] // [ClusterK8S(id:1,name:"cluster 1",nodes:["nodo_1"],state:1),ClusterK8S(id:2,name:"cluster 2",nodes:["nodo_2"],state:1)]
    //var selectedCluster: Binding<cluster>
    
    var runPing = false  //Ejecutar el QpingClient
    var qpingTask: Task<Sendable,Error>?
    var sendInterval = 1000.0 //ms, default 1000ms=1seg
    var qpingDataNode1 = ""
    
    init(path: NavigationPath){
        self.path = path
    }
}


//Clusters/nodes
@Model
class ClusterK8S: Identifiable, Hashable{
    @Attribute(.unique) var id: UUID
    var name: String
    var node1IP: String
    var node2IP: String
    var node3IP: String
    //var nodes: [String]
    //var state: Int   //0 Desactivo | 1 Activo
   
    init(id: UUID, name: String, node1IP: String, node2IP: String, node3IP: String) {
        self.id = id
        self.name = name
        self.node1IP = node1IP
        self.node2IP = node2IP
        self.node3IP = node3IP
//        self.nodes = nodes
//        self.state = state
    }
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


//Latencia

class Latency
{
  
    
    @Attribute(.unique) var id: UUID
    var node: String
    var data: Array<LatencyPoint>  //Tiempo envio, delay
  
    init(id: UUID, node: String, data: Array<LatencyPoint>) {
        self.id = id
        self.node = node
        self.data = data
    }
}


class LatencyPoint
{
    var timeSend: Double = 0.0
    var timeReceived: Double = 0.0
    var delay: Double = 0.0
    
    init(timeSend: Double, timeReceived: Double, delay: Double) {
        self.timeSend = timeSend
        self.timeReceived = timeReceived
        self.delay = delay
    }
}
