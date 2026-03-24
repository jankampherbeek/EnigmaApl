// FactorDisplaySelector.swift
// EnigmaApl
//
// Determines which factors should be shown in the chart wheel.
// A factor is drawn when both isUsed (calculate) and isDrawn (show) are true
// in the active FactorConfig.
//
// Follows the same pattern as GlyphSelector: configure once on startup
// and whenever the active configuration changes.

import Foundation

struct FactorDisplaySelector {
    private init() {}

    private static var drawnFactors: Set<Factors> = defaultDrawnFactors()

    /// Updates the set of drawable factors from the active factor configuration.
    /// Call on app launch and whenever the active configuration changes.
    static func configure(with factorConfig: FactorConfig) {
        drawnFactors = Set(
            factorConfig.factorSettings
                .filter { $0.isUsed && $0.isDrawn }
                .map { $0.factor }
        )
    }

    /// Returns true if the factor should be drawn in the chart wheel.
    static func shouldDraw(_ factor: Factors) -> Bool {
        drawnFactors.contains(factor)
    }

    // MARK: - Private

    private static func defaultDrawnFactors() -> Set<Factors> {
        Set(
            FactorConfig.defaultSettings
                .filter { $0.isUsed && $0.isDrawn }
                .map { $0.factor }
        )
    }
}
