//
//  ColorConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import SwiftUI

/// A Codable color representation for use in configuration and Swift Data storage.
public struct ColorConfig: Codable, Equatable {
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

    public var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
