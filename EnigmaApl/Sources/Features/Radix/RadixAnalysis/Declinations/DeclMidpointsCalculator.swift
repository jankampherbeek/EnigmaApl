// DeclMidpointsCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// A midpoint between two factors expressed in declination.
///
/// `position` is the arithmetic mean of the two declinations, in degrees
/// (negative = south, positive = north).
struct DeclBaseMidpoint {
    let factor1: Factors
    let factor2: Factors
    /// Declination of the midpoint in degrees (negative = south).
    let position: Double
}

/// A factor whose declination coincides with a declination midpoint within the allowed orb.
struct DeclOccupiedMidpoint {
    /// The base midpoint that is occupied.
    let midpoint: DeclBaseMidpoint
    /// The factor that occupies the midpoint position.
    let occupyingFactor: Factors
    /// Declination of the occupying factor in degrees.
    let occupyingPosition: Double
    /// Actual deviation from the exact midpoint position (always ≥ 0).
    let actualOrb: Double
    /// Exactness as a percentage: 100 = exact, 0 = at the orb boundary.
    let exactness: Double
}

/// Calculates occupied midpoints in declination.
///
/// The algorithm mirrors `DeclMidpointsHandler` / `OccupiedMidpointsFinder` from Enigma Suite:
///
/// 1. Collect the declination for every active factor in the chart.
/// 2. Compute all pair midpoints: `midpoint = (decl1 + decl2) / 2`.
/// 3. For each midpoint, test every active factor: `deviation = |midpointPos − factorDecl|`.
/// 4. If `deviation ≤ orb`, record a `DeclOccupiedMidpoint` with
///    `exactness = 100 − (deviation / orb × 100)`.
///
/// Unlike ecliptic midpoints there is no circular wrap-around: declination is a
/// linear scale from roughly −90° to +90°.
struct DeclMidpointsCalculator {

    /// Find all occupied midpoints in declination for the active factors in a chart.
    ///
    /// - Parameters:
    ///   - chart: The calculated chart containing equatorial positions.
    ///   - factorConfig: Determines which factors are active (`isUsed == true`).
    ///   - orbConfig: Supplies `midpoint360DialOrb` as the orb for declination midpoints.
    /// - Returns: All occupied midpoints sorted by `actualOrb` ascending (most exact first).
    static func occupiedMidpoints(
        chart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig
    ) -> [DeclOccupiedMidpoint] {
        let orb = orbConfig.midpoint360DialOrb

        // Collect (factor, declination) for every active factor present in the chart.
        let pairs: [(Factors, Double)] = factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> (Factors, Double)? in
                guard let pos = chart.Coordinates[settings.factor],
                      let eq  = pos.equatorial.first else { return nil }
                return (settings.factor, eq.deviation)
            }

        guard pairs.count >= 2 else { return [] }

        // Build all base midpoints in declination.
        var baseMidpoints: [DeclBaseMidpoint] = []
        for i in 0 ..< pairs.count {
            for j in (i + 1) ..< pairs.count {
                let (f1, d1) = pairs[i]
                let (f2, d2) = pairs[j]
                // Arithmetic mean — identical to the C# shift-by-100 trick,
                // which just avoids negatives before averaging.
                let midPos = (d1 + d2) / 2.0
                baseMidpoints.append(DeclBaseMidpoint(factor1: f1, factor2: f2, position: midPos))
            }
        }

        // For each base midpoint check every factor for occupation.
        var results: [DeclOccupiedMidpoint] = []
        for midpoint in baseMidpoints {
            for (factor, declination) in pairs {
                let deviation = abs(midpoint.position - declination)
                guard deviation <= orb else { continue }
                let exactness = orb > 0 ? 100.0 - (deviation / orb * 100.0) : 100.0
                results.append(DeclOccupiedMidpoint(
                    midpoint:          midpoint,
                    occupyingFactor:   factor,
                    occupyingPosition: declination,
                    actualOrb:         deviation,
                    exactness:         exactness
                ))
            }
        }

        return results.sorted { $0.actualOrb < $1.actualOrb }
    }
}
