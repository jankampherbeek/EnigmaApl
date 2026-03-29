// Dial45TypeWheelModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

@MainActor
final class Dial45TypeWheelModel: ObservableObject {
    @Published var plotData: WheelPlotData = .empty

    func update(from chart: FullChart, config: UserConfiguration? = nil) {
        plotData = Dial45PlotDataBuilder.build(from: chart, config: config)
    }
}
