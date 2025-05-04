//
//  AppData.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//

import Foundation
import SwiftUI
import SwiftData

///
///Datos de la aplicación GUI, observable.
///
@Observable
class QPingAppData: Identifiable, ObservableObject {
   
    var showAboutView = false
    
    /// Ejecutar qping. Enlazado a los botones stop y start en DetailClusterView
    var runPing = false
    var path: NavigationPath
    var vistaActiva = TipoVistaActiva.root
    
    /// Cluster seleccionado en la pantalla lateral
    var selectedCluster: ClusterK8SData?
    
    /// Cluster que se está editando
    var editCluster: ClusterK8SData?
    
    /// Cluster que esta ejecutándose (running)
    var clusterRunning: ClusterK8S?
    var QUIC_UDP = true
    //var estadoCluster = "Stop"
    //var qpingOutputNode = ""
    var sendInterval = 1000.0 //ms, default 1000ms=1seg
    var sidebarbackground: (any View)?
    var selectionProtocol = "QUIC+UDP"
   // var nodeSelected = ""
    
    //Para visualizar, datos en clusterk8s, el view debe de estar asociado a un objeto observble.
    var actualRTT = 0.0  //Min RTT del cluster
//    var minRTT = 0.0  //Min RTT del cluster
//    var medRTT = 0.0
//    var maxRTT = 100.0  //Max RTT del cluster
//    //var muestras = 100.0  //Max RTT del cluster
    
    /// Time de actualizacon datos del GUI
    var timestamp: String = TimeNow()
    
    init(path: NavigationPath){
        self.path = path
    }
}


extension Formatter {
    static let number = NumberFormatter()
}

extension FloatingPoint {
    func fractionDigitsRounded(to digits: Int, roundingMode:  NumberFormatter.RoundingMode = .halfEven) -> String {
        Formatter.number.roundingMode = roundingMode
        Formatter.number.minimumFractionDigits = digits
        Formatter.number.maximumFractionDigits = digits
        return Formatter.number.string(for:  self) ?? ""
    }
}
