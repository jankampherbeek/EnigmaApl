//
//  ColorConfig+SwiftUI.swift
//  EnigmaApl
//

import SwiftUI

public extension ColorConfig {
    /// Returns a SwiftUI Color from the stored RGBA components.
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
