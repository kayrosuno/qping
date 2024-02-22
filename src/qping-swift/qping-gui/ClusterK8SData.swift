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
/// Modelo de datos para swiftdata con la inforamción de los Clusters/nodes
///
@Model
class ClusterK8SData: Identifiable, Hashable{
    @Attribute(.unique) var id: UUID
    var name: String
    var port: String
    var node1IP: String
    var node2IP: String
    var node3IP: String
    
   
    init(id: UUID, name: String, port: String,  node1IP: String, node2IP: String, node3IP: String) {
        self.id = id
        self.name = name
        self.port = port
        self.node1IP = node1IP
        self.node2IP = node2IP
        self.node3IP = node3IP
        
    }
}
