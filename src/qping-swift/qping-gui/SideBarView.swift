//
//  SideBarView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject  var appData: AppData
    @State var showSheetAddCluster = false
    
    var body: some View {
        VStack(alignment: .center){
            Image("italtel").padding(EdgeInsets(top: 5.0,leading: 0.0,bottom: 5.0,trailing: 0.0))
            Text("qping 5g").padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 10.0,trailing: 0.0))
        }
        List{
          
//            HStack{
//                Text("Cluster kubernetes / node:").padding(EdgeInsets(top: 0.0,leading: 5.0,bottom: 0.0,trailing: 0.0))
//                Spacer()
//            }
         
            Section("Cluster kubernetes / node:")
            {
                ForEach(appData.clusters) { cluster in
                    NavigationLink(cluster.name, value: cluster.id)
                }
                //                NavigationLink(cluster.name, value: cluster.id)
                //            }.listStyle(.sidebar)
                //                .headerProminence(.increased)
            }
//            List(appData.clusters, selection: $appData.selectedCluster) { cluster in
//                NavigationLink(cluster.name, value: cluster.id)
//            }.listStyle(.sidebar)
//                .headerProminence(.increased)
        }.listStyle(.sidebar)
        .navigationDestination(for: Int.self) { numberValue in
            Text("Detail with \(numberValue)")}
        
        Button(action: {
            showSheetAddCluster=true
        }) {
            Label("Add cluster", systemImage: "plus.circle")
        }.buttonStyle(.plain).padding(5)
            .sheet(isPresented: $showSheetAddCluster){ Text("MODAL !!!!!")}
    }
}

struct SideBarView_Previews: PreviewProvider {
    @EnvironmentObject  var appData: AppData
    static var previews: some View {
        SideBarView()
    }
}
