// AppEnvironmentTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import SwiftData
@testable import EnigmaApl

/// Guards that a test run never touches the data of the user.
@MainActor
@Suite(.tags(.integration))
struct AppEnvironmentTests {

    @Test func detectsTheTestHost() {
        #expect(AppEnvironment.isRunningUnitTests)
        #expect(AppEnvironment.skipsStartupChart)
    }

    @Test func sharedContainerIsInMemoryDuringTests() {
        let configurations = PersistenceController.shared.container.configurations
        #expect(!configurations.isEmpty)
        #expect(configurations.allSatisfy { $0.isStoredInMemoryOnly })
    }

    @Test func makeContainerInMemoryGivesAnEmptyDatabase() throws {
        let container = try PersistenceController.makeContainer(inMemory: true)
        let context = ModelContext(container)
        #expect(try context.fetchCount(FetchDescriptor<HoroscopeModel>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<UserConfiguration>()) == 0)
    }
}
