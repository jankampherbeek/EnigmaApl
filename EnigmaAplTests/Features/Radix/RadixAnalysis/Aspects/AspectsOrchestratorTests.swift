// AspectsOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct AspectsOrchestratorTests {

    private let delta = 1e-8

    // MARK: - Happy flow

    @Test("AspectsOrchestrator: exact conjunction is found")
    func testExactConjunction() {
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 0.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
        #expect(result[0].aspect == .conjunction)
        #expect(abs(result[0].orb) < delta)
    }

    @Test("AspectsOrchestrator: exact opposition is found")
    func testExactOpposition() {
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 180.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.opposition]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
        #expect(result[0].aspect == .opposition)
        #expect(abs(result[0].orb) < delta)
    }

    @Test("AspectsOrchestrator: exact trine is found")
    func testExactTrine() {
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 120.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.trine]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
        #expect(result[0].aspect == .trine)
        #expect(abs(result[0].orb) < delta)
    }

    @Test("AspectsOrchestrator: aspect within orb is found with correct orb value")
    func testAspectWithinOrb() {
        // Sun=0, Moon=7: shortestDistance=7; conjunction deviation=7; maxOrb=10 → found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 7.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
        #expect(abs(result[0].orb - 7.0) < delta)
    }

    @Test("AspectsOrchestrator: FoundAspect contains correct aspect, orb and maxOrb")
    func testFoundAspectFields() {
        // Sun=0, Moon=120: exact trine; all 100%, baseOrb=10 → maxOrb=10.0
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 120.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.trine]),
            orbConfig: Self.orbConfig(baseOrb: 10.0)
        )
        #expect(result.count == 1)
        let found = result[0]
        #expect(found.aspect == .trine)
        #expect(abs(found.orb) < delta)
        #expect(abs(found.maxOrb - 10.0) < delta)
    }

    @Test("AspectsOrchestrator: result is sorted by orb ascending")
    func testResultSortedByOrb() {
        // Sun=0, Moon=3 (conjunction orb=3), Mars=178 (opposition from Sun orb=2, from Moon orb=5)
        // Expected sorted order: Sun-Mars opp(2), Sun-Moon conj(3), Moon-Mars opp(5)
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 3.0), (.mars, 178.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            aspectConfig: Self.aspectConfig([.conjunction, .opposition]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count >= 2)
        for i in 0..<(result.count - 1) {
            #expect(result[i].orb <= result[i + 1].orb)
        }
    }

    @Test("AspectsOrchestrator: wrap-around distance near 0°/360° boundary is handled correctly")
    func testWrapAroundDistance() {
        // Sun=355, Moon=5: |355-5|=350 > 180 → shortestDistance=360-350=10
        // conjunction deviation=10; maxOrb=10 → found at orb boundary
        let chart = Self.makeChart([(.sun, 355.0), (.moon, 5.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
        #expect(result[0].aspect == .conjunction)
        #expect(abs(result[0].orb - 10.0) < delta)
    }

    // MARK: - Orb boundary

    @Test("AspectsOrchestrator: deviation exactly equal to maxOrb is included")
    func testDeviationAtMaxOrbBoundary() {
        // Sun=0, Moon=10: deviation=10; maxOrb=10; 10 <= 10 → found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 10.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
    }

    @Test("AspectsOrchestrator: deviation just outside maxOrb is excluded")
    func testDeviationJustOutsideMaxOrb() {
        // Sun=0, Moon=11: deviation=11 > maxOrb=10 → not found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 11.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    // MARK: - Guard conditions

    @Test("AspectsOrchestrator: empty chart returns empty result")
    func testEmptyChart() {
        let chart = Self.makeChart([])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    @Test("AspectsOrchestrator: single factor returns empty result")
    func testSingleFactor() {
        let chart = Self.makeChart([(.sun, 0.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    @Test("AspectsOrchestrator: no used factors returns empty result")
    func testNoUsedFactors() {
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 0.0)])
        let factorConfig = FactorConfig(factorSettings: [
            FactorSettings(factor: .sun, isUsed: false, isDrawn: false),
            FactorSettings(factor: .moon, isUsed: false, isDrawn: false)
        ])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: factorConfig,
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    @Test("AspectsOrchestrator: no used aspects returns empty result")
    func testNoUsedAspects() {
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 0.0)])
        let aspectConfig = AspectConfig(aspectSettings: [
            AspectSettings(aspect: .conjunction, isUsed: false, isDrawn: false)
        ])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: aspectConfig,
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    @Test("AspectsOrchestrator: factor in config but absent from chart is silently skipped")
    func testFactorAbsentFromChart() {
        // Mercury is in factorConfig but has no position in the chart; Sun-Moon pair still found.
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 0.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon, .mercury]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
        #expect(result[0].aspect == .conjunction)
    }

    // MARK: - Orb percentage

    @Test("AspectsOrchestrator: reduced aspect orbPercentage shrinks the allowed orb")
    func testAspectOrbPercentageReducesOrb() {
        // Sun=0, Moon=6; aspectOrbPct=50 → maxOrb = 1.0 * 0.5 * 10 = 5 → deviation=6 > 5 → not found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 6.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction], orbPct: 50),
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    @Test("AspectsOrchestrator: full aspect orbPercentage allows aspect within base orb")
    func testAspectOrbPercentageFull() {
        // Same positions, orbPct=100 → maxOrb=10 → deviation=6 found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 6.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction], orbPct: 100),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
    }

    @Test("AspectsOrchestrator: reduced factor orbPercentage for both factors shrinks maxOrb")
    func testBothFactorOrbPercentagesReduced() {
        // Sun 50%, Moon 50%; conjunction 100%; baseOrb=10
        // maxOrb = max(0.5, 0.5) * 1.0 * 10 = 5 → deviation=6 > 5 → not found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 6.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: FactorConfig(factorSettings: [
                FactorSettings(factor: .sun, isUsed: true, isDrawn: false, orbPercentage: 50),
                FactorSettings(factor: .moon, isUsed: true, isDrawn: false, orbPercentage: 50)
            ]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.isEmpty)
    }

    @Test("AspectsOrchestrator: higher factor orbPercentage dominates via max()")
    func testFactorOrbPercentageMaxDominates() {
        // Sun 100%, Moon 50%; max(1.0, 0.5) = 1.0 → maxOrb=10 → deviation=6 found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 6.0)])
        let result = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: FactorConfig(factorSettings: [
                FactorSettings(factor: .sun, isUsed: true, isDrawn: false, orbPercentage: 100),
                FactorSettings(factor: .moon, isUsed: true, isDrawn: false, orbPercentage: 50)
            ]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig()
        )
        #expect(result.count == 1)
    }

    @Test("AspectsOrchestrator: larger baseOrb allows aspects that smaller baseOrb excludes")
    func testBaseOrbScaling() {
        // Sun=0, Moon=12; baseOrb=10 → maxOrb=10 < 12 → not found
        // baseOrb=15 → maxOrb=15 ≥ 12 → found
        let chart = Self.makeChart([(.sun, 0.0), (.moon, 12.0)])
        let smallOrb = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig(baseOrb: 10.0)
        )
        let largeOrb = AspectsOrchestrator.calculate(
            chart: chart,
            factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            orbConfig: Self.orbConfig(baseOrb: 15.0)
        )
        #expect(smallOrb.isEmpty)
        #expect(largeOrb.count == 1)
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

    private static func factorConfig(_ factors: [Factors], orbPct: Int = 100) -> FactorConfig {
        FactorConfig(factorSettings: factors.map {
            FactorSettings(factor: $0, isUsed: true, isDrawn: false, orbPercentage: orbPct)
        })
    }

    private static func aspectConfig(_ aspects: [Aspects], orbPct: Int = 100) -> AspectConfig {
        AspectConfig(aspectSettings: aspects.map {
            AspectSettings(aspect: $0, isUsed: true, isDrawn: false, orbPercentage: orbPct)
        })
    }

    private static func orbConfig(baseOrb: Double = 10.0) -> OrbConfig {
        OrbConfig(aspectBaseOrb: baseOrb)
    }
}
