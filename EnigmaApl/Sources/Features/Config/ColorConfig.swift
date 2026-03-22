//
//  ColorConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

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

    /// Light blue — default background color for zodiac signs.
    public static let defaultSignColor = ColorConfig(red: 0.678, green: 0.847, blue: 0.902)
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
