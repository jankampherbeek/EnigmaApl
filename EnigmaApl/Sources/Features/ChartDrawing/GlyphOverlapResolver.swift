// GlyphOverlapResolver.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct GlyphOverlapResolver {

    /// Resolves overlapping glyph positions.
    /// - Parameters:
    ///   - items: Planet items whose plotAngle may be adjusted (their mundaneAngle is left untouched).
    ///   - minDistance: Minimum angular separation in degrees (default 6°).
    /// - Returns: Items sorted by mundaneAngle, with adjusted plotAngles.
    static func resolve(_ items: [WheelPlotItem], minDistance: Double = WheelMetrics.minGlyphDistance) -> [WheelPlotItem] {
        guard items.count > 1 else { return items }

        var sorted = items.sorted { $0.mundaneAngle < $1.mundaneAngle }
        let plot = resolvedPlotAngles(for: sorted.map { $0.mundaneAngle }, minDistance: minDistance)
        for i in sorted.indices { sorted[i].plotAngle = plot[i] }
        return sorted
    }

    /// Spreads a set of angles (in degrees, any range) so that neighbours are at least
    /// `minDistance` apart, while keeping every glyph as close as possible to its true angle.
    ///
    /// Isolated angles are left exactly where they are; only crowded clusters are fanned out, and
    /// each cluster stays centred on its original centre of mass. Handles the full circle (including
    /// wrap-around) and coincident angles (a stellium, or hard-aspect factors that collapse onto the
    /// same dial point). Returns the adjusted angles in the **same order** as the input.
    static func resolvedPlotAngles(for angles: [Double],
                                   minDistance: Double = WheelMetrics.minGlyphDistance) -> [Double] {
        let n = angles.count
        guard n > 1 else { return angles }

        // The separation can never exceed an even distribution around the whole circle.
        let gap = Swift.min(minDistance, 360.0 / Double(n))

        let norm = angles.map { WheelGeometry.normalise($0) }
        let order = Array(0..<n).sorted { norm[$0] < norm[$1] }

        // Put the "seam" at the largest gap between neighbours, so the circle can be treated as a
        // line: walking from the seam, positions only ever increase and never need to wrap.
        var seam = 0
        var maxGap = 360.0 - (norm[order[n - 1]] - norm[order[0]])   // wrap-around gap
        for k in 1..<n {
            let g = norm[order[k]] - norm[order[k - 1]]
            if g > maxGap { maxGap = g; seam = k }
        }

        // Linearise from the seam into non-decreasing offsets in [0, 360).
        let start = norm[order[seam]]
        var lin = [Double](repeating: 0, count: n)
        for k in 0..<n {
            var a = norm[order[(seam + k) % n]] - start
            if a < 0 { a += 360 }
            lin[k] = a
        }

        // Forward pass: enforce the minimum gap (only ever pushes elements to the right).
        var x = lin
        for k in 1..<n { x[k] = Swift.max(x[k], x[k - 1] + gap) }

        // Re-centre each tightly packed run on its original centre of mass, so isolated glyphs stay
        // put and clusters fan out symmetrically around their true position rather than drifting.
        var k = 0
        while k < n {
            var j = k
            while j + 1 < n && abs(x[j + 1] - x[j] - gap) < 1e-6 { j += 1 }
            if j > k {
                let count = Double(j - k + 1)
                let origCentre = (k...j).reduce(0.0) { $0 + lin[$1] } / count
                let curCentre  = (k...j).reduce(0.0) { $0 + x[$1] } / count
                var shift = origCentre - curCentre                          // <= 0: runs only move left
                if k > 0 { shift = Swift.max(shift, (x[k - 1] + gap) - x[k]) } // never hit the left neighbour
                if shift != 0 { for m in k...j { x[m] += shift } }
            }
            k = j + 1
        }

        // Map back to the input order, as absolute normalised angles.
        var result = [Double](repeating: 0, count: n)
        for k in 0..<n {
            result[order[(seam + k) % n]] = WheelGeometry.normalise(start + x[k])
        }
        return result
    }
}
