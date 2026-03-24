// WheelColors.swift
// EnigmaApl

import SwiftUI

struct WheelColors {

    // MARK: - Circle backgrounds
    static let outerCircleBackground    = Color(red: 0.94, green: 0.97, blue: 1.00) // AliceBlue
    static let signRingBackground       = Color(red: 0.69, green: 0.93, blue: 0.93) // PaleTurquoise
    static let houseRingBackground      = Color(red: 1.00, green: 0.98, blue: 0.94) // FloralWhite
    static let aspectCircleBackground   = Color(red: 0.94, green: 0.97, blue: 1.00) // AliceBlue

    // MARK: - Circle strokes
    static let circleStroke             = Color(red: 0.20, green: 0.20, blue: 0.80) // MediumBlue
    static let degreeTickStroke         = Color(red: 0.20, green: 0.20, blue: 0.80)

    // MARK: - Signs
    static let signGlyph                = Color(red: 0.20, green: 0.20, blue: 0.80)
    static let signSeparator            = Color(red: 0.20, green: 0.20, blue: 0.80)

    // MARK: - Element sector backgrounds (40% opacity)
    static let fireElement   = Color(red: 1.0, green: 0.0, blue: 0.0).opacity(0.40)
    static let earthElement  = Color(red: 0.55, green: 0.27, blue: 0.07).opacity(0.40)
    static let airElement    = Color(red: 0.0, green: 0.0, blue: 1.0).opacity(0.40)
    static let waterElement  = Color(red: 0.0, green: 0.7, blue: 0.3).opacity(0.40)

    // MARK: - Cusps
    static let cuspLine                 = Color(red: 0.27, green: 0.51, blue: 0.71) // SteelBlue
    static let cuspText                 = Color(red: 0.55, green: 0.27, blue: 0.07) // SaddleBrown
    static let cardinalIndicator        = Color(red: 0.55, green: 0.27, blue: 0.07)

    // MARK: - Planets
    static let planetGlyph              = Color(red: 0.18, green: 0.31, blue: 0.31) // DarkSlateBlue
    static let planetText               = Color(red: 0.18, green: 0.31, blue: 0.31)
    static let planetConnectLine        = Color(red: 0.18, green: 0.31, blue: 0.31)

    // MARK: - Aspects
    static let hardAspect               = Color.red
    static let softAspect               = Color.green
    static let minorAspect              = Color.gray
    static let inconjunct               = Color.purple

    // MARK: - Element color lookup
    static func elementColor(forSignIndex index: Int) -> Color {
        switch index % 4 {
        case 0: return fireElement
        case 1: return earthElement
        case 2: return airElement
        case 3: return waterElement
        default: return fireElement
        }
    }
}
