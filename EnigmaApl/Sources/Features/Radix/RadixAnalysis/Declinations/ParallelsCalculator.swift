// ParallelsCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// A found parallel or contra-parallel between two chart factors.
///
/// - `factor1`, `factor2`: the two factors forming the parallel.
/// - `isContraParallel`: `true` when the factors are on opposite sides of the equator
///   (one north, one south); `false` for a regular parallel (same side).
/// - `maxOrb`: the configured maximum orb that was used.
/// - `actualOrb`: the actual angular distance between the absolute declination values.
struct DefinedParallel {
    let factor1: Factors
    let factor2: Factors
    let isContraParallel: Bool
    let maxOrb: Double
    let actualOrb: Double
}

/// Calculates parallels and contra-parallels from a chart.
///
/// A **parallel** occurs when two factors have (approximately) the same absolute
/// declination value and are on the **same** side of the celestial equator.
/// A **contra-parallel** occurs when they have the same absolute declination but
/// are on **opposite** sides.
///
/// The orb used is `OrbConfig.parallelOrb`.
struct ParallelsCalculator {

    /// Find all parallels and contra-parallels for the active factors in a chart.
    ///
    /// - Parameters:
    ///   - chart: The calculated chart containing equatorial positions.
    ///   - factorConfig: Determines which factors are active (`isUsed == true`).
    ///   - orbConfig: Supplies `parallelOrb`.
    /// - Returns: All `DefinedParallel` instances whose actual orb ≤ `parallelOrb`.
    static func parallels(
        chart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig
    ) -> [DefinedParallel] {
        let maxOrb = orbConfig.parallelOrb

        // Collect (factor, declination) pairs for every active factor that has a position.
        let pairs: [(Factors, Double)] = factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> (Factors, Double)? in
                guard let decl = DeclMidpointsCalculator.declination(for: settings.factor, in: chart) else { return nil }
                return (settings.factor, decl)
            }

        var results: [DefinedParallel] = []

        for i in 0 ..< pairs.count {
            let (factor1, decl1) = pairs[i]
            for j in (i + 1) ..< pairs.count {
                let (factor2, decl2) = pairs[j]
                let actualOrb = abs(abs(decl1) - abs(decl2))
                guard actualOrb <= maxOrb else { continue }
                let isContra = (decl1 >= 0.0) != (decl2 >= 0.0)
                results.append(DefinedParallel(
                    factor1:          factor1,
                    factor2:          factor2,
                    isContraParallel: isContra,
                    maxOrb:           maxOrb,
                    actualOrb:        actualOrb
                ))
            }
        }

        return results
    }
}
