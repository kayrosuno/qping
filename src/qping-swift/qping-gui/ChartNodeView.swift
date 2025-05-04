//
//  View1.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI
import Charts


struct ChartNodeView: View {
   
    @EnvironmentObject  var qpingAppData: QPingAppData
    
#if os(iOS)
    let espaciado = 0.0
#endif
    
#if os(macOS)
    let espaciado = 5.0
#endif
    
    var body: some View {
        
        if let selectedCluster = qpingAppData.selectedCluster {
            if let clusterRunning = qpingAppData.clusterRunning {
                if clusterRunning.id == selectedCluster.id {
                    VStack{
#if os(iOS)
                Divider()
                    .overlay(Color.gray)
#endif
                        HStack{
                            Text("RTT: \((qpingAppData.actualRTT/1000).fractionDigitsRounded(to: 2)) ms")
                            Spacer()
                            Button(action: {   //Trash
                                if let cluster = qpingAppData.clusterRunning {
                                    // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                                    cluster.resetCounter()
                                }
                                qpingAppData.actualRTT = 0.0 // Para resfrescar los datos.
                            }  , label: {HStack{
                                Text("Clear")
                                Image(systemName: "trash")}
                           // .foregroundColor(Color.green)
                            })
                
            #if os(iOS)
                        //.padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: 0))
                            .frame(maxWidth: 93, alignment: .trailing)
                            .padding(EdgeInsets(top: 7.0,leading: 0.0,bottom: 5.0,trailing: 0))
            #else
                        
                            .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: espaciado))
                            .frame(/*maxWidth: 93,*/ alignment: .trailing)
        //#if os(iOS)
            #endif
                        }
                        Chart {
                            ForEach(clusterRunning.qpingDataChart, id: \.timeReceived) { item in
                                LineMark(
                                    x: .value("Date", item.id),
                                    y: .value("Delay", item.delay/1000) ///1000).fractionDigitsRounded(to: 1))
                                 //   series: .value("Node","A")
                                )
                                .foregroundStyle(.green)
                            }
                               RuleMark(  //Media
                                y: .value("med RTT", clusterRunning.medRTT/1000)
                                )
                               .annotation(position: .bottom,
                                                              alignment: .bottomLeading) {
                                   Text("med RTT \((clusterRunning.medRTT/1000).fractionDigitsRounded(to: 1)) ms").font(.system(size: 12))
                                                  }
                        }
                    }
                }
                else
                {
                    VStack{
#if os(iOS)
                Divider()
                    .overlay(Color.gray)
#endif
                        HStack{
                            Text("RTT: 0us").padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            Spacer()
                            Button(action: {   //Trash
                                if let cluster = qpingAppData.clusterRunning {
                                    // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                                    cluster.resetCounter()
                                }
                                qpingAppData.actualRTT = 0.0 // Para resfrescar los datos.
                            }  , label: {HStack{
                                Text("Clear")
                                Image(systemName: "trash")}
                           // .foregroundColor(Color.green)
                            })
                            //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                            //.frame(maxWidth: 150)
                            //Spacer()
            #if os(iOS)
                        //.padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: 0))
                            .frame(maxWidth: 93, alignment: .trailing)
                            .padding(EdgeInsets(top: 5.0,leading: 0.0,bottom: 5.0,trailing: 0))
            #else
                            .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: espaciado))
                            .frame(/*maxWidth: 93,*/ alignment: .trailing)
        //#if os(iOS)
            #endif
                        }
                        Chart {}
                    }
                }
            }
            else
            {
                //Inicio. Sin nada
                VStack{
#if os(iOS)
                Divider()
                    .overlay(Color.gray)
#endif
                    HStack{
                        Text("RTT: 0us").padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        Spacer()
                        Button(action: {   //Trash
                            if let cluster = qpingAppData.clusterRunning {
                                // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                                cluster.resetCounter()
                            }
                            qpingAppData.actualRTT = 0.0 // Para resfrescar los datos.
                        }  , label: {HStack{
                            Text("Clear")
                            Image(systemName: "trash")}
                       // .foregroundColor(Color.green)
                        })
                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                        //.frame(maxWidth: 150)
                        //Spacer()
#if os(iOS)
                        //.padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: 0))
                        .frame(maxWidth: 93, alignment: .trailing)
                        .padding(EdgeInsets(top: 5.0,leading: 0.0,bottom: 5.0,trailing: 0))
#else
                        
                        .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: espaciado))
                        .frame(/*maxWidth: 93,*/ alignment: .trailing)
#endif
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
