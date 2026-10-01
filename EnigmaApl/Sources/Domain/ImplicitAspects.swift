// ImplicitAspects.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Pairs of factors with a fixed distance between them. Any aspect between them is implicit,
/// so these pairs are omitted when calculating aspects within a single chart.
/// Not applicable to aspects between two different charts (transits, progressions, synastry).
enum ImplicitAspects {

    /// North Node, South Node, Dragon and Beast are all at fixed distances from each other.
    private static let nodeGroup: Set<Factors> = [.northNode, .southNode, .dragon, .beast]

    /// Each Priapus is calculated as the exact opposite of the corresponding Black Moon.
    private static let fixedPairs: [(Factors, Factors)] = [
        (.apogeeMean, .priapus),
        (.apogeeKoch, .priapusKoch),
        (.apogeeDuval, .priapusDuval),
        (.apogeeInterpolated, .priapusInterpolated),
        (.blackSun, .diamond)
    ]

    /// True if an aspect between the two factors is implicit and should be omitted.
    static func isImplicit(_ factor1: Factors, _ factor2: Factors) -> Bool {
        guard factor1 != factor2 else { return false }
        if nodeGroup.contains(factor1) && nodeGroup.contains(factor2) { return true }
        return fixedPairs.contains { ($0.0 == factor1 && $0.1 == factor2) || ($0.0 == factor2 && $0.1 == factor1) }
    }
}
