//
//  View1.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI
import Charts


struct ChartNodeView: View {
   
    @EnvironmentObject  var appData: AppData
    
    var body: some View {
        
        if let selectedCluster = appData.selectedCluster {
            if let clusterRunning = appData.clusterRunning {
                if clusterRunning.id == selectedCluster.id {
                    VStack{
                        HStack{
                            Text("RTT:\(appData.actualRTT.fractionDigitsRounded(to: 0)) us")
                            Spacer()
                        }
                        Chart {
                            
                            ForEach(clusterRunning.qpingData, id: \.timeReceived) { item in
                                LineMark(
                                    x: .value("Date", item.timeReceived),
                                    y: .value("Delay", item.delay),
                                    series: .value("Node 1", "A")
                                )
                                .foregroundStyle(.green)
                            }
                            //   RuleMark(  //TODO: POner la media
                            //                    y: .value("Threshold", 10)
                            //                )
                        }
                        
                    }
                }
                else
                {
                    VStack{
                        HStack{
                            Text("RTT: 0us").padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            Spacer()
                        }
                        Chart {}
                    }
                    
                }
            }
            else
            {
                //Inicio. Sin nada
                VStack{
                    HStack{
                        Text("RTT: 0us").padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        Spacer()
                    }
                    Chart {}
                }
            }
        }
        
    }
}

#Preview {
    //@EnvironmentObject  var appData: AppData
    ChartNodeView()
}
