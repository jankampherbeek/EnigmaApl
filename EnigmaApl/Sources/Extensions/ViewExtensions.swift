//
//  ViewExtensions.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/03/2026.
//

import SwiftUI

extension View {
    /// Adds a border to a text field that is visible in both light and dark mode.
    func adaptiveBorder() -> some View {
        overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.primary.opacity(0.25), lineWidth: 1)
        )
    }
}
