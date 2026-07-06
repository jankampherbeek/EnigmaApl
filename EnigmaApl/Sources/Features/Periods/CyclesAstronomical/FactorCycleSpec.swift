// FactorCycleSpec.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Calculation parameters for a factor used in period/cycle calculations.
/// - `interval`: step size in days between calculated positions.
/// - `maxPeriod`: maximum allowed span between start and end date, in days.
struct FactorCycleSpec {
    let interval: Double
    let maxPeriod: Int
}

extension Factors {
    /// Returns the cycle spec for this factor, or nil if the factor is not supported in cycle calculations.
    var cycleSpec: FactorCycleSpec? {
        switch self {
        case .moon:
            return FactorCycleSpec(interval: 0.1, maxPeriod: 2_000)
        case .sun, .earth, .mercury, .venus, .mars, .pallas, .juno, .vesta, .apogeeMean:
            return FactorCycleSpec(interval: 1, maxPeriod: 20_000)
        case .jupiter, .saturn, .ceres:
            return FactorCycleSpec(interval: 5, maxPeriod: 200_000)
        case .uranus, .neptune, .pluto:
            return FactorCycleSpec(interval: 10, maxPeriod: 750_000)
        case .northNode, .southNode, .chiron, .pholus, .nessus, .huya:
            return FactorCycleSpec(interval: 10, maxPeriod: 200_000)
        case .priapus, .priapusKoch, .priapusDuval, .priapusInterpolated, .dragon, .beast, .diamond,
             .ascendant, .mc, .eastPoint, .vertex, .zeroAries, .parsfortuna:
            return nil
        default:
            return FactorCycleSpec(interval: 10, maxPeriod: 200_000)
        }
    }
}
