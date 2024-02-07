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
    var name: String
    
    var body: some View {
        VStack{
            Text("Detalle de \(name)")
            //SalesOverview()
            
            Chart {
                ForEach(dataPing, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Delay", item.delay),
                        series: .value("Node 1", "A")
                    )
                    .foregroundStyle(.blue)
                }
                //            ForEach(departmentBProfit, id: \.date) { item in
                //                LineMark(
                //                    x: .value("Date", item.date),
                //                    y: .value("Profit B", item.profit),
                //                    series: .value("Company", "B")
                //                )
                //                .foregroundStyle(.green)
                //            }
                RuleMark(
                    y: .value("Threshold", 10)
                )
                .foregroundStyle(.red)
            }
        }
    }
}


struct QpingDelay {
    var date: Double
    var delay: Double

    init(date: Double, delay: Double) {
        self.date = date
        self.delay = delay
    }
}


var dataPing: [QpingDelay] = [
    QpingDelay(date: uptime(), delay: 12.0),
    QpingDelay(date: uptime()+10, delay: 14.0),
    QpingDelay(date: uptime()+20, delay: 12.0),
    QpingDelay(date: uptime()+30, delay: 14.5)
]

#Preview {
    //@EnvironmentObject  var appData: AppData
    ChartNodeView(name: "Nodo 1")
}
