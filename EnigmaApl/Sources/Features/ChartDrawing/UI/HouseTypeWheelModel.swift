// HouseTypeWheelModel.swift
// EnigmaApl

import Combine
import SwiftUI

@MainActor
final class HouseTypeWheelModel: ObservableObject {
    @Published var plotData: WheelPlotData = .empty

    func update(from chart: FullChart, config: UserConfiguration? = nil) {
        plotData = HouseWheelPlotDataBuilder.build(from: chart, config: config)
    }
}
