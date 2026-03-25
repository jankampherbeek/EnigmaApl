// WheelMetrics.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import CoreGraphics

struct WheelMetrics {

    // MARK: - Radius fractions (relative to outerRadius)
    static let outerCircle:         Double = 0.98
    static let cardinalIndicator:   Double = 0.93
    static let outerSign:           Double = 0.89
    static let signGlyph:           Double = 0.84
    static let outerHouse:          Double = 0.79
    static let cuspText:            Double = 0.76
    static let degrees:             Double = 0.775
    static let degrees5:            Double = 0.760
    static let planetText:          Double = 0.64
    static let planetGlyph:         Double = 0.54
    static let outerConnection:     Double = 0.48
    static let outerAspect:         Double = 0.44
    static let vsp:                 Double = 0.39

    // MARK: - Font size fractions (relative to outerRadius)
    static let signGlyphFontFraction:   Double = 0.080   // ~28px at 350px radius
    static let planetGlyphFontFraction: Double = 0.069   // ~24px at 350px radius
    static let cardinalFontFraction:    Double = 0.046   // ~16px at 350px radius
    static let positionTextFraction:    Double = 0.029   // ~10px at 350px radius
    static let vspTextFraction:         Double = 0.043   // ~15px at 350px radius

    // MARK: - Stroke width fractions (relative to outerRadius)
    static let strokeFraction:          Double = 0.0057  // ~2px at 350px radius
    static let connectLineFraction:     Double = 0.0029  // ~1px at 350px radius
    static let aspectLineFraction:      Double = 0.017   // ~6px at 350px radius

    // MARK: - Opacity
    static let cuspLineOpacity:         Double = 0.5
    static let connectLineOpacity:      Double = 0.25
    static let aspectOpacity:           Double = 0.4
    static let elementSectorOpacity:    Double = 0.4

    // MARK: - Anti-overlap
    static let minGlyphDistance:        Double = 6.0    // degrees

    // MARK: - Computed values for a given outerRadius

    static func radius(_ fraction: Double, outerRadius: Double) -> Double {
        outerRadius * fraction
    }

    static func fontSize(_ fraction: Double, outerRadius: Double) -> CGFloat {
        CGFloat(outerRadius * fraction)
    }

    static func strokeWidth(_ fraction: Double, outerRadius: Double) -> CGFloat {
        CGFloat(outerRadius * fraction)
    }
}
