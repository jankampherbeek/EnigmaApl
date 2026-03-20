//
//  PersistenceController.swift
//  EnigmaApl
//
//  Prerequisites in Xcode before enabling CloudKit:
//  1. Add the "iCloud" capability to the target (Signing & Capabilities)
//  2. Enable "CloudKit" and create/select a container (e.g. "iCloud.com.yourname.EnigmaApl")
//  3. Add the "Background Modes" capability and check "Remote notifications"
//

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
