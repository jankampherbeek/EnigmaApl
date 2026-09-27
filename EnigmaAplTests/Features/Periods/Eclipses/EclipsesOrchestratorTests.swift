// EclipsesOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
import SwissEphC

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

    /// Regression test for a heap-corruption crash (SIGSEGV inside Swiss Ephemeris' own
    /// `get_new_segment` / `read_const` / `do_fread`, or a libmalloc abort in `mfm_free`)
    /// that appeared when searching a long period — around 150 years — with a location.
    ///
    /// Root cause: `SEWrapper.solEclipseSaros` passed a 3-element `geopos` array to
    /// `swe_sol_eclipse_where`, which writes 10 doubles. The 7 doubles written past the end
    /// of the Swift array corrupted the heap, and the process later died inside whatever
    /// Swiss Ephemeris had allocated next. It only shows up with a location, because
    /// `solEclipseSaros` is the fallback taken when an eclipse is not visible from there —
    /// rare in a short period, frequent over 150 years.
    @Test("findEclipses over 150 years with a location does not corrupt the heap")
    func testFindEclipsesLongPeriodWithLocation() async throws {
        let seWrapper = SEWrapper()
        let orchestrator = EclipsesOrchestrator(seWrapper: seWrapper)

        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: 2024, Month: 1, Day: 1, Gregorian: true),
            time: AstronomicalTime(HourDecimal: 0.0))
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: 2174, Month: 12, Day: 31, Gregorian: true),
            time: AstronomicalTime(HourDecimal: 0.0))

        let events = orchestrator.findEclipses(
            startJD: jdStart, endJD: jdEnd,
            type: .all,
            geoLon: 4.9, geoLat: 52.4)

        // ~4.6 eclipses per year over 151 years; the search loop caps each kind at 1000.
        #expect(events.count > 600)
        #expect(events.allSatisfy { $0.displayJD.isFinite && $0.longitude.isFinite })
        #expect(events.allSatisfy { (0.0..<360.0).contains($0.longitude) })
    }

    /// Pins the output-buffer contract of `swe_sol_eclipse_where`, whose documented
    /// "2 doubles" for `geopos` is wrong — it writes 10. If a Swiss Ephemeris upgrade widens
    /// this further, this test fails instead of the heap silently corrupting again.
    @Test("swe_sol_eclipse_where writes no more than 10 doubles into geopos")
    func testSolEclipseWhereGeoposContract() async throws {
        _ = SEWrapper()   // sets the ephemeris path

        let capacity = 32
        let sentinel = -12345.6789
        let geopos = UnsafeMutablePointer<Double>.allocate(capacity: capacity)
        defer { geopos.deallocate() }
        for i in 0..<capacity { geopos[i] = sentinel }

        var attr = [Double](repeating: 0.0, count: 20)
        var serr = [CChar](repeating: 0, count: 256)
        let jdTotalSolarEclipse2024 = 2460409.0

        let returnCode = swe_sol_eclipse_where(jdTotalSolarEclipse2024, SEFLG_SWIEPH,
                                               geopos, &attr, &serr)
        #expect(returnCode >= 0)

        var highestIndexWritten = -1
        for i in 0..<capacity where geopos[i] != sentinel { highestIndexWritten = i }
        #expect(highestIndexWritten <= 9,
                "swe_sol_eclipse_where wrote geopos[\(highestIndexWritten)]; the buffer in solEclipseSaros holds 10 doubles")
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
