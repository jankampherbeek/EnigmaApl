// UserConfigurationRepositoryTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import SwiftData
@testable import EnigmaApl

@MainActor
struct UserConfigurationRepositoryTests {

    // MARK: - Helpers

    private func makeRepository() throws -> UserConfigurationRepository {
        let schema = Schema([UserConfiguration.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return UserConfigurationRepository(context: ModelContext(container))
    }

    // MARK: - add

    @Test("add: creates a configuration with the given name")
    func testAddCreatesConfiguration() throws {
        let repo = try makeRepository()
        let config = try repo.add(name: "Western")
        #expect(config.name == "Western")
    }

    @Test("add: first configuration is automatically set as active")
    func testAddFirstIsActive() throws {
        let repo = try makeRepository()
        let config = try repo.add(name: "Western")
        #expect(config.isActive == true)
    }

    @Test("add: second configuration is not automatically set as active")
    func testAddSecondIsNotActive() throws {
        let repo = try makeRepository()
        try repo.add(name: "Western")
        let second = try repo.add(name: "Vedic")
        #expect(second.isActive == false)
    }

    @Test("add: defaults are applied for sub-configs")
    func testAddDefaultSubConfigs() throws {
        let repo = try makeRepository()
        let config = try repo.add(name: "Western")
        #expect(config.calculationConfig.houseSystem == .placidus)
        #expect(config.orbConfig.aspectBaseOrb == 10.0)
    }

    // MARK: - fetchAll

    @Test("fetchAll: returns all configurations sorted by name")
    func testFetchAllSortedByName() throws {
        let repo = try makeRepository()
        try repo.add(name: "Uranian")
        try repo.add(name: "Vedic")
        try repo.add(name: "Western")
        let all = try repo.fetchAll()
        #expect(all.count == 3)
        #expect(all.map(\.name) == ["Uranian", "Vedic", "Western"])
    }

    @Test("fetchAll: returns empty array when no configurations exist")
    func testFetchAllEmpty() throws {
        let repo = try makeRepository()
        let all = try repo.fetchAll()
        #expect(all.isEmpty)
    }

    // MARK: - fetchActive

    @Test("fetchActive: returns the active configuration")
    func testFetchActive() throws {
        let repo = try makeRepository()
        try repo.add(name: "Western")
        let active = try repo.fetchActive()
        #expect(active?.name == "Western")
    }

    @Test("fetchActive: returns nil when no configuration is active")
    func testFetchActiveNil() throws {
        let repo = try makeRepository()
        let active = try repo.fetchActive()
        #expect(active == nil)
    }

    // MARK: - setActive

    @Test("setActive: makes the given configuration active")
    func testSetActive() throws {
        let repo = try makeRepository()
        try repo.add(name: "Western")
        let vedic = try repo.add(name: "Vedic")
        try repo.setActive(vedic)
        let active = try repo.fetchActive()
        #expect(active?.name == "Vedic")
    }

    @Test("setActive: deactivates all other configurations")
    func testSetActiveDeactivatesOthers() throws {
        let repo = try makeRepository()
        try repo.add(name: "Western")
        let vedic = try repo.add(name: "Vedic")
        try repo.setActive(vedic)
        let all = try repo.fetchAll()
        let activeCount = all.filter(\.isActive).count
        #expect(activeCount == 1)
    }

    // MARK: - update

    @Test("update: persists changes to a configuration")
    func testUpdate() throws {
        let repo = try makeRepository()
        let config = try repo.add(name: "Western")
        config.name = "Renamed"
        try repo.update(config)
        let all = try repo.fetchAll()
        #expect(all.first?.name == "Renamed")
    }

    // MARK: - delete

    @Test("delete: removes a non-active configuration")
    func testDeleteNonActive() throws {
        let repo = try makeRepository()
        try repo.add(name: "Western")
        let vedic = try repo.add(name: "Vedic")
        try repo.delete(vedic)
        let all = try repo.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.name == "Western")
    }

    @Test("delete: throws when deleting the only configuration")
    func testDeleteOnlyThrows() throws {
        let repo = try makeRepository()
        let config = try repo.add(name: "Western")
        #expect(throws: UserConfigurationRepositoryError.cannotDeleteOnlyConfiguration) {
            try repo.delete(config)
        }
    }

    @Test("delete: throws when deleting the active configuration")
    func testDeleteActiveThrows() throws {
        let repo = try makeRepository()
        let western = try repo.add(name: "Western")
        try repo.add(name: "Vedic")
        #expect(throws: UserConfigurationRepositoryError.cannotDeleteActiveConfiguration) {
            try repo.delete(western)
        }
    }

    // MARK: - standard configuration

    @Test("delete: throws when deleting the standard configuration")
    func testDeleteStandardThrows() throws {
        let repo = try makeRepository()
        let standard = try repo.addStandard(name: "Standard")
        let western = try repo.add(name: "Western")
        try repo.setActive(western)
        #expect(throws: UserConfigurationRepositoryError.cannotDeleteStandardConfiguration) {
            try repo.delete(standard)
        }
    }

    @Test("delete: deleting the active configuration makes the standard configuration active")
    func testDeleteActiveActivatesStandard() throws {
        let repo = try makeRepository()
        let standard = try repo.addStandard(name: "Standard")
        let western = try repo.add(name: "Western")
        try repo.setActive(western)
        try repo.delete(western)
        #expect(try repo.fetchAll().count == 1)
        #expect(standard.isActive)
        #expect(try repo.fetchActive() === standard)
    }

    @Test("markStandardIfNeeded: marks the configuration with a standard name")
    func testMarkStandardIfNeeded() throws {
        let repo = try makeRepository()
        try repo.add(name: "Standaard")
        try repo.add(name: "Western")
        try repo.markStandardIfNeeded(standardNames: ["Default", "Standaard", "Standard"])
        #expect(try repo.fetchStandard()?.name == "Standaard")
    }

    @Test("markStandardIfNeeded: leaves an existing standard configuration alone")
    func testMarkStandardIfNeededKeepsExisting() throws {
        let repo = try makeRepository()
        try repo.addStandard(name: "Mine")
        let other = try repo.add(name: "Standard")
        try repo.markStandardIfNeeded(standardNames: ["Standard"])
        #expect(try repo.fetchStandard()?.name == "Mine")
        #expect(other.isStandard != true)
    }

    @Test("restoreDefaults: resets settings but keeps name and active state")
    func testRestoreDefaults() throws {
        let repo = try makeRepository()
        let config = try repo.add(name: "Western")
        config.orbConfig = OrbConfig(aspectBaseOrb: 3.0)
        config.displayConfig = DisplayConfig(drawingType: .dial90)
        try repo.restoreDefaults(config)
        #expect(config.name == "Western")
        #expect(config.isActive)
        #expect(config.orbConfig.aspectBaseOrb == OrbConfig().aspectBaseOrb)
        #expect(config.displayConfig.drawingType == DisplayConfig().drawingType)
    }
}
