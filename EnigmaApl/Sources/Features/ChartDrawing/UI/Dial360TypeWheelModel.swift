// Dial360TypeWheelModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

@MainActor
final class Dial360TypeWheelModel: ObservableObject {
    @Published var plotData: WheelPlotData = .empty

    func update(from chart: FullChart) {
        plotData = DialPlotDataBuilder.build(from: chart)
    }
}
