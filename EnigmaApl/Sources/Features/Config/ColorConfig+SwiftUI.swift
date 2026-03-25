// ColorConfig+SwiftUI.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

public extension ColorConfig {
    /// Returns a SwiftUI Color from the stored RGBA components.
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
