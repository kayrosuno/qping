//
//  RTTData.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//

import Foundation
import SwiftUI
import SwiftData

///
///Class RTTData
///Un dato concreto de latencia medido por qping
///
struct RTTData: Hashable, Identifiable
{
    static func == (lhs: RTTData, rhs: RTTData) -> Bool {
        return lhs.timeReceived == rhs.timeReceived
    }
    
    // var timeSend: Double = 0.0
    var timeReceived: Double = 0.0
    var delay: Double = 0.0
    var string: String = ""
    var id:Int64  = 0
    
    init(string: String, id: Int64, timeReceived: Double, delay: Double) {
        self.string = string
        self.id = id
        self.timeReceived = timeReceived
        self.delay = delay
    }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(timeReceived)
       }
}

