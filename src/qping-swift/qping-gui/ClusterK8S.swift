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
//@Observable
class ClusterK8S: Identifiable, Hashable{
    
   //@EnvironmentObject  var appData: AppData
    
    static func == (lhs: ClusterK8S, rhs: ClusterK8S) -> Bool {
        return lhs.id == rhs.id
    }
    /// id de identificar único
    var id: UUID
    
    /// Data ClusterK8SData
    private var clusterData: ClusterK8SData
    
    /// qping task reference
    private var task : Task<Void, Error>?
    /// String output
    var qpingOutputNode = [QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
    /// qpingData
    var qpingData = [QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
    /// Tiempo inicial
    private var startTime = uptime()
    /// Min RTT del cluster
    var minRTT = 0.0
    ///medRTT
    var medRTT = 0.0
    /// Max RTT del cluster
    var maxRTT = 0.0
    /// Last RTT del cluster
    var actualRTT = 0.0
    ///Cluster state, refer to statoe
    var estadoCluster = "Stop"
    /// bool for run qping loop
    //var runQPing = true
    /// Client QPing
    var qpingClient: QPingClient?
    /// Delay between send request
    //private var delay = 1000.0
    ///AppData, reference to update swiftUI
    private var appData: AppData?
    
    init(clusterData: ClusterK8SData, appData: AppData)  //Utilizar el mismo id del cluster que el modelo de datos ClusterK8SData
    {
        self.clusterData = clusterData
        self.id = clusterData.id
        self.appData = appData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Set delay between ping request
    func setDelay(delay: Double)
    {
        if let client = qpingClient
        {
            client.setDelay(delay: delay)
        }
    }
    /// Resetear contadores
    func resetCounter()
    {
        minRTT = 0.0
        medRTT = 0.0
        maxRTT = 0.0
        actualRTT = 0.0
        qpingData.removeAll(keepingCapacity: true)
        qpingOutputNode.removeAll(keepingCapacity: true)
        startTime = uptime()
    }
    
    /// Para cliente QPing
    func stopQPing()
    {
        if let c = qpingClient{
         c.stop()
        }
        //resetCounter()
//        guard let t = task else { return }
//        t.cancel()
    }
    
    /// Loop para espera de comando start y para ejecucion de qping en loop
    func runQPing()  throws
    {
        if clusterData.nodes[clusterData.nodeSelected] == ""
        {  qpingOutputNode.append(QPingData(string: "Error: No node address found.\n", timeReceived: uptime(), delay: 0.0)) ; return }
        
        if clusterData.port == ""
        {  qpingOutputNode.append(QPingData(string: "Error: No port found.\n", timeReceived: uptime(), delay: 0.0)) ; return }
        
        //
        // Client QPing
        // ----------------------------------------------------------------------
        //
        
        qpingOutputNode.append(QPingData(string: "Connection to: \(clusterData.nodes[clusterData.nodeSelected])", timeReceived: uptime(), delay: 0.0)) 
    
        qpingClient = QPingClient (remoteAddr: clusterData.nodes[clusterData.nodeSelected]+":"+clusterData.port ,
                                   sendCommentsTo: {(cadena: String) -> Void in
            //appData.clusterRunning[cluster.id]?.qpingDataNodeArray[0].append(cadena)
            
            
            if self.qpingOutputNode.count > Max_Lines_QPing
            {
                self.qpingOutputNode.removeFirst()
            }
            self.qpingOutputNode.append(QPingData(string: cadena, timeReceived: fabs(uptime()), delay: 0.0))
            
        } ,
                                   sendDataTo: {(timeReceived: Double, delay: Double) ->Void in
            
            if fabs(delay) >    self.maxRTT
            {
                self.maxRTT = fabs(delay)
            }
            
            if fabs(delay) <    self.minRTT
            {
                self.minRTT = fabs(delay)
            }
          
            
            self.actualRTT = fabs(delay)
            self.appData!.actualRTT = fabs(delay) //para refrescar el observaable appdata y que refresque la interfaz de SwiftUI
            
            //Añadir dato al array , se corrige el tiempo desde el inicio para trasladarlo a un rango 0..n
            
            self.qpingData.append( QPingData(string: "",timeReceived: timeReceived - self.startTime, delay: fabs(delay)))
            
            let total = self.qpingData.count
            var suma = 0.0
            for e in self.qpingData
            {
                suma = suma + e.delay
            }
            self.medRTT = suma / Double(total)
            
            
        })
        
       
        //Void in print("Time: \(a), Delay: \(b)") })
        qpingClient!.setDelay(delay: self.appData!.sendInterval)
        
        //qpingTask =  qpingTask
        minRTT = 0.0
        medRTT = 0.0
        maxRTT = 0.0
        actualRTT = 0.0
        estadoCluster = "Running"
        qpingData.removeAll(keepingCapacity: true)
        startTime = uptime()
        
        task = Task {
            //Run qpingClient
            do {
                try await qpingClient!.run()
            }
            catch
            {
                if (error is CancellationError)
                {
                    qpingOutputNode.append(QPingData(string: "Closed connection.\n", timeReceived: uptime(), delay: 0.0))
                    throw error
                }
                else
                {
                    qpingOutputNode.append(QPingData(string: "Unexpected error: \(error).\n", timeReceived: uptime(), delay: 0.0))
                    throw error
                }
            }
        }
        
    }
}

