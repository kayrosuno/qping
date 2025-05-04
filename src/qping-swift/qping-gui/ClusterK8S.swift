//
//  ClusterK8S.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//

import Foundation
import Network
import SwiftData
import SwiftUI

///
/// Clase ClusterK8
///
//@Observable
class ClusterK8S: Identifiable, Hashable {

    static func == (lhs: ClusterK8S, rhs: ClusterK8S) -> Bool {
        return lhs.id == rhs.id
    }
    /// id de identificar único
    let id: UUID
    /// Data ClusterK8SData
    let clusterData: ClusterK8SData
    /// String output
    var qpingDataString = [
        RTTData(string: "", id: 0, timeReceived: uptime(), delay: 0.0)
    ]
    /// qpingData, array de RTTData para chart
    var qpingDataChart = [
        RTTData(string: "", id: 0, timeReceived: uptime(), delay: 0.0)
    ]
    /// Tiempo inicial
    var startTime = uptime()
    /// Min RTT del cluster
    var minRTT = 1000.0
    ///medRTT
    var medRTT = 0.0
    /// Max RTT del cluster
    var maxRTT = 0.0
    /// Last RTT del cluster
    var actualRTT = 0.0
    ///Cluster state, refer to statoe
    var estadoCluster = "Stop"
    /// Delay between send request
    var delayms = 1000.0  //ms
    ///AppData, reference to update swiftUI
    private var appData: QPingAppData?

    /// init ClusterK8S
    init(clusterData: ClusterK8SData, appData: QPingAppData)  //Utilizar el mismo id del cluster que el modelo de datos ClusterK8SData
    {
        self.clusterData = clusterData
        self.id = clusterData.id
        self.appData = appData
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Resetear contadores
    func resetCounter() {
        minRTT = 1000.0
        medRTT = 0.0
        maxRTT = 0.0
        actualRTT = 0.0
        qpingDataChart.removeAll(keepingCapacity: true)
        qpingDataString.removeAll(keepingCapacity: true)
        startTime = 0
    }
}
