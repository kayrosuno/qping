//
//  Latency.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//

import Foundation
import SwiftUI
import SwiftData

///
///Clase QPingTask
///Datos para recoger la latencia
///
struct QPingTask: Hashable
{
    static func == (lhs: QPingTask, rhs: QPingTask) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID = UUID()
    var task: Task<Void, Never>?// Tarea de ejecucion
    
    init(_ task: Task<Void, Never>? ) {
     //   self.cluster = cluster
        self.task = task
      
    }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
}

///
///Clase LatencyPoint
///Un dato concreto de latencia medido por qping
///
struct LatencyPoint: Hashable
{
    static func == (lhs: LatencyPoint, rhs: LatencyPoint) -> Bool {
        return lhs.timeReceived == rhs.timeReceived
    }
    

   // var timeSend: Double = 0.0
    var timeReceived: Double = 0.0
    var delay: Double = 0.0
    
    init( timeReceived: Double, delay: Double) {
        
        self.timeReceived = timeReceived
        self.delay = delay
    }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(timeReceived)
       }
}

