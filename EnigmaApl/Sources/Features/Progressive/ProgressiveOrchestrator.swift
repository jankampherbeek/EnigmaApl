// ProgressiveOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

enum ProgressiveOrchestratorError: Error {
    case noActiveConfiguration
    case missingNatalJulianDay
}

private let TROPICAL_YEAR_IN_DAYS = 365.242199074

/// Dispatches progressive calculations to the appropriate technique
/// and returns the resulting positions keyed by factor.
///
/// SEWrapper is created locally per call, consistent with the pattern used in
/// ResearchPipelineOrchestrator and AnalysisOrchestrator — it is not thread-safe
/// and must not be shared across calls or stored as a property on a non-actor type.
@MainActor
struct ProgressiveOrchestrator {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Public API

    /// Calculates progressive positions for the given request.
    /// Dispatches to the appropriate technique based on `request.method`.
    /// - Returns: Positions keyed by `Factors`. Returns an empty dictionary for
    ///   methods that are not yet implemented.
    func progressivePositions(_ request: ProgressiveCalcRequest) throws -> [Factors: ProgressivePosition] {
        switch request.method {
        case .transit:    return try calculateTransits(request: request)
        case .secdir:     return try calculateSecondaryDirections(request: request)
        case .symdir:     return [:]   // TODO: symbolic directions
        case .primdir:    return [:]   // TODO: primary directions
        case .solar:      return [:]   // TODO: solar return
        case .profection: return [:]   // TODO: profections
        case .firdaria:   return [:]   // TODO: firdaria
        }
    }

    // MARK: - Transits

    private func calculateTransits(request: ProgressiveCalcRequest) throws -> [Factors: ProgressivePosition] {
        let userConfig = try fetchActiveConfig()
        let factors    = userConfig.progressionsConfig.transits.factors
        let calcConfig = userConfig.calculationConfig
        let seWrapper  = SEWrapper()
        return ProgressiveCalculator.performCalculation(
            request,
            calculationConfig: calcConfig,
            factors: factors,
            seWrapper: seWrapper
        )
    }

    // MARK: - Secondary directions

    /// Each year of life equals one day in secondary directions.
    /// sdJD = natalJD + (eventJD − natalJD) / TROPICAL_YEAR_IN_DAYS
    private func calculateSecondaryDirections(request: ProgressiveCalcRequest) throws -> [Factors: ProgressivePosition] {
        guard let natalJD = request.natalJulianDay else {
            throw ProgressiveOrchestratorError.missingNatalJulianDay
        }
        let userConfig = try fetchActiveConfig()
        let factors    = userConfig.progressionsConfig.secondaryDirections.factors
        let calcConfig = userConfig.calculationConfig
        let seWrapper  = SEWrapper()

        let ageInDays  = request.julianDay - natalJD
        let sdJD       = natalJD + ageInDays / TROPICAL_YEAR_IN_DAYS

        let sdRequest  = ProgressiveCalcRequest(julianDay: sdJD, method: .secdir)
        return ProgressiveCalculator.performCalculation(
            sdRequest,
            calculationConfig: calcConfig,
            factors: factors,
            seWrapper: seWrapper
        )
    }

    // MARK: - Helpers

    private func fetchActiveConfig() throws -> UserConfiguration {
        let descriptor = FetchDescriptor<UserConfiguration>(
            predicate: #Predicate { $0.isActive == true }
        )
        guard let config = try context.fetch(descriptor).first else {
            throw ProgressiveOrchestratorError.noActiveConfiguration
        }
        return config
    }
}
