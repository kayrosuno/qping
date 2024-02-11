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
            HStack{
                Text(appData.qpingDataNode1).multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 50.0))
                Spacer()
            }.frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    QPingView()
}
