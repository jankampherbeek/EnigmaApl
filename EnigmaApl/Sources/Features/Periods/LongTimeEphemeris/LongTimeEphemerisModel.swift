// LongTimeEphemerisModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

enum LongTimeEphemerisDisplayFormat: Int, CaseIterable, Identifiable {
    case dms = 0
    case decimal = 1
    var id: Int { rawValue }
}

@MainActor
final class LongTimeEphemerisModel: ObservableObject {

    // MARK: - Date inputs
    @Published var startYearText: String = "2000"
    @Published var startMonth: Int = 1
    @Published var startDay: Int = 1
    @Published var startCalendarStyle: CalendarStyle = .gregorian
    @Published var startYearCount: YearCount = .ce

    @Published var endYearText: String = "2025"
    @Published var endMonth: Int = 12
    @Published var endDay: Int = 31
    @Published var endCalendarStyle: CalendarStyle = .gregorian
    @Published var endYearCount: YearCount = .ce

    // MARK: - Interval
    @Published var intervalDays: Int = 1
    @Published var intervalHours: Int = 0

    // MARK: - Calculation parameters
    @Published var observerPosition: ObserverPositions = .geoCentric
    @Published var ayanamsha: Ayanamshas = .tropical
    @Published var selectedCoordinate: EphemerisCoordinate = .longitude
    @Published var displayFormat: LongTimeEphemerisDisplayFormat = .dms
    @Published var selectedFactors: [Factors] = []

    // MARK: - Results
    @Published var rows: [LongTimeEphemerisRow] = []
    @Published var isCalculating: Bool = false
    @Published var progress: Double = 0.0

    private var calculationTask: Task<Void, Never>?

    func startCalculation(jdStart: Double, jdEnd: Double) {
        calculationTask?.cancel()
        rows = []
        isCalculating = true
        progress = 0.0

        let interval = Double(intervalDays) + Double(intervalHours) / 24.0
        var jdValues: [Double] = []
        var jd = jdStart
        while jd <= jdEnd + 1e-9 {
            jdValues.append(jd)
            jd += interval
        }

        let capturedFactors = selectedFactors
        let capturedCoord = selectedCoordinate
        let capturedObserver = observerPosition
        let capturedAyan = ayanamsha
        let batchSize = 500

        calculationTask = Task {
            let calcActor = LongTimeEphemerisActor()
            let total = jdValues.count
            var allResults: [LongTimeEphemerisRow] = []
            allResults.reserveCapacity(total)

            for batchStart in stride(from: 0, to: total, by: batchSize) {
                if Task.isCancelled { break }

                let batchEnd = min(batchStart + batchSize, total)
                let batchJds = Array(jdValues[batchStart..<batchEnd])

                let batchRows = await calcActor.calculateBatch(
                    jdValues: batchJds,
                    startIndex: batchStart,
                    factors: capturedFactors,
                    coordinate: capturedCoord,
                    observerPosition: capturedObserver,
                    ayanamsha: capturedAyan
                )
                allResults.append(contentsOf: batchRows)
                self.progress = Double(batchEnd) / Double(total)
            }

            if !Task.isCancelled {
                self.rows = allResults
            }
            self.isCalculating = false
        }
    }

    func cancelCalculation() {
        calculationTask?.cancel()
        calculationTask = nil
        isCalculating = false
        progress = 0.0
    }
}
