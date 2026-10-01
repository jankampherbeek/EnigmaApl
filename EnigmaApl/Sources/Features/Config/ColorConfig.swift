// ColorConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftUI

/// A Codable color representation for use in configuration and Swift Data storage.
public struct ColorConfig: Codable, Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    /// Default background color for a zodiac sign, based on its element.
    public static func defaultSignColor(for sign: Signs) -> ColorConfig {
        switch sign {
        case .Aries, .Leo, .Sagittarius:     return fireSignColor
        case .Taurus, .Virgo, .Capricorn:    return earthSignColor
        case .Gemini, .Libra, .Aquarius:     return airSignColor
        case .Cancer, .Scorpio, .Pisces:     return waterSignColor
        }
    }

    private static let fireSignColor  = ColorConfig(red: 1.0,   green: 0.149, blue: 0.0)
    private static let earthSignColor = ColorConfig(red: 0.574, green: 0.566, blue: 0.0)
    private static let airSignColor   = ColorConfig(red: 1.0,   green: 0.832, blue: 0.473)
    private static let waterSignColor = ColorConfig(red: 0.0,   green: 0.590, blue: 1.0)
}

// MARK: - SwiftUI Color bridge

extension Color {
    /// Creates a SwiftUI Color from a ColorConfig.
    init(_ config: ColorConfig) {
        self.init(red: config.red, green: config.green,
                  blue: config.blue, opacity: config.opacity)
    }

    /// Converts a SwiftUI Color back to a ColorConfig using the sRGB color space.
    var colorConfig: ColorConfig {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.white
        return ColorConfig(
            red:     ns.redComponent,
            green:   ns.greenComponent,
            blue:    ns.blueComponent,
            opacity: ns.alphaComponent
        )
    }
}
