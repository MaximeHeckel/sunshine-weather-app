//
//  sunshineApp.swift
//  sunshine
//
//  Created by Maxime on 11/26/20.
//

import SwiftUI

@main
struct sunshineApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
