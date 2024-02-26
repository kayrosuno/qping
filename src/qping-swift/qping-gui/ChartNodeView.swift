//
//  View1.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
//

import SwiftUI
import Charts

//struct QpingDelay {
//    var date: Double
//    var delay: Double
//
//    init(date: Double, delay: Double) {
//        self.date = date
//        self.delay = delay
//    }
//}
//

//var dataPing: [QPingData]?

//] = [
//    QpingDelay(date: uptime(), delay: 12.0),
//    QpingDelay(date: uptime()+10, delay: 14.0),
//    QpingDelay(date: uptime()+20, delay: 12.0),
//    QpingDelay(date: uptime()+30, delay: 14.5)
//]


struct ChartNodeView: View {
    @EnvironmentObject  var appData: AppData
    var name: String
    
    var body: some View {
        VStack{
            HStack{
                Text("RTT:\(appData.actualRTT.fractionDigitsRounded(to: 0)) us")
                Spacer()
            }
            Chart {
                if let cluster = appData.clusterRunning {
                    ForEach(cluster.qpingData, id: \.timeReceived) { item in
                        LineMark(
                            x: .value("Date", item.timeReceived),
                            y: .value("Delay", item.delay),
                            series: .value("Node 1", "A")
                        )
                        .foregroundStyle(.green)
                    }
                    //   RuleMark(
                    //                    y: .value("Threshold", 10)
                    //                )
                }
            }
        }
    }
}

#Preview {
    //@EnvironmentObject  var appData: AppData
    ChartNodeView(name: "Nodo 1")
}
