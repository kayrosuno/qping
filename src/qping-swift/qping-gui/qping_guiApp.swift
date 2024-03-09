//
//  qping_guiApp.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//

import SwiftUI
import SwiftData
import CoreTelephony



@main
struct qping_guiApp: App {
    //AppData para guardar estado de la aplicacion entre vistas
    @StateObject private var appData = AppData(path: NavigationPath())
#if os(iOS)
private var info: CTTelephonyNetworkInfo!
#endif

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: [
                    ClusterK8SData.self
                ])
                .environment(appData)
                .preferredColorScheme(.dark)
                .onAppear()
#if os(macOS)
                .frame(minWidth: 1280, minHeight: 800)
#endif
        }
        
        //Otro grupo de ventanas
        WindowGroup("Content") {
            ContentView2()
        }
        
#if os(macOS)
        //Ventana Settings
        Settings() {
            SettingsView()
        }  .environment(appData)
#endif
    }
    
    
//    
//#if os(iOS)
//
//mutating func createObserver() {
//    info = CTTelephonyNetworkInfo();
//    NotificationCenter.default.addObserver(self, selector: "currentAccessTechnologyDidChange",
//                                           name: NSNotification.Name.CTRadioAccessTechnologyDidChange, object: <#Any?#>) //, object: observerObject)
//}
//
//func currentAccessTechnologyDidChange() {
//    if let currentAccess = self.info.currentRadioAccessTechnology {
//        switch currentAccess {
//        case CTRadioAccessTechnologyGPRS:
//            print("GPRS")
//        case CTRadioAccessTechnologyEdge:
//            print("EDGE")
//        case CTRadioAccessTechnologyWCDMA:
//            print("WCDMA")
//        case CTRadioAccessTechnologyHSDPA:
//            print("HSDPA")
//        case CTRadioAccessTechnologyHSUPA:
//            print("HSUPA")
//        case CTRadioAccessTechnologyCDMA1x:
//            print("CDMA1x")
//        case CTRadioAccessTechnologyCDMAEVDORev0:
//            print("CDMAEVDORev0")
//        case CTRadioAccessTechnologyCDMAEVDORevA:
//            print("CDMAEVDORevA")
//        case CTRadioAccessTechnologyCDMAEVDORevB:
//            print("CDMAEVDORevB")
//        case CTRadioAccessTechnologyeHRPD:
//            print("HRPD")
//        case CTRadioAccessTechnologyLTE:
//            print("LTE")
//        default:
//            print("DEF")
//        }
//    } else {
//        print("Current Access technology is NIL")
//    }
//}
//
//#endif

}



//Los tipos de VistaActiva
enum TipoVistaActiva
{
    case cluster    //Vista cluster
    case root       //Vista root
    case latency    //Vista latencia
    case bandwith   //Vista BW
    case mtu        //Vista MTU
    
}
