// ProgressiveCalendarOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

@MainActor
struct ProgressiveCalendarOrchestratorTests {

    // MARK: - Shared reference chart

    // Same reference date/place used by AstronCalcOrchestratorTests: known-good, already
    // validated ephemeris and house values.
    private let natalJD: Double = 2455197.5
    private let geoLat: Double  = 52.21805555555556
    private let geoLon: Double  = 6.895555555555555
    private let houseSystemId   = 82   // Regiomontanus

    private func makeConfig() -> CalculationConfig {
        CalculationConfig(
            houseSystem: HouseSystems(rawValue: houseSystemId) ?? .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
    }

    private func makeRadixChart(_ seWrapper: SEWrapper, factors: [Factors] = [.sun, .moon, .mercury, .venus, .mars]) -> FullChart {
        let request = CalcRequest(
            JulianDay: natalJD,
            FactorsToUse: factors,
            HouseSystem: houseSystemId,
            Latitude: geoLat,
            Longitude: geoLon,
            Height: 0.0,
            calculationConfig: makeConfig()
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
    }

    private func makeOrchestrator(_ seWrapper: SEWrapper, chart: FullChart) -> ProgressiveCalendarOrchestrator {
        ProgressiveCalendarOrchestrator(natalJD: natalJD, radixChart: chart, seWrapper: seWrapper)
    }

    // MARK: - Aspect-to-radix episode: the annual solar return

    @Test("ProgressiveCalendarOrchestrator: transiting Sun conjunct natal Sun found once per year, with enter/exact/exit ordering")
    func testSolarReturnConjunctionEpisode() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let chart = makeRadixChart(seWrapper)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.parallelsToRadix = false
        toggles.aspectsProgToProg = false
        toggles.parallelsProgToProg = false
        toggles.cuspConjunctions = false
        toggles.retrogradeDirectStations = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        // Start scanning a few days after the natal moment: starting exactly at natalJD would
        // make the transiting Sun trivially "already exact" at t=0 (it IS the natal Sun then),
        // producing a degenerate extra episode that closes within a day — correct behavior,
        // but not what this test is checking.
        let result = orchestrator.findEvents(
            startJD: natalJD + 10.0, endJD: natalJD + 400.0,
            selections: [.init(technique: .transit, factors: [.sun])],
            radixFactors: [.sun],
            aspects: [.conjunction],
            aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        #expect(result.episodes.count == 1, "Expected exactly one solar-return episode, got \(result.episodes.count)")
        guard let episode = result.episodes.first else { return }

        #expect(episode.kind == .aspectToRadix(.conjunction), "Expected an aspect-to-radix conjunction episode")

        let expectedReturnJD = natalJD + 365.242199074
        #expect(abs(episode.exactJD - expectedReturnJD) < 1.0,
                "Expected the exact solar return near \(expectedReturnJD), got \(episode.exactJD)")

        if let enterJD = episode.enterJD, let exitJD = episode.exitJD {
            #expect(enterJD < episode.exactJD, "enterJD must precede exactJD")
            #expect(episode.exactJD < exitJD, "exactJD must precede exitJD")
        } else {
            Issue.record("Expected both enterJD and exitJD to be non-nil, well inside the scanned range")
        }

        #expect(episode.minOrb < 0.01, "Expected the exact moment's orb to be near zero, got \(episode.minOrb)")
        #expect(episode.becomesExact, "A genuine solar return must be marked as becoming exact")
    }

    // MARK: - Episode already past exact at the start of the scan

    @Test("ProgressiveCalendarOrchestrator: episode already past its exact moment at scan start falls back exactJD to startJD verbatim")
    func testEpisodeExactBeforeScanStartFallsBackToStartJD() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let chart = makeRadixChart(seWrapper)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.parallelsToRadix = false
        toggles.aspectsProgToProg = false
        toggles.parallelsProgToProg = false
        toggles.cuspConjunctions = false
        toggles.retrogradeDirectStations = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        // Start the scan half a day AFTER the exact solar return (the Sun moves ~0.99°/day,
        // so at +0.5 days it is ~0.49° past exact — inside a 1° orb, and already moving away).
        // No exact crossing exists inside [startJD, endJD], so exactJD must fall back to
        // startJD verbatim, and becomesExact must be false — the contract
        // ProgressiveCalendarResultsScreen relies on to hide a misleading "exact" date.
        let returnJD = natalJD + 365.242199074
        let startJD = returnJD + 0.5
        let endJD = returnJD + 3.0

        let result = orchestrator.findEvents(
            startJD: startJD, endJD: endJD,
            selections: [.init(technique: .transit, factors: [.sun])],
            radixFactors: [.sun],
            aspects: [.conjunction],
            aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        #expect(result.episodes.count == 1, "Expected exactly one already-in-orb episode, got \(result.episodes.count)")
        guard let episode = result.episodes.first else { return }

        #expect(episode.enterJD == nil, "Episode should already be in orb at scan start (enterJD nil)")
        #expect(episode.exactJD == startJD, "exactJD must fall back to startJD verbatim (bit-exact) when no interior crossing exists")
        #expect(episode.exitJD != nil, "Episode should exit orb within the scanned window")
        #expect(!episode.becomesExact, "This episode never reaches exact within the scanned window")
    }

    // MARK: - Episode still approaching exact at the end of the scan

    @Test("ProgressiveCalendarOrchestrator: episode still approaching exact at scan end falls back exactJD to endJD verbatim")
    func testEpisodeExactAfterScanEndFallsBackToEndJD() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let chart = makeRadixChart(seWrapper)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.parallelsToRadix = false
        toggles.aspectsProgToProg = false
        toggles.parallelsProgToProg = false
        toggles.cuspConjunctions = false
        toggles.retrogradeDirectStations = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        // End the scan half a day BEFORE the exact solar return (still ~0.49° away — inside a
        // 1° orb, still approaching). No exact crossing exists inside [startJD, endJD], so
        // exactJD must fall back to endJD verbatim — the symmetric counterpart of the
        // start-of-scan fallback above, and the contract ProgressiveCalendarResultsScreen
        // relies on to also hide a misleading "exact" date after the scanned period.
        let returnJD = natalJD + 365.242199074
        let startJD = returnJD - 3.0
        let endJD = returnJD - 0.5

        let result = orchestrator.findEvents(
            startJD: startJD, endJD: endJD,
            selections: [.init(technique: .transit, factors: [.sun])],
            radixFactors: [.sun],
            aspects: [.conjunction],
            aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        #expect(result.episodes.count == 1, "Expected exactly one still-approaching episode, got \(result.episodes.count)")
        guard let episode = result.episodes.first else { return }

        #expect(episode.exitJD == nil, "Episode should still be in orb at scan end (exitJD nil)")
        #expect(episode.exactJD == endJD, "exactJD must fall back to endJD verbatim (bit-exact) when no interior crossing exists")
        #expect(episode.enterJD != nil, "Episode should enter orb within the scanned window")
        #expect(!episode.becomesExact, "This episode never reaches exact within the scanned window")
    }

    // MARK: - Instantaneous events: retrograde/direct stations

    @Test("ProgressiveCalendarOrchestrator: Mercury transit stations found over a year, alternating retrograde/direct")
    func testMercuryStationsFoundOverAYear() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let chart = makeRadixChart(seWrapper)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.aspectsToRadix = false
        toggles.parallelsToRadix = false
        toggles.aspectsProgToProg = false
        toggles.parallelsProgToProg = false
        toggles.cuspConjunctions = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        let result = orchestrator.findEvents(
            startJD: natalJD, endJD: natalJD + 400.0,
            selections: [.init(technique: .transit, factors: [.mercury])],
            radixFactors: [], aspects: [], aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        // Mercury stations 3-4 times a year, so a ~400-day window must contain at least one
        // full retrograde/direct pair.
        #expect(result.events.count >= 2, "Expected at least one retro/direct pair, got \(result.events.count)")

        for event in result.events {
            #expect(event.jd >= natalJD && event.jd <= natalJD + 400.0, "Station JD must be within the scanned range")
            switch event.kind {
            case .retrogradeStation, .directStation:
                break
            default:
                Issue.record("Unexpected event kind for a stations-only scan: \(event.kind)")
            }
        }

        // Stations must alternate retrograde/direct.
        var previousWasRetrograde: Bool? = nil
        for event in result.events {
            let isRetrograde: Bool
            switch event.kind {
            case .retrogradeStation: isRetrograde = true
            case .directStation: isRetrograde = false
            default: continue
            }
            if let previous = previousWasRetrograde {
                #expect(previous != isRetrograde, "Consecutive stations must alternate retrograde/direct")
            }
            previousWasRetrograde = isRetrograde
        }
    }

    // MARK: - Instantaneous events: cusp conjunctions

    @Test("ProgressiveCalendarOrchestrator: transiting Sun crosses the natal Ascendant exactly once per full zodiac cycle")
    func testSunCrossesNatalAscendantOnce() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let chart = makeRadixChart(seWrapper)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.aspectsToRadix = false
        toggles.parallelsToRadix = false
        toggles.aspectsProgToProg = false
        toggles.parallelsProgToProg = false
        toggles.retrogradeDirectStations = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        let result = orchestrator.findEvents(
            startJD: natalJD, endJD: natalJD + 370.0,
            selections: [.init(technique: .transit, factors: [.sun])],
            radixFactors: [], aspects: [], aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        let ascendantHits = result.events.filter { event in
            if case .cuspConjunction(_, let cusp) = event.kind, cusp == .ascendant { return true }
            return false
        }
        #expect(ascendantHits.count == 1, "Expected exactly one Sun-Ascendant crossing, got \(ascendantHits.count)")
    }

    // MARK: - Symbolic directions: longitude-only scope

    @Test("ProgressiveCalendarOrchestrator: symbolic directions never produce declination, OOB, station or parallel results")
    func testSymbolicDirectionsExcludeDeclinationBasedResults() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let chart = makeRadixChart(seWrapper)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        let toggles = ProgressiveCalendarOrchestrator.EventKindToggles()   // all kinds on

        let result = orchestrator.findEvents(
            startJD: natalJD, endJD: natalJD + 3650.0,
            selections: [.init(technique: .symbolicDirection, factors: [.sun, .moon], symbolicKey: .oneDegree)],
            radixFactors: [.sun, .moon],
            aspects: [.conjunction, .opposition, .trine, .square],
            aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        for event in result.events {
            switch event.kind {
            case .zeroDeclination, .maxDeclination, .oobEnter, .oobExit, .retrogradeStation, .directStation:
                Issue.record("Symbolic directions must not produce this event kind: \(event.kind)")
            case .cuspConjunction:
                break
            }
        }
        for episode in result.episodes {
            switch episode.kind {
            case .parallelToRadix, .contraParallelToRadix, .parallelProgToProg, .contraParallelProgToProg:
                Issue.record("Symbolic directions must not produce this episode kind: \(episode.kind)")
            case .aspectToRadix, .aspectProgToProg:
                break
            }
        }
    }

    // MARK: - Never-exact episode: closest approach must be the true interior minimum

    @Test("ProgressiveCalendarOrchestrator: a never-exact episode reports the true interior closest approach, not an orb-boundary value")
    func testNeverExactEpisodeReportsTrueClosestApproach() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let factors: [Factors] = [.mercury, .saturn]
        let chart = makeRadixChart(seWrapper, factors: factors)
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.aspectsToRadix = false
        toggles.parallelsToRadix = false
        toggles.parallelsProgToProg = false
        toggles.cuspConjunctions = false
        toggles.retrogradeDirectStations = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        // A narrow window bracketing a known transiting Mercury/Saturn square that a Mercury
        // station interrupts before it becomes exact (found via a broad survey + brute-force
        // verification: ground truth closest approach is ~0.906°, at JD≈2455212.18, strictly
        // between the episode's enter and exit — not equal to either).
        let result = orchestrator.findEvents(
            startJD: natalJD + 8.0, endJD: natalJD + 20.0,
            selections: [.init(technique: .transit, factors: factors)],
            radixFactors: [],
            aspects: [.square],
            aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        #expect(result.episodes.count == 1, "Expected exactly one episode, got \(result.episodes.count)")
        guard let episode = result.episodes.first else { return }

        #expect(episode.enterJD != nil && episode.exitJD != nil, "Expected a fully-bracketed episode")
        if let enterJD = episode.enterJD, let exitJD = episode.exitJD {
            #expect(episode.exactJD > enterJD && episode.exactJD < exitJD,
                    "exactJD must be strictly interior, not equal to a boundary — got enterJD=\(enterJD) exactJD=\(episode.exactJD) exitJD=\(exitJD)")
        }
        #expect(abs(episode.minOrb - 0.9055) < 0.005,
                "Expected minOrb close to the true closest approach (~0.9055°), got \(episode.minOrb)")
        #expect(!episode.becomesExact, "A station-interrupted approach must not be marked as becoming exact")
    }

    // MARK: - Genuine exact aspect: scanner must still find a true zero-orb crossing

    @Test("ProgressiveCalendarOrchestrator: a genuinely exact aspect-to-radix trine is found with near-zero orb")
    func testGenuineExactAspectReportsNearZeroOrb() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()

        // Construct a radix Chiron position that makes transiting Mercury's trine to it exact
        // at a known, controlled moment — this isolates whether the zero-crossing scan itself
        // can still find a true exact aspect (as opposed to the near-miss, station-interrupted
        // episodes covered by testNeverExactEpisodeReportsTrueClosestApproach above).
        let claimedExactJD = seWrapper.julianDay(
            date: AstronomicalDate(Year: 2030, Month: 1, Day: 10, Gregorian: true),
            time: AstronomicalTime(Hour: 20, Minute: 35, Second: 33)
        )
        func longitude(_ factor: Factors, _ jd: Double) -> Double {
            seWrapper.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2)?.mainPos ?? 0.0
        }
        let mercuryAtClaimedExact = longitude(.mercury, claimedExactJD)
        var derivedChironLongitude = (mercuryAtClaimedExact - 120.0).truncatingRemainder(dividingBy: 360.0)
        if derivedChironLongitude < 0 { derivedChironLongitude += 360.0 }

        let baseChart = makeRadixChart(seWrapper, factors: [.sun, .mercury, .venus, .mars, .chiron])
        guard let realChiron = baseChart.Coordinates[.chiron] else {
            Issue.record("Expected Chiron in the base chart")
            return
        }
        let syntheticChironEcliptical = MainAstronomicalPosition(
            mainPos: derivedChironLongitude,
            deviation: realChiron.ecliptical.first?.deviation ?? 0.0,
            distance: realChiron.ecliptical.first?.distance ?? 0.0
        )
        var coordinates = baseChart.Coordinates
        coordinates[.chiron] = FullFactorPosition(
            ecliptical: [syntheticChironEcliptical],
            equatorial: realChiron.equatorial,
            horizontal: realChiron.horizontal
        )
        let chart = FullChart(
            Coordinates: coordinates, HousePositions: baseChart.HousePositions,
            SiderealTime: baseChart.SiderealTime, JulianDay: baseChart.JulianDay, Obliquity: baseChart.Obliquity
        )
        let orchestrator = makeOrchestrator(seWrapper, chart: chart)

        let startJD = seWrapper.julianDay(date: AstronomicalDate(Year: 2030, Month: 1, Day: 1), time: AstronomicalTime(Hour: 0, Minute: 0, Second: 0))
        let endJD = seWrapper.julianDay(date: AstronomicalDate(Year: 2030, Month: 2, Day: 1), time: AstronomicalTime(Hour: 0, Minute: 0, Second: 0))

        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.parallelsToRadix = false
        toggles.aspectsProgToProg = false
        toggles.parallelsProgToProg = false
        toggles.cuspConjunctions = false
        toggles.retrogradeDirectStations = false
        toggles.oobEnterExit = false
        toggles.declinationExtremes = false

        let result = orchestrator.findEvents(
            startJD: startJD, endJD: endJD,
            selections: [.init(technique: .transit, factors: [.mercury])],
            radixFactors: [.chiron],
            aspects: [.trine],
            aspectOrb: 1.0, parallelOrb: 1.0, cuspOrb: 1.0,
            toggles: toggles
        )

        #expect(result.episodes.count == 1, "Expected exactly one episode in this narrow window, got \(result.episodes.count)")
        guard let episode = result.episodes.first else { return }

        #expect(abs(episode.exactJD - claimedExactJD) < 0.01,
                "Expected exactJD close to the constructed exact moment, got \(episode.exactJD) vs \(claimedExactJD)")
        #expect(episode.minOrb < 0.001, "Expected a near-zero orb for a genuinely exact aspect, got \(episode.minOrb)")
        #expect(episode.becomesExact, "A genuinely exact aspect must be marked as becoming exact")
    }
}
