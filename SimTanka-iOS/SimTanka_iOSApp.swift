//
//  SimTanka_iOSApp.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 12/12/21.
//

import SwiftUI

@main
struct SimTanka_iOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
