// ReferenceChartFixture.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
@testable import EnigmaApl

/// Contents of Fixtures/ReferenceCharts.json: charts with known positions.
/// Enum values are written by case name ("placidus", "lahiri") so the file stays readable.
struct ReferenceChartFile: Codable {
    let cases: [ReferenceChartCase]
}

struct ReferenceChartCase: Codable {
    let id: String
    let description: String
    /// Where the expected values come from, e.g. "Enigma .NET 1.4" or "Baseline recorded from EnigmaApl".
    let source: String
    /// True when the expected values were checked against an independent source.
    let verified: Bool
    /// Description of a known bug in the house calculation for this case. The houses are then not
    /// compared (expected.houses must be null); cover the bug with a separate test using `withKnownIssue`.
    let knownIssue: String?
    let input: ReferenceChartInput
    let tolerance: ReferenceTolerance?
    /// Nil for a new case: the test then fails and prints the calculated values to paste into the file.
    let expected: ReferenceChartExpected?
}

struct ReferenceChartInput: Codable {
    /// Date in UT as yyyy-mm-dd; years before 1 are astronomical (0 = 1 BCE).
    let date: String
    /// Time in UT as hh:mm:ss.
    let timeUT: String
    let calendar: String          // "gregorian" or "julian"
    let latitude: Double          // north positive
    let longitude: Double         // east positive
    let height: Double
    let houseSystem: String
    let ayanamsha: String
    let observerPosition: String
    let projectionType: String
    let lunarNodeType: String
    let factors: [String]
}

/// Tolerances in degrees (speeds in degrees per day).
struct ReferenceTolerance: Codable {
    var positions: Double = 1.0 / 3600.0     // 1 arc second
    var houses: Double = 1.0 / 3600.0
    var speeds: Double = 1.0e-5
}

struct ReferenceChartExpected: Codable {
    let julianDay: Double
    let obliquity: Double
    let factors: [String: ReferenceFactorPosition]
    let omittedFactors: [String]
    /// Factors that have no meaning for the observer position (heliocentric charts); nil means not checked.
    let skippedFactors: [String]?
    let houses: ReferenceHouses?
}

struct ReferenceFactorPosition: Codable {
    let longitude: Double
    let latitude: Double
    let longitudeSpeed: Double
    let rightAscension: Double
    let declination: Double
}

struct ReferenceHouses: Codable {
    let cusps: [Double]
    let ascendant: Double
    let midheaven: Double
}

// MARK: - Conversion between fixture and domain

enum ReferenceChartError: Error, CustomStringConvertible {
    case unknownName(type: String, name: String)
    case invalidDate(String)
    case invalidTime(String)
    case fixtureNotFound

    var description: String {
        switch self {
        case .unknownName(let type, let name): return "Unknown \(type) '\(name)' in ReferenceCharts.json"
        case .invalidDate(let date): return "Invalid date '\(date)' in ReferenceCharts.json, expected yyyy-mm-dd"
        case .invalidTime(let time): return "Invalid time '\(time)' in ReferenceCharts.json, expected hh:mm:ss"
        case .fixtureNotFound: return "ReferenceCharts.json not found in the test bundle"
        }
    }
}

/// Finds an enum case by its Swift case name, e.g. "placidus" → HouseSystems.placidus.
func enumCase<T: CaseIterable>(_ type: T.Type, named name: String) throws -> T {
    guard let value = T.allCases.first(where: { "\($0)" == name }) else {
        throw ReferenceChartError.unknownName(type: "\(T.self)", name: name)
    }
    return value
}

private final class ReferenceBundleToken {}

extension ReferenceChartFile {
    static func load() throws -> ReferenceChartFile {
        guard let url = Bundle(for: ReferenceBundleToken.self).url(forResource: "ReferenceCharts", withExtension: "json") else {
            throw ReferenceChartError.fixtureNotFound
        }
        return try JSONDecoder().decode(ReferenceChartFile.self, from: Data(contentsOf: url))
    }
}

extension ReferenceChartInput {
    func astronomicalDate() throws -> AstronomicalDate {
        // A leading "-" belongs to the year, so split from the end.
        let parts = date.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count >= 3,
              let day = Int(parts[parts.count - 1]),
              let month = Int(parts[parts.count - 2]),
              let year = Int(parts[0..<(parts.count - 2)].joined(separator: "-")) else {
            throw ReferenceChartError.invalidDate(date)
        }
        return AstronomicalDate(Year: year, Month: month, Day: day, Gregorian: calendar == "gregorian")
    }

    func astronomicalTime() throws -> AstronomicalTime {
        let parts = timeUT.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 3 else { throw ReferenceChartError.invalidTime(timeUT) }
        return AstronomicalTime(Hour: parts[0], Minute: parts[1], Second: parts[2])
    }

    func calculationConfig() throws -> CalculationConfig {
        CalculationConfig(
            houseSystem: try enumCase(HouseSystems.self, named: houseSystem),
            ayanamsha: try enumCase(Ayanamshas.self, named: ayanamsha),
            observerPosition: try enumCase(ObserverPositions.self, named: observerPosition),
            projectionType: try enumCase(ProjectionTypes.self, named: projectionType),
            lunarNodeType: try enumCase(LunarNodeTypes.self, named: lunarNodeType)
        )
    }

    /// Builds the request the same way the app does for a chart entered by the user.
    func calcRequest(seWrapper: SEWrapper) throws -> CalcRequest {
        let config = try calculationConfig()
        return CalcRequest(
            JulianDay: seWrapper.julianDay(date: try astronomicalDate(), time: try astronomicalTime()),
            FactorsToUse: try factors.map { try enumCase(Factors.self, named: $0) },
            HouseSystem: Int(config.houseSystem.seId.asciiValue ?? 80),
            Latitude: latitude,
            Longitude: longitude,
            Height: height,
            calculationConfig: config
        )
    }
}

extension ReferenceChartExpected {
    /// The expected values as calculated now; used to record a new case.
    init(chart: FullChart, houseSystem: HouseSystems) {
        var factors: [String: ReferenceFactorPosition] = [:]
        for (factor, position) in chart.Coordinates {
            guard let ecl = position.ecliptical.first, let equ = position.equatorial.first else { continue }
            factors["\(factor)"] = ReferenceFactorPosition(
                longitude: ecl.mainPos,
                latitude: ecl.deviation,
                longitudeSpeed: ecl.mainPosSpeed,
                rightAscension: equ.mainPos,
                declination: equ.deviation
            )
        }
        let houses = chart.HousePositions
        self.init(
            julianDay: chart.JulianDay,
            obliquity: chart.Obliquity,
            factors: factors,
            omittedFactors: chart.omittedFactors.map { "\($0)" }.sorted(),
            skippedFactors: chart.skippedFactors.map { "\($0)" }.sorted(),
            houses: houseSystem == .noHouses ? nil : ReferenceHouses(
                cusps: houses.cusps.map(\.longitude),
                ascendant: houses.ascendant.longitude,
                midheaven: houses.midheaven.longitude
            )
        )
    }

    func prettyJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return "" }
        return String(decoding: data, as: UTF8.self)
    }
}

/// Smallest difference between two angles in degrees, so 359.9999 and 0.0001 are close.
func angularDifference(_ a: Double, _ b: Double) -> Double {
    let diff = abs(a - b).truncatingRemainder(dividingBy: 360.0)
    return min(diff, 360.0 - diff)
}
