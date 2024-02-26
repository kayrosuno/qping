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
///Class QPing Data
///Un dato concreto de latencia medido por qping
///
struct QPingData: Hashable, Identifiable
{
    static func == (lhs: QPingData, rhs: QPingData) -> Bool {
        return lhs.timeReceived == rhs.timeReceived
    }
    

   // var timeSend: Double = 0.0
    var timeReceived: Double = 0.0
    var delay: Double = 0.0
    var string: String = ""
    var id: Double {timeReceived}
    
    init(string: String, timeReceived: Double, delay: Double) {
        
        self.timeReceived = timeReceived
        self.delay = delay
        self.string = string
    }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(timeReceived)
       }
}

