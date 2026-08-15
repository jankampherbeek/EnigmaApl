// BlaSchemaCalculationsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation

@testable import EnigmaApl

/// Golden fixture ported verbatim from Enigma.Test/Integration/IntegrationTestBlaSchema.cs
/// (same longitudes, same expected sign/house counts), to verify the Swift port of the
/// BLA schema sign/house counting logic against the original C# implementation.
@MainActor
struct BlaSchemaCalculationsTests {

    private func makeChart() -> BlaChartLongitudes {
        let points: [Factors: Double] = [
            .sun: 136.6, .moon: 308.75, .mercury: 124.6, .venus: 99.95, .mars: 181.09,
            .jupiter: 103.3, .saturn: 1.35, .uranus: 61.12, .neptune: 1.85, .pluto: 302.25,
            .persephoneCarteret: 337.6, .vulcanusCarteret: 84.75, .apogeeMean: 225.0, .apogeeKoch: 224.1,
            .priapus: 45.0, .priapusKoch: 44.1, .blackSun: 103.55, .diamond: 283.55,
            .northNode: 338.6, .southNode: 168.6, .beast: 259.85, .dragon: 79.85,
            .parsfortuna: 88.85, .ascendant: 276.55, .mc: 222.65
        ]
        let cusps: [Int: Double] = [
            1: 276.55, 2: 327.11, 3: 13.52, 4: 42.65, 5: 62.7, 6: 79.58,
            7: 96.55, 8: 147.11, 9: 193.52, 10: 222.65, 11: 242.7, 12: 259.58
        ]
        return BlaChartLongitudes(points: points, cusps: cusps)
    }

    @Test("Sign counts match the golden fixture from Enigma.Test IntegrationTestBlaSchema")
    func signCounts() {
        let orchestrator = BlaSchemaOrchestrator(chart: makeChart(), useDecanates: false)
        let result = orchestrator.getSignCounts()
        #expect(result.count == 12)
        #expect(result[1] == 2)
        #expect(result[2] == 2)
        #expect(result[3] == 4)
        #expect(result[4] == 3)
        #expect(result[5] == 2)
        #expect(result[6] == 1)
        #expect(result[7] == 1)
        #expect(result[8] == 3)
        #expect(result[9] == 1)
        #expect(result[10] == 2)
        #expect(result[11] == 2)
        #expect(result[12] == 2)
    }

    @Test("House counts match the golden fixture from Enigma.Test IntegrationTestBlaSchema")
    func houseCounts() {
        let orchestrator = BlaSchemaOrchestrator(chart: makeChart(), useDecanates: false)
        let result = orchestrator.getHouseCounts()
        #expect(result.count == 12)
        #expect(result[1] == 3)
        #expect(result[2] == 4)
        #expect(result[3] == 0)
        #expect(result[4] == 3)
        #expect(result[5] == 0)
        #expect(result[6] == 3)
        #expect(result[7] == 5)
        #expect(result[8] == 2)
        #expect(result[9] == 0)
        #expect(result[10] == 2)
        #expect(result[11] == 0)
        #expect(result[12] == 1)
    }

    // Note: the C# `BlaSchemaOrchestrator.GetCrossELementCounts()` (Enigma.Core layer) is
    // dead code in the Windows app — the real UI is fed exclusively by `CrossElementPresFactory`
    // (Enigma.Frontend layer), which this Swift port's `BlaSchemaPresentables.crossesCounts`/
    // `elementsCounts` mirror instead. There is no usable golden fixture for that path, so this
    // is a structural sanity check rather than an exact-value comparison.
    @Test("Crosses and elements counts cover the same total points, just grouped differently")
    func crossesAndElementsCoverSameTotal() {
        let orchestrator = BlaSchemaOrchestrator(chart: makeChart(), useDecanates: false)
        let signCounts = orchestrator.getSignCounts()
        let houseCounts = orchestrator.getHouseCounts()
        let planetsInHouses = orchestrator.getPlanetsInHouses()
        let signsOnCusps = orchestrator.getSignsOnCusps()

        let crosses = BlaSchemaPresentables.crossesCounts(
            signCounts: signCounts, houseCounts: houseCounts, planetsInHouses: planetsInHouses, signOnCusps: signsOnCusps
        )
        let elements = BlaSchemaPresentables.elementsCounts(
            signCounts: signCounts, planetsInHouses: planetsInHouses, signOnCusps: signsOnCusps
        )

        #expect(crosses.count == 3)
        #expect(elements.count == 4)
        #expect(crosses.reduce(0) { $0 + $1.total } == elements.reduce(0) { $0 + $1.total })
    }

    @Test("Dispositors produce exactly 6 ruler-pair axes")
    func dispositorsCoverSixAxes() {
        let orchestrator = BlaSchemaOrchestrator(chart: makeChart(), useDecanates: false)
        let dispositors = orchestrator.getDispositors(useDecanates: false)
        #expect(dispositors.count == 6)
    }
}
