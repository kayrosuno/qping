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
    @State var nodes = ["node 1","node 2","node 3"]
    @State var nodeSelected = "node 1"
    let protocols = ["QUIC+UDP", "Only UDP"]
    var body: some View {
        VStack{
            if let selectedCluster = appData.selectedCluster {
#if os(iOS)
                Divider()
                    .overlay(Color.gray)
#endif
                HStack{
                    Picker("Node:", selection:  $nodeSelected) {
                        ForEach(nodes, id: \.self) { colour in
                            Text(colour)
                        }.onAppear(perform: {
                            nodes = [selectedCluster.node1IP,selectedCluster.node2IP,selectedCluster.node3IP]
                            nodeSelected = selectedCluster.node1IP
                        })
                    }
#if os(iOS)
                    .frame(/*idealWidth: 180, maxWidth:200 , */alignment: .leading)
#else
                    .frame(idealWidth: 180, maxWidth:200 , alignment: .leading)
#endif
                    
//#if os(iOS)
                    Spacer()
//#endif
                    Text("Port: \(selectedCluster.port)")
                    //.multilineTextAlignment(.leading)
                    //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        .frame(maxWidth: 93, alignment: .center)
//#if os(iOS)
                    Spacer()
//#endif
                       //Toggle("QUIC/UDP", isOn: $appData.QUIC_UDP)
                        Picker("Protocol:", selection: $appData.selectionProtocol) {
                            ForEach(protocols, id: \.self ) { item  in
                                Text(item)
                            }
                        }
#if os(iOS)
                        .pickerStyle(.automatic)
                        .frame(maxWidth: 93, alignment: .trailing)
#else
                        .pickerStyle(.palette)
                        .frame(maxWidth: 250, alignment: .center)
                    
#endif
                    
                    
                    #if os(macOS)
                    Spacer()
                    #endif
                    
                        
                }//.frame(width: .infinity)
#if os(iOS)
                Divider()
                    .overlay(Color.gray)
          
#endif
                
                if let clusterRunning = appData.clusterRunning {
                    VStack{
                        HStack{
                            
                            Text("Estado: \( (appData.runPing &&  (clusterRunning.id == selectedCluster.id)) ? "Running" : "Stop" )")
                                .multilineTextAlignment(.leading)
                                .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            
                            // .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
                                .frame(width: .infinity, alignment: .leading)
                        }
                            if  clusterRunning.id == selectedCluster.id  {
                                HStack{
                                    Gauge(value: Double(appData.actualRTT.fractionDigitsRounded(to: 0)) ??  0.0, in: clusterRunning.minRTT...clusterRunning.maxRTT+1) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                    } currentValueLabel: {
                                        Text("\(clusterRunning.actualRTT.fractionDigitsRounded(to: 0))")
                                            .foregroundColor(Color.green)
                                    } minimumValueLabel: {
                                        Text("\(clusterRunning.minRTT.fractionDigitsRounded(to: 0))")
                                            .foregroundColor(Color.blue)
                                    } maximumValueLabel: {
                                        Text("\(clusterRunning.maxRTT.fractionDigitsRounded(to: 0))")
                                            .foregroundColor(Color.red)
                                    }
                                    .gaugeStyle(.accessoryCircular)//.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.blue)
                                    Spacer()
                                    Text("min RTT: \(clusterRunning.minRTT.fractionDigitsRounded(to: 0))").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.blue)
                                    Spacer()
                                    Text("desv RTT: \(clusterRunning.medRTT.fractionDigitsRounded(to: 0))").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.green)
                                    Spacer()
                                    Text("max RTT: \(clusterRunning.maxRTT.fractionDigitsRounded(to: 0))").multilineTextAlignment(.leading).padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0)).foregroundColor(.red)
                                    Spacer()
                                }
                                if  appData.runPing
                                {
                                    ProgressView().progressViewStyle(.linear)
                                        .transition(.opacity)
                                        .frame(height: 6)
                                }
                                ScrollView{
                                    //HStack{
                                    ForEach(clusterRunning.qpingOutputNode) { item in
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
                            //                        Button(action: {  //STOP CLUSTER QPing **************************
                            //                            appData.runPing=false
                            //                            // 1. Parar
                            //                            if let cluster = appData.clusterRunning {
                            //                                cluster.stopQPing()
                            //
                            //                            }
                            //                        }  , label: {HStack{
                            //                            Text("Stop")
                            //                            Image(systemName: "stop.fill")}
                            //                        .foregroundColor(Color.red)
                            //                        }
                            //
                            //                        )
                            //                        //.background(Color.red)
                            //                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                            //                        Button(action: {  // RUN CLUSTER QPing *************************
                            //                            appData.runPing = true
                            //
                            //                            //Para cluster anterior
                            //                            if let cluster = appData.clusterRunning {
                            //                                cluster.stopQPing()
                            //                            }
                            //
                            //                            //Crear nuevo cluster
                            //                            appData.clusterRunning = ClusterK8S(clusterData: selectedCluster, appData: appData)
                            //
                            //                            //                    Task {
                            //                            do
                            //                            {
                            //                                //Ejecutar QPing
                            //                                try appData.clusterRunning!.runQPing()
                            //                            }
                            //                            catch
                            //                            {
                            //                                appData.runPing = false
                            //                            }
                            //                            //}
                            //                        }  , label: {HStack{
                            //                            Text("Start")
                            //                            Image(systemName: "play.fill")}
                            //                        .foregroundColor(Color.green)
                            //                        })
                        }
                        Spacer()
                    }
                }
            }
            else
            {
                Text("Cluster undefined")
            }
        
    }
    }
}

//#Preview {
//    @EnvironmentObject  var appData: AppData
//    QPingView( cluster: ClusterK8S(id: UUID(), name: "a", node1IP: "1.1.1.", node2IP: "2.2.2.2", node3IP: "3.3.3.3"))
//}
