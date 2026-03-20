//
//  RadixOverviewModel.swift
//  EnigmaApl
//

import Foundation
import Combine

@MainActor
final class RadixOverviewModel: ObservableObject {

    /// Formats a Julian Day number for display.
    func formattedJulianDay(_ julianDay: Double) -> String {
        String(format: "%.4f", julianDay)
    }
}
