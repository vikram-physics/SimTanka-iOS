//
//  SimTanka_iOSApp.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 12/12/21.
//

import SwiftUI

@main
struct SimTanka_iOSApp: App {
    
    
   
    
    @StateObject var myTankaUnits = TankaUnits() // user pref for units
    
    @StateObject private var downloadRainModel:DownLoadRainfallNOAA
    
    @StateObject var demandModel:DemandModel
    
    @StateObject private var simTanka:SimTanka
    
    @StateObject private var performancdModel:PerformanceModel
    
    @StateObject private var waterDiaryModel:WaterDiaryModel
    
    init() {
        self.persistenceController = PersistenceController.shared
        
        let rainModel = DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext)
        
        self._downloadRainModel = StateObject(wrappedValue: rainModel)
        
        let simModel = SimTanka(managedObjectContext: persistenceController.container.viewContext)
        
        self._simTanka = StateObject(wrappedValue: simModel)
        
        let demand = DemandModel(managedObjectContext: persistenceController.container.viewContext)
        self._demandModel = StateObject(wrappedValue: demand)
        
        let performance = PerformanceModel(managedObjectContext: persistenceController.container.viewContext)
        self._performancdModel = StateObject(wrappedValue: performance)
        
        let diaryModel = WaterDiaryModel(managedObjectContext: persistenceController.container.viewContext)
        self._waterDiaryModel = StateObject(wrappedValue: diaryModel)
    }
    let persistenceController: PersistenceController

    var body: some Scene {
        WindowGroup {
            //ContentView()
           // SettingUpView()
            StartUpView()
                .environmentObject(myTankaUnits)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(downloadRainModel)
                .environmentObject(simTanka)
                .environmentObject(demandModel)
                .environmentObject(performancdModel)
                .environmentObject(waterDiaryModel)
        }
    }
}
