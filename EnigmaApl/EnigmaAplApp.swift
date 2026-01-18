//
//  EnigmaAplApp.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 15/12/2025.
//

import SwiftUI
import SwiftData

@main
struct EnigmaAplApp: App {
    // Create a single SEWrapper instance at app startup for thread-safety
    // Swiss Ephemeris is single-threaded, so we must use one instance throughout the app lifecycle
    private let seWrapper = SEWrapper()
    
    init() {
        // Initialize logging
        Logger.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            Logger.log.error("Could not create ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(seWrapper: seWrapper)
        }
        .modelContainer(sharedModelContainer)
    }
}
