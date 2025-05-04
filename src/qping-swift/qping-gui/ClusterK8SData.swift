//
//  ClusterK8SData.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//

import Foundation
import SwiftUI
import SwiftData

///
/// Modelo de datos para swiftdata con la inforamción de los Clusters/nodes
///
@Model
class ClusterK8SData: Identifiable, Hashable{
    @Attribute(.unique) var id: UUID
    var name: String
    var port: UInt16 = 25450 //Default port
    var nodes: [String]
    var nodeSelected = 0 //Default. 1st node
   
    init(id: UUID, name: String, port: UInt16, nodes: [String]) {
        self.id = id
        self.name = name
        self.port = port
        self.nodes = nodes
    }
}
