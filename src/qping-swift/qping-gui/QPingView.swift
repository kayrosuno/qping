//
//  QPingView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 5/2/24.
//

import SwiftUI
import Network

struct QPingView: View {
    @EnvironmentObject  var appData: AppData
    
    var body: some View {
        ScrollView{
            Text(appData.qpingDataNode1)
        }
    }
}

#Preview {
    QPingView()
}
