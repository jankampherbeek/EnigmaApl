// FrenchTypeWheelModel.swift
// EnigmaApl

import SwiftUI
import Combine

@MainActor
final class FrenchTypeWheelModel: ObservableObject {
    @Published var plotData: WheelPlotData = .empty

    func update(from chart: FullChart, config: UserConfiguration? = nil) {
        plotData = WheelPlotDataBuilder.build(from: chart, config: config)
    }
}
