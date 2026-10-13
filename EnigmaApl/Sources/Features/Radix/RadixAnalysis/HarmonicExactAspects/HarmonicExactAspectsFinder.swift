// HarmonicExactAspectsFinder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Finds the aspect(s) with the smallest orb between a set of harmonic positions.
struct HarmonicExactAspectsFinder {

    private init() {}

    /// Orbs that differ less than this are considered equal; all of them are returned.
    private static let tieTolerance = 1e-8

    /// Returns the aspect(s) with the smallest orb between the positions, for the given harmonic.
    /// No orb limit is applied: the closest aspect is always returned when there are at least two positions.
    /// Pairs with a fixed distance (see `ImplicitAspects`) are skipped.
    static func find(positions: [HarmonicPosition], aspects: [Aspects], harmonic: Int) -> [HarmonicExactAspect] {
        guard positions.count >= 2, !aspects.isEmpty else { return [] }

        var best: [HarmonicExactAspect] = []
        var bestOrb = Double.greatestFiniteMagnitude

        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let p1 = positions[i]
                let p2 = positions[j]
                if ImplicitAspects.isImplicit(p1.factor, p2.factor) { continue }
                let distance = shortestDistance(p1.longitude, p2.longitude)

                for aspect in aspects {
                    let orb = abs(distance - aspect.angle)
                    if orb < bestOrb - tieTolerance {
                        bestOrb = orb
                        best = []
                    }
                    if abs(orb - bestOrb) <= tieTolerance {
                        best.append(HarmonicExactAspect(harmonic: harmonic, factor1: p1.factor,
                                                        factor2: p2.factor, aspect: aspect, orb: orb))
                    }
                }
            }
        }
        return best
    }

    /// Shortest angular distance between two longitudes, in the range 0–180°.
    private static func shortestDistance(_ long1: Double, _ long2: Double) -> Double {
        let diff = abs(long1 - long2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }
}
