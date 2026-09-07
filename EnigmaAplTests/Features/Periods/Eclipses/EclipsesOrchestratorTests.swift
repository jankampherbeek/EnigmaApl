// EclipsesOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation

@testable import EnigmaApl

struct EclipsesOrchestratorTests {

    /// Regression test for a heap-corruption crash ("BUG IN CLIENT OF LIBMALLOC: memory
    /// corruption of free block") seen when pressing Calculate on the Eclipses screen.
    ///
    /// Root cause: `SEWrapper` used to reference-count its instances and call `swe_close()`
    /// from `deinit` once the count returned to zero. `SEWrapper` instances are held by
    /// SwiftUI View structs (e.g. `EclipsesInputScreen`, `EclipsesResultsScreen`), which are
    /// created and discarded far more often than their on-screen lifetime as SwiftUI
    /// re-renders. Swiss Ephemeris is a single process-global C library, so a throwaway
    /// wrapper's `deinit` could call `swe_close()` — freeing SE's internal buffers — while
    /// another still-alive `SEWrapper` was mid-search. This test reproduces that churn
    /// concurrently with a long eclipse search (the search loop makes up to ~2000 Swiss
    /// Ephemeris calls) to catch any reintroduction of the bug.
    @Test("findEclipses survives concurrent SEWrapper churn from other screens")
    func testFindEclipsesUnderConcurrentWrapperChurn() async throws {
        let churnFlag = ManagedAtomicFlag()

        let churnTask = Task.detached(priority: .userInitiated) {
            while !churnFlag.isSet {
                // Simulate other SwiftUI screens repeatedly creating/discarding their own
                // SEWrapper property as the view tree re-renders.
                _ = SEWrapper()
            }
        }

        let seWrapper = SEWrapper()
        let orchestrator = EclipsesOrchestrator(seWrapper: seWrapper)

        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: 1950, Month: 1, Day: 1, Gregorian: true),
            time: AstronomicalTime(HourDecimal: 0.0))
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: 2050, Month: 1, Day: 1, Gregorian: true),
            time: AstronomicalTime(HourDecimal: 0.0))

        let events = orchestrator.findEclipses(
            startJD: jdStart, endJD: jdEnd,
            type: .all,
            geoLon: 4.9, geoLat: 52.4)

        churnFlag.set()
        _ = await churnTask.value

        #expect(!events.isEmpty, "Expected eclipses to be found over a 100-year range")
    }
}

/// Minimal thread-safe flag (avoids pulling in extra deps just for this test).
final class ManagedAtomicFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false

    var isSet: Bool {
        lock.lock(); defer { lock.unlock() }
        return value
    }

    func set() {
        lock.lock(); defer { lock.unlock() }
        value = true
    }
}
