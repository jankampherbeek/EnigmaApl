// WheelTheme.swift
// EnigmaApl
//
// Determines all drawing colors for a chart wheel.
// In blackWhite mode every fill and text color becomes black/white;
// only cusp lines are exempt — they stay grey and semi-transparent.

import SwiftUI

struct WheelTheme {
    let isBlackWhite: Bool

    static let color      = WheelTheme(isBlackWhite: false)
    static let blackWhite = WheelTheme(isBlackWhite: true)

    // MARK: - Circle fills
    var outerCircleBackground:  Color { isBlackWhite ? .white : WheelColors.outerCircleBackground }
    var signRingBackground:     Color { isBlackWhite ? .white : WheelColors.signRingBackground }
    var houseRingBackground:    Color { isBlackWhite ? .white : WheelColors.houseRingBackground }
    var aspectCircleBackground: Color { isBlackWhite ? .white : WheelColors.aspectCircleBackground }

    // MARK: - Strokes
    var circleStroke:     Color { isBlackWhite ? .black : WheelColors.circleStroke }
    var degreeTickStroke: Color { isBlackWhite ? .black : WheelColors.degreeTickStroke }
    var signSeparator:    Color { isBlackWhite ? .black : WheelColors.signSeparator }

    // MARK: - Signs
    var signGlyph: Color { isBlackWhite ? .black : WheelColors.signGlyph }
    func signSectorColor(for sign: Signs) -> Color {
        isBlackWhite ? .clear : SignColorSelector.getColorForSign(sign)
    }

    // MARK: - Cusps
    var cuspLine:          Color { isBlackWhite ? Color(white: 0.6) : WheelColors.cuspLine }
    var cuspText:          Color { isBlackWhite ? .black : WheelColors.cuspText }
    var cardinalIndicator: Color { isBlackWhite ? .black : WheelColors.cardinalIndicator }

    // MARK: - Planets
    var planetGlyph:       Color { isBlackWhite ? .black : WheelColors.planetGlyph }
    var planetText:        Color { isBlackWhite ? .black : WheelColors.planetText }
    var planetConnectLine: Color { isBlackWhite ? .black : WheelColors.planetConnectLine }

    // MARK: - Aspects
    func aspectLineColor(original: Color) -> Color {
        isBlackWhite ? Color(white: 0.25) : original
    }
}
