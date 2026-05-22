// WavesModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class WavesModel: ObservableObject {
    @Published var allResults: [Factors: [(julianDay: Double, waveValue: Double)]] = [:]
    @Published var selectedFactors: [Factors] = []

    var hasResults: Bool { !allResults.isEmpty }
}
