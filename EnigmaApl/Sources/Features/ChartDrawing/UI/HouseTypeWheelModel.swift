// HouseTypeWheelModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Combine
import SwiftUI

@MainActor
final class HouseTypeWheelModel: ObservableObject {
    @Published var plotData: WheelPlotData = .empty

    func update(from chart: FullChart, config: UserConfiguration? = nil) {
        plotData = HouseWheelPlotDataBuilder.build(from: chart, config: config)
    }
}
