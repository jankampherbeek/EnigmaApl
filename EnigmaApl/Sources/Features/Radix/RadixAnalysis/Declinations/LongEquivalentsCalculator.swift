// LongEquivalentsCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The longitude equivalent for a single chart factor.
///
/// `longitudeEquivalent` is the ecliptic longitude (0–360°) that corresponds to
/// the factor's declination, taking obliquity and out-of-bounds status into account.
struct LongEquivalentResult {
    /// The factor this result belongs to.
    let factor: Factors
    /// Computed longitude equivalent in degrees (0–360°).
    let longitudeEquivalent: Double
    /// `true` when the factor's declination exceeds the obliquity (out of bounds).
    let isOutOfBounds: Bool
}

/// Calculates the longitude equivalent for every active factor in a chart.
///
/// The algorithm mirrors `LongitudeEquivalentHandler` from Enigma Suite:
///
/// 1. For each active factor collect its ecliptic longitude and equatorial declination.
/// 2. If `|declination| > obliquity` the factor is **out of bounds (OOB)**:
///    reflect its declination back inside the ecliptic band:
///    `reflected = sign(decl) × (obliquity − (|decl| − obliquity))`
/// 3. Convert the (possibly reflected) declination to a longitude candidate:
///    `candidate1 = asin(sin(decl) / sin(obliquity))` (degrees, normalised to 0–360).
/// 4. Compute a second candidate on the opposite arc:
///    `candidate2 = longitude < 180 ? 90 + (90 − c1) : 270 + (270 − c1)`.
/// 5. Return the candidate whose distance to the actual longitude is smaller.
struct LongEquivalentsCalculator {

    private init() {}

    /// Compute longitude equivalents for all active factors in a chart.
    ///
    /// - Parameters:
    ///   - chart: The calculated chart; supplies ecliptic longitude, equatorial
    ///     declination, and `Obliquity`.
    ///   - factorConfig: Determines which factors are active (`isUsed == true`).
    /// - Returns: One `LongEquivalentResult` per active factor that has both
    ///   ecliptic and equatorial data in the chart.
    static func equivalents(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [LongEquivalentResult] {
        let obliquity = chart.Obliquity

        return factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> LongEquivalentResult? in
                guard
                    let pos = chart.Coordinates[settings.factor],
                    let ecl = pos.ecliptical.first,
                    let eq  = pos.equatorial.first
                else { return nil }

                let longitude   = ecl.mainPos
                let rawDecl     = eq.deviation

                // OOB check and reflection
                var declination = rawDecl
                var oob         = false
                if abs(rawDecl) > obliquity {
                    let oobPart = abs(rawDecl) - obliquity
                    declination = rawDecl > 0 ? obliquity - oobPart : oobPart - obliquity
                    oob = true
                }

                // Convert declination → longitude (asin, degrees)
                let sinDecl = sin(declination * .pi / 180.0)
                let sinObl  = sin(obliquity   * .pi / 180.0)
                guard sinObl != 0.0 else { return nil }
                var candidate1 = asin(sinDecl / sinObl) * 180.0 / .pi
                if candidate1 < 0.0 { candidate1 += 360.0 }

                let candidate2 = longitude < 180.0
                    ? 90.0  + (90.0  - candidate1)
                    : 270.0 + (270.0 - candidate1)

                let diff1 = abs(candidate1 - longitude)
                let diff2 = abs(candidate2 - longitude)
                let equivalent = diff1 < diff2 ? candidate1 : candidate2

                return LongEquivalentResult(
                    factor:              settings.factor,
                    longitudeEquivalent: equivalent,
                    isOutOfBounds:       oob
                )
            }
    }
}
