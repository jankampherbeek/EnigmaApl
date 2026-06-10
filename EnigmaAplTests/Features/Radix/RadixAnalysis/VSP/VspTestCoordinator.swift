// VspTestCoordinator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Runs all SE-backed VSP orchestrator tests sequentially with a single SEWrapper.
/// Swiss Ephemeris is not thread-safe; sharing one instance and running tests one
/// after another avoids race conditions.
struct VspTestCoordinator {

    @Test("VSP: Run all SE-backed orchestrator tests sequentially")
    @MainActor
    func runAllVspTests() async throws {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()

        VspOrchestratorTests.testHappyFlow(seWrapper: seWrapper)
        VspOrchestratorTests.testChronologicalOrder(seWrapper: seWrapper)
        VspOrchestratorTests.testLongitudesInValidRange(seWrapper: seWrapper)
        VspOrchestratorTests.testBothPhenomenaPresent(seWrapper: seWrapper)
        VspOrchestratorTests.testConsistentResults(seWrapper: seWrapper)
        VspOrchestratorTests.testKnownLongitudeJan2022(seWrapper: seWrapper)
        VspOrchestratorTests.testVariousDates(seWrapper: seWrapper)

        _ = seWrapper   // keep alive until end of function
    }
}
