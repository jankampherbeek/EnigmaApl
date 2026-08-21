// CountingsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Element/cross counts (by zodiac sign) for the factors currently active in the configuration.
/// Unlike the BLA schema (fixed point set), this always follows the app's regular `FactorConfig`.
enum CountingsOrchestrator {

    static func elementsAndCrosses(chart: FullChart, factorConfig: FactorConfig) -> (elements: [CountingsLine], crosses: [CountingsLine]) {
        let usedFactors = Set(factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })

        var signCounts: [Int: Int] = Dictionary(uniqueKeysWithValues: (1...12).map { ($0, 0) })
        for (factor, position) in chart.Coordinates where usedFactors.contains(factor) {
            guard let longitude = position.ecliptical.first?.mainPos else { continue }
            signCounts[sign(forLongitude: longitude), default: 0] += 1
        }

        let elements = groupedLines(kinds: [.fire, .earth, .air, .water], signCounts: signCounts, groupFor: CountingsGroup.elementFor)
        let crosses = groupedLines(kinds: [.cardinal, .fixed, .mutable], signCounts: signCounts, groupFor: CountingsGroup.crossFor)
        return (elements, crosses)
    }

    // MARK: - Private helpers

    private static func sign(forLongitude longitude: Double) -> Int {
        var lon = longitude.truncatingRemainder(dividingBy: 360.0)
        if lon < 0 { lon += 360.0 }
        return Int(lon / 30.0) + 1
    }

    private static func groupedLines(
        kinds: [CountingsGroup], signCounts: [Int: Int], groupFor: (Int) -> CountingsGroup?
    ) -> [CountingsLine] {
        var counts: [CountingsGroup: Int] = [:]
        for (sign, count) in signCounts {
            guard let group = groupFor(sign) else { continue }
            counts[group, default: 0] += count
        }
        return kinds.map { CountingsLine(group: $0, count: counts[$0] ?? 0) }
    }
}
