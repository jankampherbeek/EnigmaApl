// HarmonicOrbsModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Shared state for the Harmonic Orbs feature. The input screen edits the maximum orb and the
/// aspect selection; the drawing screen observes the same instance to redraw the chart.
@MainActor
final class HarmonicOrbsModel: ObservableObject {
    @Published var orbDegrees: Int = 15
    @Published var orbMinutes: Int = 0
    @Published var settings: [HarmonicOrbSetting] = HarmonicOrbSetting.defaults

    /// The user-entered maximum orb, in decimal degrees.
    var maxOrbDegrees: Double {
        Double(orbDegrees) + Double(orbMinutes) / 60.0
    }

    /// The actual orb for a given aspect: the maximum orb divided by its harmonic number.
    func actualOrbDegrees(for setting: HarmonicOrbSetting) -> Double {
        maxOrbDegrees / Double(setting.harmonicNumber)
    }

    func toggleSelection(for aspect: Aspects) {
        guard let index = settings.firstIndex(where: { $0.aspect == aspect }) else { return }
        settings[index].isSelected.toggle()
    }
}
