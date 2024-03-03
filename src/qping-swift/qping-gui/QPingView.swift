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
   
    var body: some View {
        if let selectedCluster = appData.selectedCluster {
            if let clusterRunning = appData.clusterRunning {
                VStack{
                
                    HStack{
                        Text("Estado: \( (appData.runPing &&  (clusterRunning.id == selectedCluster.id)) ? "Running" : "Stop" )")
                            .multilineTextAlignment(.leading)
                            .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                         
                        Button(action: {   //Trash
                            if let cluster = appData.clusterRunning {
                                // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                                cluster.resetCounter()
                            }
                            appData.actualRTT = 0.0 // Para resfrescar los datos.
                        }  , label: {Image(systemName: "trash")})
                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 20.0))
                        //.frame(maxWidth: 150)
                        //Spacer()
                        
                        Button(action: {  //STOP CLUSTER QPing **************************
                            appData.runPing=false
                            // 1. Parar
                            if let cluster = appData.clusterRunning {
                                cluster.stopQPing()
                                
                            }
                        }  , label: {HStack{
                            Text("Stop")
                            Image(systemName: "stop.fill")}
                        .foregroundColor(Color.red)
                        }
                               
                        )
                        //.background(Color.red)
                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                        Button(action: {  // RUN CLUSTER QPing *************************
                            appData.runPing = true
                            
                            //Para cluster anterior
                            if let cluster = appData.clusterRunning {
                                cluster.stopQPing()
                            }
                            
                            //Crear nuevo cluster
                            appData.clusterRunning = ClusterK8S(clusterData: selectedCluster, appData: appData)
                            
                            //                    Task {
                            do
                            {
                                //Ejecutar QPing
                                try appData.clusterRunning!.runQPing()
                            }
                            catch
                            {
                                appData.runPing = false
                            }
                            //}
                        }  , label: {HStack{
                            Text("Start")
                            Image(systemName: "play.fill")}
                        .foregroundColor(Color.green)
                        })
                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                          
                    }
                    // .padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 0.0,trailing: 5.0))
                    .frame(width: .infinity, alignment: .leading)
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
                                //.fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
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
                        Button(action: {  //STOP CLUSTER QPing **************************
                            appData.runPing=false
                            // 1. Parar
                            if let cluster = appData.clusterRunning {
                                cluster.stopQPing()
                                
                            }
                        }  , label: {HStack{
                            Text("Stop")
                            Image(systemName: "stop.fill")}
                        .foregroundColor(Color.red)
                        }
                               
                        )
                        //.background(Color.red)
                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                        Button(action: {  // RUN CLUSTER QPing *************************
                            appData.runPing = true
                            
                            //Para cluster anterior
                            if let cluster = appData.clusterRunning {
                                cluster.stopQPing()
                            }
                            
                            //Crear nuevo cluster
                            appData.clusterRunning = ClusterK8S(clusterData: selectedCluster, appData: appData)
                            
                            //                    Task {
                            do
                            {
                                //Ejecutar QPing
                                try appData.clusterRunning!.runQPing()
                            }
                            catch
                            {
                                appData.runPing = false
                            }
                            //}
                        }  , label: {HStack{
                            Text("Start")
                            Image(systemName: "play.fill")}
                        .foregroundColor(Color.green)
                        })
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

//#Preview {
//    @EnvironmentObject  var appData: AppData
//    QPingView( cluster: ClusterK8S(id: UUID(), name: "a", node1IP: "1.1.1.", node2IP: "2.2.2.2", node3IP: "3.3.3.3"))
//}
