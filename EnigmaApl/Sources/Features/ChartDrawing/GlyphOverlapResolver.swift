// GlyphOverlapResolver.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct GlyphOverlapResolver {

    /// Resolves overlapping glyph positions.
    /// - Parameters:
    ///   - items: Planet items whose plotAngle may be adjusted.
    ///   - minDistance: Minimum angular separation in degrees (default 6°).
    /// - Returns: Items with adjusted plotAngles.
    static func resolve(_ items: [WheelPlotItem], minDistance: Double = WheelMetrics.minGlyphDistance) -> [WheelPlotItem] {
        guard items.count > 1 else { return items }

        // Sort by mundane angle
        var sorted = items.sorted { $0.mundaneAngle < $1.mundaneAngle }

        // Two-pass spreading to handle clusters
        for _ in 0..<3 {
            for i in 1..<sorted.count {
                let diff = angularDiff(sorted[i].plotAngle, sorted[i - 1].plotAngle)
                if diff < minDistance {
                    let shift = (minDistance - diff) / 2.0
                    sorted[i - 1].plotAngle = WheelGeometry.normalise(sorted[i - 1].plotAngle - shift)
                    sorted[i].plotAngle     = WheelGeometry.normalise(sorted[i].plotAngle     + shift)
                }
            }
            // Also check wrap-around (last vs first)
            let diff = angularDiff(sorted[0].plotAngle + 360.0, sorted[sorted.count - 1].plotAngle)
            if diff < minDistance {
                let shift = (minDistance - diff) / 2.0
                sorted[sorted.count - 1].plotAngle = WheelGeometry.normalise(sorted[sorted.count - 1].plotAngle - shift)
                sorted[0].plotAngle = WheelGeometry.normalise(sorted[0].plotAngle + shift)
            }
        }
        return sorted
    }

    // Angular difference going counter-clockwise from a to b (result 0..<360)
    private static func angularDiff(_ a: Double, _ b: Double) -> Double {
        var diff = a - b
        if diff < 0 { diff += 360.0 }
        return diff
    }
}
