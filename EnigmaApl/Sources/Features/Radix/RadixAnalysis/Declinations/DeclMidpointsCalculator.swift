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

/// Computes all base midpoints in declination for the active factors in a chart.
///
/// Declination midpoints are arithmetic means: `midpoint = (decl1 + decl2) / 2`.
/// There is no circular wrap-around — declination is a linear scale from roughly −90° to +90°.
struct DeclMidpointsCalculator {

    /// Returns all pair midpoints in declination for the active factors present in the chart.
    ///
    /// - Parameters:
    ///   - chart: The calculated chart containing equatorial positions.
    ///   - factorConfig: Determines which factors are active (`isUsed == true`).
    /// - Returns: All base midpoints (n*(n-1)/2 for n active factors). Order is not guaranteed.
    static func baseMidpoints(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [DeclBaseMidpoint] {
        let pairs = activePairs(chart: chart, factorConfig: factorConfig)
        guard pairs.count >= 2 else { return [] }

        var result: [DeclBaseMidpoint] = []
        for i in 0 ..< pairs.count {
            for j in (i + 1) ..< pairs.count {
                let (f1, d1) = pairs[i]
                let (f2, d2) = pairs[j]
                result.append(DeclBaseMidpoint(factor1: f1, factor2: f2, position: (d1 + d2) / 2.0))
            }
        }
        return result
    }

    /// Returns (factor, declination) for every active factor present in the chart.
    static func activePairs(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [(Factors, Double)] {
        factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> (Factors, Double)? in
                guard let decl = declination(for: settings.factor, in: chart) else { return nil }
                return (settings.factor, decl)
            }
    }

    /// Returns the declination for a factor, checking both planet coordinates and house positions.
    static func declination(for factor: Factors, in chart: FullChart) -> Double? {
        longAndDeclination(for: factor, in: chart)?.1
    }

    /// Returns (longitude, declination) for a factor, checking both planet coordinates and house positions.
    static func longAndDeclination(for factor: Factors, in chart: FullChart) -> (Double, Double)? {
        if let pos = chart.Coordinates[factor],
           let ecl = pos.ecliptical.first,
           let eq  = pos.equatorial.first {
            return (ecl.mainPos, eq.deviation)
        }
        let cusp: FullCuspPosition?
        switch factor {
        case .ascendant: cusp = chart.HousePositions.ascendant
        case .mc:        cusp = chart.HousePositions.midheaven
        case .eastPoint: cusp = chart.HousePositions.eastpoint
        case .vertex:    cusp = chart.HousePositions.vertex
        default:         cusp = nil
        }
        guard let c = cusp else { return nil }
        return (c.longitude, c.declination)
    }
}
