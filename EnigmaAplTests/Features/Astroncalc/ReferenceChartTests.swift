// ReferenceChartTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Compares complete chart calculations with the charts in Fixtures/ReferenceCharts.json.
///
/// Adding a chart: add a case with "expected": null and run the tests. The test fails and prints the
/// calculated values; check them against an independent source, paste them into the file as "expected"
/// and set "verified" and "source" accordingly.
@MainActor
@Suite(.tags(.integration, .reference))
struct ReferenceChartTests {

    nonisolated private static let cases: [ReferenceChartCase] = (try? ReferenceChartFile.load().cases) ?? []

    @Test func fixtureFileIsReadable() throws {
        let file = try ReferenceChartFile.load()
        #expect(!file.cases.isEmpty)
        #expect(Set(file.cases.map(\.id)).count == file.cases.count, "Case ids must be unique")
    }

    @Test(arguments: cases.map(\.id))
    func chartMatchesReference(id: String) throws {
        let reference = try #require(Self.cases.first { $0.id == id })
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = try reference.input.calcRequest(seWrapper: seWrapper)
        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let actual = ReferenceChartExpected(chart: chart, houseSystem: request.calculationConfig.houseSystem)

        guard let expected = reference.expected else {
            Issue.record("""
                Reference case '\(id)' has no expected values. Calculated values:
                \(actual.prettyJSON())
                """)
            return
        }
        let tolerance = reference.tolerance ?? ReferenceTolerance()

        #expect(abs(actual.julianDay - expected.julianDay) < 1e-8, "[\(id)] Julian Day")
        #expect(abs(actual.obliquity - expected.obliquity) < tolerance.positions, "[\(id)] obliquity")
        #expect(actual.omittedFactors == expected.omittedFactors.sorted(), "[\(id)] omitted factors")
        if let expectedSkipped = expected.skippedFactors {
            #expect(actual.skippedFactors == expectedSkipped.sorted(), "[\(id)] skipped factors")
        }
        #expect(Set(actual.factors.keys) == Set(expected.factors.keys), "[\(id)] calculated factors")

        for (name, exp) in expected.factors.sorted(by: { $0.key < $1.key }) {
            guard let act = actual.factors[name] else { continue }
            expectAngle(act.longitude, exp.longitude, tolerance.positions, "[\(id)] \(name) longitude")
            expectValue(act.latitude, exp.latitude, tolerance.positions, "[\(id)] \(name) latitude")
            expectValue(act.longitudeSpeed, exp.longitudeSpeed, tolerance.speeds, "[\(id)] \(name) speed")
            expectAngle(act.rightAscension, exp.rightAscension, tolerance.positions, "[\(id)] \(name) right ascension")
            expectValue(act.declination, exp.declination, tolerance.positions, "[\(id)] \(name) declination")
        }

        if reference.knownIssue != nil {
            // Houses of this case are wrong at the moment; a separate test covers the bug.
            #expect(expected.houses == nil, "[\(id)] a case with a known issue must not contain expected houses")
            return
        }
        #expect((actual.houses == nil) == (expected.houses == nil), "[\(id)] houses present")
        if let actHouses = actual.houses, let expHouses = expected.houses {
            #expect(actHouses.cusps.count == expHouses.cusps.count, "[\(id)] number of cusps")
            for (index, (act, exp)) in zip(actHouses.cusps, expHouses.cusps).enumerated() {
                expectAngle(act, exp, tolerance.houses, "[\(id)] cusp \(index + 1)")
            }
            expectAngle(actHouses.ascendant, expHouses.ascendant, tolerance.houses, "[\(id)] ascendant")
            expectAngle(actHouses.midheaven, expHouses.midheaven, tolerance.houses, "[\(id)] midheaven")
        }
    }

    private func expectAngle(_ actual: Double, _ expected: Double, _ tolerance: Double, _ label: String,
                             sourceLocation: SourceLocation = #_sourceLocation) {
        let diff = angularDifference(actual, expected)
        #expect(diff <= tolerance, "\(label): expected \(expected), got \(actual) (difference \(diff * 3600)″)",
                sourceLocation: sourceLocation)
    }

    private func expectValue(_ actual: Double, _ expected: Double, _ tolerance: Double, _ label: String,
                             sourceLocation: SourceLocation = #_sourceLocation) {
        let diff = abs(actual - expected)
        #expect(diff <= tolerance, "\(label): expected \(expected), got \(actual) (difference \(diff))",
                sourceLocation: sourceLocation)
    }
}
