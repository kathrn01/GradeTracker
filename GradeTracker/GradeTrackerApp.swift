//
//  GradeTrackerApp.swift
//  GradeTracker
//
//  Created by Katharine K
//
// This class is the first view the user will see upon opening the app. HomePageView() is displayed, and contains the list of terms created and allows user to add new terms.
//
// ** note: use of scenePhase, .onChange, and saveToPersistence method in Persistence.swift was reference from:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-configure-core-data-to-work-with-swiftui
// as a way to save changes once app is closed or moved to background on device (when user seems to be done using it)
// instead of saving changes every single time a change is made.

import SwiftUI

@main
struct GradeTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            AllTermsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in //this idea was referenced in the link in above comments
            persistenceController.saveToPersistence()
        }
    }
}
