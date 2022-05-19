//
//  GradeTrackerApp.swift
//  GradeTracker
//
//  Created by Katharine K
//

import SwiftUI

@main
struct GradeTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomePageView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
