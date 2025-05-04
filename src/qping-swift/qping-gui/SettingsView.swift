//
//  SettingsView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject  var appData: QPingAppData
    
    let protocols = ["QUIC+UDP", "Only UDP"]
    
    var body: some View {
        Group{
           //Toggle("QUIC/UDP", isOn: $appData.QUIC_UDP)
            Picker("Protocol:", selection: $appData.selectionProtocol) {
                ForEach(protocols, id: \.self ) { item  in
                    Text(item)
                }
            }
            .pickerStyle(.segmented)
            Text("Use QUIC protocol over UDP. Active by default.")
        }
    }
}

#Preview {
    SettingsView()
}
