//
//  UserConfigurationTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
import Foundation
import SwiftData
@testable import EnigmaApl

struct UserConfigurationTests {

    // MARK: - Helpers

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([UserConfiguration.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    // MARK: - Initialization

    @Test("UserConfiguration: default sub-configs are applied")
    func testDefaultSubConfigs() {
        let config = UserConfiguration(name: "Test")
        #expect(config.name == "Test")
        #expect(config.isActive == false)
        #expect(config.calculationConfig.houseSystem == .placidus)
        #expect(config.orbConfig.aspectBaseOrb == 10.0)
        #expect(config.progressionsConfig.solarReturn.method == .tropicalParallax)
    }

    @Test("UserConfiguration: custom name and isActive")
    func testCustomNameAndActive() {
        let config = UserConfiguration(name: "Vedic", isActive: true)
        #expect(config.name == "Vedic")
        #expect(config.isActive == true)
    }

    @Test("UserConfiguration: custom sub-configs are stored correctly")
    func testCustomSubConfigs() {
        let calcConfig = CalculationConfig(houseSystem: .wholeSign, ayanamsha: .lahiri)
        let config = UserConfiguration(name: "Vedic", calculationConfig: calcConfig)
        #expect(config.calculationConfig.houseSystem == .wholeSign)
        #expect(config.calculationConfig.ayanamsha == .lahiri)
    }

    // MARK: - Swift Data persistence

    @Test("UserConfiguration: persists and retrieves from Swift Data")
    func testPersistence() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let config = UserConfiguration(name: "Western", isActive: true)
        context.insert(config)
        try context.save()

        let descriptor = FetchDescriptor<UserConfiguration>()
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results.first?.name == "Western")
        #expect(results.first?.isActive == true)
    }

    @Test("UserConfiguration: multiple configurations can be stored")
    func testMultipleConfigurations() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(UserConfiguration(name: "Western", isActive: true))
        context.insert(UserConfiguration(name: "Vedic", isActive: false))
        context.insert(UserConfiguration(name: "Uranian", isActive: false))
        try context.save()

        let descriptor = FetchDescriptor<UserConfiguration>()
        let results = try context.fetch(descriptor)
        #expect(results.count == 3)
    }

    @Test("UserConfiguration: only one configuration is active")
    func testOnlyOneActive() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(UserConfiguration(name: "Western", isActive: true))
        context.insert(UserConfiguration(name: "Vedic", isActive: false))
        try context.save()

        let descriptor = FetchDescriptor<UserConfiguration>(
            predicate: #Predicate { $0.isActive == true }
        )
        let activeResults = try context.fetch(descriptor)
        #expect(activeResults.count == 1)
        #expect(activeResults.first?.name == "Western")
    }

    @Test("UserConfiguration: sub-configs persist correctly")
    func testSubConfigsPersist() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let calcConfig = CalculationConfig(houseSystem: .koch, ayanamsha: .fagan)
        let orbConfig = OrbConfig(aspectBaseOrb: 8.0)
        context.insert(UserConfiguration(name: "Custom",
                                         calculationConfig: calcConfig,
                                         orbConfig: orbConfig))
        try context.save()

        let descriptor = FetchDescriptor<UserConfiguration>()
        let result = try context.fetch(descriptor).first
        #expect(result?.calculationConfig.houseSystem == .koch)
        #expect(result?.calculationConfig.ayanamsha == .fagan)
        #expect(result?.orbConfig.aspectBaseOrb == 8.0)
    }
}
