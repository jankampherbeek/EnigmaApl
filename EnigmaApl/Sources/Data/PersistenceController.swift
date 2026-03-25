// PersistenceController.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftData
import Foundation

@MainActor
final class PersistenceController {

    static let shared = PersistenceController()

    let container: ModelContainer

    private init() {
        let schema = Schema(versionedSchema: SchemaV1.self)

        // Switch to cloudKitDatabase: .automatic once the iCloud capability is configured in Xcode.
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            container = try ModelContainer(
                for: schema,
                migrationPlan: AppMigrationPlan.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// In-memory container for use in SwiftUI previews and unit tests.
    static var preview: ModelContainer = {
        let schema = Schema([
            HoroscopeModel.self,
            HoroscopeDateTimeModel.self,
            EventModel.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
}
