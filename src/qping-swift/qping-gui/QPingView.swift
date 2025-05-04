//
//  QPingView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 5/2/24.
//

import SwiftUI
import Network
import CoreTelephony



struct QPingView: View {
    @EnvironmentObject  var qpingAppData: QPingAppData
    // @State var nodes = ["node 1","node 2","node 3"]
   
    
    
#if os(iOS)
    let espaciado = 0.0
#endif
    
#if os(macOS)
    let espaciado = 5.0
#endif
    
    var body: some View {
        VStack{
            if let selectedCluster = qpingAppData.selectedCluster {
                
                Spacer()
                
                Button(action: {   //Trash
                    if let cluster = qpingAppData.clusterRunning {
                        // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                        cluster.resetCounter()
                    }
                    //cluster.actualRTT = 0.0 // Para resfrescar los datos.
                }  , label: {HStack{
                    Text("Clear")
                    Image(systemName: "trash")}
                })
                
#if os(iOS)
                //.padding(EdgeInsets(top: 0.0,leading: espaciado+15,bottom: 0.0,trailing: 0))
                .frame(maxWidth: 93, alignment: .trailing)
#else
                
                .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: espaciado))
                .frame(/*maxWidth: 93,*/ alignment: .trailing)
                
#endif
                
                
#if os(iOS)
                Divider()
                    .overlay(Color.gray)
#else
                Divider()
                    .overlay(Color.gray)
                    .padding(EdgeInsets(top: espaciado+3,leading: espaciado,bottom: 5.0,trailing: espaciado))
#endif
                
                if let clusterRunning = qpingAppData.clusterRunning {
                    VStack{
                        Text("\(qpingAppData.timestamp)")
                        if  clusterRunning.id == selectedCluster.id  {
                            HStack{
                                
                                
                                Gauge(value: Double((clusterRunning.actualRTT/1000).fractionDigitsRounded(to: 0)) ??  0.0, in: (clusterRunning.minRTT/1000)...(clusterRunning.maxRTT/1000)+1) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                } currentValueLabel: {
                                    Text("\((clusterRunning.actualRTT/1000).fractionDigitsRounded(to: 0))")
                                        .foregroundColor(Color.green)
                                } minimumValueLabel: {
                                    Text("\((clusterRunning.minRTT/1000).fractionDigitsRounded(to: 0))")
                                        .foregroundColor(Color.blue)
                                } maximumValueLabel: {
                                    Text("\((clusterRunning.maxRTT/1000).fractionDigitsRounded(to: 0))")
                                        .foregroundColor(Color.red)
                                }
                                .frame( alignment: .center)
                                .gaugeStyle(.accessoryCircular)//.frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(EdgeInsets(top: 5.0,leading: espaciado+15.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.blue)
                                
                                
                                Spacer()
                                Text("min RTT: \((clusterRunning.minRTT/1000).fractionDigitsRounded(to: 0)) ms").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.blue)
                                Spacer()
                                Text("med RTT: \((clusterRunning.medRTT/1000).fractionDigitsRounded(to: 0)) ms").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.green)
                                Spacer()
                                Text("max RTT: \((clusterRunning.maxRTT/1000).fractionDigitsRounded(to: 0)) ms").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.red)
                                Spacer()
                            }
                            
                            ScrollView{
                                //HStack{
                                ForEach(clusterRunning.qpingDataString) { item in
                                    HStack{
                                        Text(item.string).multilineTextAlignment(.leading)
                                        // 5.0)).frame(maxWidth: .infinity)
                                        Spacer()
                                    }
                                    .padding(EdgeInsets(top: 0.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
                                    .frame(maxWidth: .infinity)
                                }
                            }.defaultScrollAnchor(.bottom)
                        }
                        else {
                            Spacer()
                        }
                    }
                }
                else{
                    VStack{
                        HStack{
                            Text("Estado: Stop").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            Spacer()
                            
                        }
                        Spacer()
                    }
                }
            }
            //            else
            //            {
            //                Text("Cluster undefined")
            //            }
            
        }
    }
    }

//#Preview {
//    @EnvironmentObject  var appData: AppData
//    QPingView( cluster: ClusterK8S(id: UUID(), name: "a", node1IP: "1.1.1.", node2IP: "2.2.2.2", node3IP: "3.3.3.3"))
//}
