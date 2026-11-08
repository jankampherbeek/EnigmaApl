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
        // Tests (unit, integration and UI) never open the database of the user.
        do {
            container = try Self.makeContainer(inMemory: AppEnvironment.usesInMemoryStore)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// Creates a container with the complete schema and migration plan of the app.
    /// Integration tests use `inMemory: true` to get a fresh, empty database.
    static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)

        // Switch to cloudKitDatabase: .automatic once the iCloud capability is configured in Xcode.
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )

        return try ModelContainer(
            for: schema,
            migrationPlan: AppMigrationPlan.self,
            configurations: configuration
        )
    }

    /// In-memory container for use in SwiftUI previews and unit tests.
    static var preview: ModelContainer = {
        let schema = Schema([
            HoroscopeModel.self,
            HoroscopeDateTimeModel.self,
            EventModel.self,
            ResearchProjectModel.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
}
