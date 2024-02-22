//
//  ClusterK8S.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//

import Foundation
import SwiftUI
import SwiftData


///
/// Clase ClusterK8
///

class ClusterK8S: Identifiable, Hashable{
    static func == (lhs: ClusterK8S, rhs: ClusterK8S) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID
    var qpingTaskArray: Array<QPingTask> = [QPingTask(nil),QPingTask(nil),QPingTask(nil)]  // 3 nodos max
    var qpingDataNodeArray: Array<String> = ["","",""]// Muestra el ping del primer nodo por ahora solamente. TODO
    var qpingDataLatencyArray: Array<Set> = [Set<LatencyPoint>(),Set(),Set()]         // Tiempo envio, delay
    var minRTT = 0.0  //Min RTT del cluster
    var medRTT = 0.0
    var maxRTT = 0.0  //Max RTT del cluster
    var estadoCluster = "Stop"
    
    init(id: UUID)  //Utilizar el id del cluster en el modelo de datos
    {
        self.id = id
    }

    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
}
