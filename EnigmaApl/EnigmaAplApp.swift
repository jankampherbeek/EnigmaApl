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

    @StateObject private var composition: AppComposition

    // Create a single SEWrapper instance at app startup for thread-safety
    // Swiss Ephemeris is single-threaded, so we must use one instance throughout the app lifecycle
    // Stored as a let property to ensure it persists for the entire app lifetime
    private let seWrapper: SEWrapper

    init() {
        // Initialize logging
        Logger.configure()
        // Create SEWrapper in init to ensure it's initialized before body is accessed
        self.seWrapper = SEWrapper()

        // Create ONE AppState and pass it into composition
        let state = AppState()
        _composition = StateObject(wrappedValue: AppComposition(app: state))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(composition)
        }
    }
}
