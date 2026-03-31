// HarmonicsOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct HarmonicsOrchestratorTests {

    private let delta = 1e-8

    // MARK: - harmonicPositions: happy flow

    @Test("HarmonicsOrchestrator.harmonicPositions: correct H2 positions for two factors")
    func testH2Positions() {
        // Sun=30° → H2=60°, Moon=100° → H2=200°
        let chart = Self.makeChart([(.sun, 30.0), (.moon, 100.0)])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            harmonic: 2.0
        )
        #expect(result.count == 2)
        // sorted ascending: 60° (Sun), 200° (Moon)
        #expect(result[0].factor == .sun)
        #expect(abs(result[0].longitude - 60.0) < delta)
        #expect(result[1].factor == .moon)
        #expect(abs(result[1].longitude - 200.0) < delta)
    }

    @Test("HarmonicsOrchestrator.harmonicPositions: result is sorted ascending by longitude")
    func testPositionsSortedAscending() {
        let chart = Self.makeChart([(.sun, 22.0), (.moon, 178.0), (.mars, 302.0)])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            harmonic: 3.0
        )
        for i in 0..<(result.count - 1) {
            #expect(result[i].longitude <= result[i + 1].longitude)
        }
    }

    @Test("HarmonicsOrchestrator.harmonicPositions: H1 returns original longitudes")
    func testH1IsIdentity() {
        let chart = Self.makeChart([(.sun, 45.0), (.moon, 200.0)])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            harmonic: 1.0
        )
        let longitudes = result.map(\.longitude).sorted()
        #expect(abs(longitudes[0] - 45.0) < delta)
        #expect(abs(longitudes[1] - 200.0) < delta)
    }

    @Test("HarmonicsOrchestrator.harmonicPositions: reduction keeps result within 0–360°")
    func testPositionsInRange() {
        let chart = Self.makeChart([(.sun, 200.0), (.moon, 300.0), (.mars, 350.0)])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            harmonic: 5.0
        )
        for item in result {
            #expect(item.longitude >= 0.0 && item.longitude < 360.0)
        }
    }

    // MARK: - harmonicPositions: unused / absent factors

    @Test("HarmonicsOrchestrator.harmonicPositions: unused factors are excluded")
    func testUnusedFactorExcluded() {
        // Mars is in the chart but not in factorConfig
        let chart = Self.makeChart([(.sun, 30.0), (.moon, 100.0), (.mars, 200.0)])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            harmonic: 2.0
        )
        #expect(result.count == 2)
        #expect(!result.contains(where: { $0.factor == .mars }))
    }

    @Test("HarmonicsOrchestrator.harmonicPositions: factor in config absent from chart is skipped")
    func testAbsentFactorSkipped() {
        let chart = Self.makeChart([(.sun, 30.0)])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            harmonic: 2.0
        )
        #expect(result.count == 1)
        #expect(result[0].factor == .sun)
    }

    // MARK: - harmonicPositions: guard conditions

    @Test("HarmonicsOrchestrator.harmonicPositions: empty chart returns empty list")
    func testPositionsEmptyChart() {
        let chart = Self.makeChart([])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            harmonic: 2.0
        )
        #expect(result.isEmpty)
    }

    @Test("HarmonicsOrchestrator.harmonicPositions: no used factors returns empty list")
    func testPositionsNoUsedFactors() {
        let chart = Self.makeChart([(.sun, 30.0), (.moon, 100.0)])
        let factorConfig = FactorConfig(factorSettings: [
            FactorSettings(factor: .sun, isUsed: false, isDrawn: false),
            FactorSettings(factor: .moon, isUsed: false, isDrawn: false)
        ])
        let result = HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: factorConfig,
            harmonic: 2.0
        )
        #expect(result.isEmpty)
    }

    // MARK: - matches: happy flow

    @Test("HarmonicsOrchestrator.matches: exact match is found")
    func testMatchesExactMatch() {
        // Sun=90°, Moon=180°; H2: Sun→180° = Moon's radix position → exact match
        let chart = Self.makeChart([(.sun, 90.0), (.moon, 180.0)])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        let exactMatch = result.first { $0.harmonicFactor == .sun && $0.radixFactor == .moon }
        #expect(exactMatch != nil)
        #expect(abs(exactMatch!.actualOrb - 0.0) < delta)
    }

    @Test("HarmonicsOrchestrator.matches: match within orb is found")
    func testMatchesWithinOrb() {
        // Sun=90°; H2→180°; Moon=181.5° → separation=1.5° < orb=2°
        let chart = Self.makeChart([(.sun, 90.0), (.moon, 181.5)])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        let match = result.first { $0.harmonicFactor == .sun && $0.radixFactor == .moon }
        #expect(match != nil)
        #expect(abs(match!.actualOrb - 1.5) < delta)
    }

    @Test("HarmonicsOrchestrator.matches: no match outside orb")
    func testMatchesOutsideOrb() {
        // Sun=90°; H2→180°; Moon=182.5° → separation=2.5° > orb=2°
        let chart = Self.makeChart([(.sun, 90.0), (.moon, 182.5)])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        let match = result.first { $0.harmonicFactor == .sun && $0.radixFactor == .moon }
        #expect(match == nil)
    }

    @Test("HarmonicsOrchestrator.matches: result sorted by actualOrb ascending")
    func testMatchesSortedByOrb() {
        // Sun=90° H2→180°; Moon=180° (sep 0°), Mars=181° (sep 1°)
        let chart = Self.makeChart([(.sun, 90.0), (.moon, 180.0), (.mars, 181.0)])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        for i in 0..<(result.count - 1) {
            #expect(result[i].actualOrb <= result[i + 1].actualOrb)
        }
    }

    @Test("HarmonicsOrchestrator.matches: maxOrb reflects orbConfig.harmonicOrb")
    func testMatchesMaxOrbFromConfig() {
        let chart = Self.makeChart([(.sun, 90.0), (.moon, 180.0)])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            orbConfig: Self.orbConfig(harmonicOrb: 3.0),
            harmonic: 2.0
        )
        for match in result {
            #expect(abs(match.maxOrb - 3.0) < delta)
        }
    }

    @Test("HarmonicsOrchestrator.matches: wrap-around match near 0°/360° boundary is found")
    func testMatchesWrapAround() {
        // Sun=179°; H2→358°; Moon=1° → shortest separation = 3° > orb=2° → not found
        // Sun=179.5°; H2→359°; Moon=1° → shortest separation = 2° == orb → found
        let chart = Self.makeChart([(.sun, 179.5), (.moon, 1.0)])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        let match = result.first { $0.harmonicFactor == .sun && $0.radixFactor == .moon }
        #expect(match != nil)
        #expect(abs(match!.actualOrb - 2.0) < delta)
    }

    // MARK: - matches: guard conditions

    @Test("HarmonicsOrchestrator.matches: empty chart returns empty list")
    func testMatchesEmptyChart() {
        let chart = Self.makeChart([])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        #expect(result.isEmpty)
    }

    @Test("HarmonicsOrchestrator.matches: no used factors returns empty list")
    func testMatchesNoUsedFactors() {
        let chart = Self.makeChart([(.sun, 90.0), (.moon, 180.0)])
        let factorConfig = FactorConfig(factorSettings: [
            FactorSettings(factor: .sun, isUsed: false, isDrawn: false),
            FactorSettings(factor: .moon, isUsed: false, isDrawn: false)
        ])
        let result = HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: factorConfig,
            orbConfig: Self.orbConfig(harmonicOrb: 2.0),
            harmonic: 2.0
        )
        #expect(result.isEmpty)
    }

    // MARK: - Helpers

    private static func makeChart(_ pairs: [(Factors, Double)]) -> FullChart {
        let dummyCusp = FullCuspPosition(
            longitude: 0, rightAscension: 0, declination: 0,
            horizontal: HorizontalPosition(azimuth: 0, altitude: 0)
        )
        let dummyHouses = HousePositions(
            cusps: [], ascendant: dummyCusp, midheaven: dummyCusp,
            eastpoint: dummyCusp, vertex: dummyCusp
        )
        var coords: [Factors: FullFactorPosition] = [:]
        for (factor, lon) in pairs {
            coords[factor] = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: lon, deviation: 0, distance: 1)],
                equatorial: [],
                horizontal: []
            )
        }
        return FullChart(Coordinates: coords, HousePositions: dummyHouses,
                         SiderealTime: 0, JulianDay: 0, Obliquity: 23.5)
    }

    private static func factorConfig(_ factors: [Factors]) -> FactorConfig {
        FactorConfig(factorSettings: factors.map {
            FactorSettings(factor: $0, isUsed: true, isDrawn: false, orbPercentage: 100)
        })
    }

    private static func orbConfig(harmonicOrb: Double) -> OrbConfig {
        OrbConfig(harmonicOrb: harmonicOrb)
    }
}
