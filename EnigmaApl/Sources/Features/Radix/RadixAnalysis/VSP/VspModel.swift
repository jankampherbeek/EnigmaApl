// VspModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Shared state for the Venus Star Point feature — cached so both the diagram
/// (ContentColumn) and the positions table (DetailColumn) compute only once.
@MainActor
final class VspModel: ObservableObject {
    @Published var positions: [PresentableVspPosition] = []

    private var cachedJd: Double?

    /// Recomputes positions only when the chart JD has changed.
    func refresh(chart: FullChart?) {
        guard let jd = chart?.JulianDay, jd != cachedJd else { return }
        cachedJd = jd
        positions = VspOrchestrator.calculate(birthJd: jd)
    }
}
