// AstronomicalCyclesModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class AstronomicalCyclesModel: ObservableObject {
    @Published var singleResults: [(factor: Factors, series: [(julianDay: Double, position: Double)])] = []
    @Published var pairResults: [[(julianDay: Double, difference: Double)]] = []
    @Published var factorPairs: [(factor1: Factors, factor2: Factors)] = []
    @Published var coordinate: Coordinates = .longitude
    @Published var isPairs: Bool = false

    var hasResults: Bool {
        isPairs ? !pairResults.isEmpty : !singleResults.isEmpty
    }
}
