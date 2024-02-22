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
    @EnvironmentObject  var appData: AppData
    var cluster: ClusterK8SData?
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    var body: some View {
        if let clusterk8sdata = cluster {
            VStack{
                HStack{
                    Text("Cluster: \(clusterk8sdata.name)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                    Text("Port: \(clusterk8sdata.port)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 20.0,bottom: 5.0,trailing: 5.0))
                    Spacer()
                }.background(Color.accentColor).cornerRadius(10)//.shadow(color: Color.gray, radius: 3)
//                HStack{
//                    
//                    Spacer()
//                }
//                HStack{
//                    Text("Node 1: \(cluster.node1IP)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 50.0))
//                    Spacer()
//                }
//                HStack{
//                    Text("Node 2: \(cluster.node2IP)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 50.0))
//                    Spacer()
//                }
//                HStack{
//                    Text("Node 3: \(cluster.node3IP)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 50.0))
//                    Spacer()
//                }
                
//                Group{
//                    Text("Radio:")
//                    Text("45db RSI")
//                    
//                }
                VStack{
                    HStack{
//                        Text("Estado: \(appData.clusterDictionary[clusterk8sdata.id]?.estadoCluster)").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        Text("Estado: \(appData.runPing ? "Running" : "Stop" )").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        Spacer()
                    }
                    
                    
                    HStack{
                         
                        Gauge(value: Double(appData.actualRTT.fractionDigitsRounded(to: 0)) ??  0.0, in: appData.minRTT...appData.maxRTT) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                } currentValueLabel: {
                                    Text("\(appData.actualRTT.fractionDigitsRounded(to: 0))")
                                        .foregroundColor(Color.green)
                                } minimumValueLabel: {
                                    Text("\(appData.minRTT.fractionDigitsRounded(to: 0))")
                                        .foregroundColor(Color.blue)
                                } maximumValueLabel: {
                                    Text("\(appData.maxRTT.fractionDigitsRounded(to: 0))")
                                        .foregroundColor(Color.red)
                                }
                                .gaugeStyle(.accessoryCircular)//.frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.blue)
                        Spacer()
//                        Gauge(value: 0){Text("min RTT")}.gaugeStyle(.accessoryCircular).foregroundColor(.blue)
//                        Gauge(value: 0){Text("des RTT")}.gaugeStyle(.accessoryCircular).foregroundColor(.green)
//                        Gauge(value: 0){Text("max RTT")}.gaugeStyle(.accessoryCircular).foregroundColor(.red)
                       // VStack{
                            Text("min RTT: \(appData.minRTT.fractionDigitsRounded(to: 1))").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.blue)
                            Spacer()
                            Text("desv RTT: \(appData.medRTT.fractionDigitsRounded(to: 1))").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.green)
                            Spacer()
                            Text("max RTT: \(appData.maxRTT.fractionDigitsRounded(to: 1))").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.red)
                            Spacer()
                      //  }
                    }
                    ScrollView{
                        HStack{
                            //appData.qpingDataNode.append(cadena)
                            
                            Text(appData.qpingDataNode).multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).onAppear{
                                appData.qpingDataNode = appData.clusterDictionary[clusterk8sdata.id]?.qpingDataNodeArray[0] ??  ""
                                
                            }
                            
                            Spacer()
                        }.frame(maxWidth: .infinity)
                    }
                }//.cornerRadius(5).shadow(color: Color.gray, radius: 5)
                
            }
        }
        else
        {
            Text("Cluster undefined")
        }
    }

}

//#Preview {
//    @EnvironmentObject  var appData: AppData
//    QPingView( cluster: ClusterK8S(id: UUID(), name: "a", node1IP: "1.1.1.", node2IP: "2.2.2.2", node3IP: "3.3.3.3"))
//}
