// ParansOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public struct ParansOrchestrator {

    private init() {}

    // MARK: - Public API

    /// Calculate paran times and matches for the given chart.
    /// - Parameters:
    ///   - chart: The active radix chart (supplies JD and already-computed factor positions).
    ///   - geoLon: Geographic longitude of the birth location (east positive).
    ///   - geoLat: Geographic latitude of the birth location (north positive).
    ///   - height: Height above sea level in metres.
    ///   - factorConfig: Active factor configuration (determines which factors to include).
    ///   - fixStarConfig: Active fixed-star configuration (determines star selection and time orb).
    ///   - calculationConfig: Calculation settings (ayanamsha, observer position).
    /// - Returns: A `ParansResult` with all transit times and paran matches.
    public static func calculate(
        chart: FullChart,
        geoLon: Double,
        geoLat: Double,
        height: Double,
        factorConfig: FactorConfig,
        fixStarConfig: FixStarConfig,
        calculationConfig: CalculationConfig
    ) -> ParansResult {
        calculate(chart: chart, geoLon: geoLon, geoLat: geoLat, height: height,
                  factorConfig: factorConfig, fixStarConfig: fixStarConfig,
                  calculationConfig: calculationConfig, seWrapper: SEWrapper())
    }

    /// SE-injectable overload used by tests to share a single SEWrapper instance.
    public static func calculate(
        chart: FullChart,
        geoLon: Double,
        geoLat: Double,
        height: Double,
        factorConfig: FactorConfig,
        fixStarConfig: FixStarConfig,
        calculationConfig: CalculationConfig,
        seWrapper: SEWrapper
    ) -> ParansResult {
        let jdUt = chart.JulianDay
        // Search for transits starting half a day before birth to capture the birth-day event.
        let searchFrom = jdUt - 0.5

        // Prepare wrapper for topocentric calculations when configured.
        if calculationConfig.observerPosition == .topoCentric {
            seWrapper.setTopocentric(geoLon: geoLon, geoLat: geoLat, height: height)
        }

        let activeFactors = activeFactorsFromChart(chart: chart, factorConfig: factorConfig)
        let activeStars   = activeStarsFromConfig(fixStarConfig: fixStarConfig)

        // Calculate transit times for factors.
        let factorTimes: [ParanTimesForBody] = activeFactors.map { factor in
            paranTimes(body: .factor(factor), ipl: factor.seId, starName: "",
                       searchFrom: searchFrom, geoLon: geoLon, geoLat: geoLat,
                       height: height, seWrapper: seWrapper)
        }

        // Calculate transit times for fixed stars using FixStarsOrchestrator for position check,
        // then swe_rise_trans for transit times.
        let starTimes: [ParanTimesForBody] = activeStars.map { star in
            let seName = "," + star.astronomicalName
            return paranTimes(body: .star(star), ipl: 0, starName: seName,
                              searchFrom: searchFrom, geoLon: geoLon, geoLat: geoLat,
                              height: height, seWrapper: seWrapper)
        }

        let allTimes = factorTimes + starTimes

        let orbDays = fixStarConfig.paranTimeOrb / 1440.0
        let matches = findMatches(allTimes: allTimes, factorTimes: factorTimes,
                                  starTimes: starTimes, orbDays: orbDays)

        return ParansResult(allTimes: allTimes, matches: matches)
    }

    // MARK: - Private helpers

    /// Returns used SE-calculated factors that are present in the chart.
    private static func activeFactorsFromChart(chart: FullChart, factorConfig: FactorConfig) -> [Factors] {
        let usedFactorSet = Set(
            factorConfig.factorSettings
                .filter { $0.isUsed && $0.factor.calculationType == .CommonSe }
                .map { $0.factor }
        )
        return chart.Coordinates.keys
            .filter { usedFactorSet.contains($0) }
            .sorted { $0.seId < $1.seId }
    }

    /// Returns the active fixed stars based on the current FixStarConfig.
    private static func activeStarsFromConfig(fixStarConfig: FixStarConfig) -> [StarDefinitions] {
        switch fixStarConfig.activeSelection {
        case .selfDefined:
            let usedStars = Set(
                fixStarConfig.fixStarSettings
                    .filter { $0.isUsed }
                    .map { $0.fixStar }
            )
            return StarDefinitions.allCases.filter { usedStars.contains($0) }
        case .magnitude:
            let limit = Double(fixStarConfig.magnitudeLimit)
            return StarDefinitions.allCases.filter { $0.magnitude <= limit }
        default:
            return FixStarsOrchestrator.getSelection(selection: fixStarConfig.activeSelection)
        }
    }

    /// Calculates all four paran transit times for one body.
    private static func paranTimes(
        body: ParanBody,
        ipl: Int,
        starName: String,
        searchFrom: Double,
        geoLon: Double,
        geoLat: Double,
        height: Double,
        seWrapper: SEWrapper
    ) -> ParanTimesForBody {
        func calc(_ type: ParanType) -> Double? {
            seWrapper.calculateParanTimes(jdUt: searchFrom, ipl: ipl, starName: starName,
                                          rsmi: type.rsmi, geoLon: geoLon,
                                          geoLat: geoLat, height: height)
        }
        return ParanTimesForBody(
            body: body,
            rising: calc(.rising),
            setting: calc(.setting),
            culmination: calc(.culmination),
            antiCulmination: calc(.antiCulmination)
        )
    }

    /// Finds paran matches: star+factor or factor+factor pairs whose transit times for ANY
    /// combination of event types (rising, setting, culmination, anti-culmination) differ
    /// by no more than `orbDays`. Star+star combinations are excluded.
    private static func findMatches(
        allTimes: [ParanTimesForBody],
        factorTimes: [ParanTimesForBody],
        starTimes: [ParanTimesForBody],
        orbDays: Double
    ) -> [ParanMatch] {
        var matches: [ParanMatch] = []

        for b1 in allTimes {
            for b2 in factorTimes {
                guard b1.body != b2.body else { continue }
                if case .star = b1.body, case .star = b2.body { continue }

                for type1 in ParanType.allCases {
                    guard let t1 = b1.time(for: type1) else { continue }
                    for type2 in ParanType.allCases {
                        guard let t2 = b2.time(for: type2) else { continue }
                        let diff = abs(t1 - t2)
                        if diff <= orbDays {
                            matches.append(ParanMatch(
                                body1: b1.body,
                                type1: type1,
                                body2: b2.body,
                                type2: type2,
                                exactTime: (t1 + t2) / 2.0,
                                orbMinutes: diff * 1440.0
                            ))
                        }
                    }
                }
            }
        }

        return matches.sorted { $0.orbMinutes < $1.orbMinutes }
    }
}
