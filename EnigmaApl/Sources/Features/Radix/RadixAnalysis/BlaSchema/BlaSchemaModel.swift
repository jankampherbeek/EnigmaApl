// BlaSchemaModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Model (VM pattern) for the BLA schema ("Invisible Luminaries Astrology") screen.
///
/// Recomputes a local, isolated `FullChart` for the BLA point set on every house-system /
/// Chiron / Ceres / decanates change, using the same `AstronCalcOrchestrator` pipeline as the
/// rest of the app — but with its own `CalcRequest` and `SEWrapper`, so it never touches
/// `ChartSession`'s shared state. Other screens keep showing the chart's original house system.
///
/// v1 simplification: always uses the mean lunar node (no true-node picker) — see the BLA
/// schema implementation plan for why. The "corrected" Black Moon/Priapus variant is picked
/// via `blackMoonCorrectionType` (BLA-only, not part of `CalculationConfig` — see
/// `BlackMoonCorrectionType`).
final class BlaSchemaModel: ObservableObject {
    @Published var houseSystem: HouseSystems = .placidus
    @Published var useChiron: Bool = false
    @Published var useCeres: Bool = false
    @Published var useDecanates: Bool = false
    @Published var blackMoonCorrectionType: BlackMoonCorrectionType = .duval

    @Published private(set) var hasChart: Bool = false
    @Published private(set) var chartName: String = ""

    @Published private(set) var blaPositions: [PresentableBlaPosition] = []
    @Published private(set) var housePositions: [PresentableHousePosition] = []
    @Published private(set) var crossesCounts: [PresentableCrossElementsCount] = []
    @Published private(set) var elementsCounts: [PresentableCrossElementsCount] = []
    @Published private(set) var quadrantCounts: [PresentableQuadrantCount] = []
    @Published private(set) var dispositorCounts: [PresentableDispositorCounts] = []
    @Published private(set) var blaDetails: [PresentableBlaDetails] = []
    @Published private(set) var blaCycles: [PresentableBlaCycle] = []
    @Published private(set) var shortenedCycles: [PresentableBlaCycle] = []
    @Published private(set) var factorsInOwnSigns: [PresentableReinforcementFactor] = []
    @Published private(set) var factorsInOwnHouses: [PresentableReinforcementFactor] = []
    @Published private(set) var factorsInOwnMundaneHouses: [PresentableReinforcementFactor] = []
    @Published private(set) var houseLordsInAnalogSigns: [PresentableReinforcementFactor] = []
    @Published private(set) var pairAnalogHouseSigns: [PresentablePairAnalogHouseSign] = []
    @Published private(set) var receptionsInSigns: [PresentableReception] = []
    @Published private(set) var receptionsInHouses: [PresentableReception] = []
    @Published private(set) var receptionsInMundaneHouses: [PresentableReception] = []

    private let seWrapper = SEWrapper()

    /// The fixed BLA point set (mirrors the Windows BlaSchemaModel.DefineChartPoints, minus the
    /// true-node branch dropped for v1), derived from `BlaSchemaDomain.standardSequence` so the
    /// calculation always uses the same factors — in the same order — as the Windows example,
    /// instead of whatever factors happen to be selected in the app's calculation configuration.
    /// Chiron/Ceres are appended when toggled on; Ascendant/MC come from the house calculation.
    private func fixedFactors() -> [Factors] {
        BlaSchemaDomain.standardSequence(blackMoonCorrectionType: blackMoonCorrectionType).filter {
            $0 != .chiron && $0 != .ceres && $0 != .ascendant && $0 != .mc
        }
    }

    func recalculate(baseRequest: CalcRequest, chartName: String) {
        var factors = fixedFactors()
        if useChiron { factors.append(.chiron) }
        if useCeres { factors.append(.ceres) }

        let request = CalcRequest(
            JulianDay: baseRequest.JulianDay,
            FactorsToUse: factors,
            HouseSystem: Int(houseSystem.seId.asciiValue ?? 80),
            Latitude: baseRequest.Latitude,
            Longitude: baseRequest.Longitude,
            Height: baseRequest.Height,
            calculationConfig: CalculationConfig(houseSystem: houseSystem)
        )
        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)

        var points: [Factors: Double] = [:]
        for factor in factors {
            points[factor] = chart.Coordinates[factor]?.ecliptical.first?.mainPos ?? 0
        }
        points[.ascendant] = chart.HousePositions.ascendant.longitude
        points[.mc] = chart.HousePositions.midheaven.longitude

        var cusps: [Int: Double] = [:]
        for (index, cusp) in chart.HousePositions.cusps.enumerated() {
            cusps[index + 1] = cusp.longitude
        }

        let chartLongitudes = BlaChartLongitudes(points: points, cusps: cusps)
        let orchestrator = BlaSchemaOrchestrator(
            chart: chartLongitudes, useDecanates: useDecanates, blackMoonCorrectionType: blackMoonCorrectionType
        )

        let signCounts = orchestrator.getSignCounts()
        let houseCounts = orchestrator.getHouseCounts()
        let planetsInHouses = orchestrator.getPlanetsInHouses()
        let signsOnCusps = orchestrator.getSignsOnCusps()

        self.chartName = chartName
        blaPositions = BlaSchemaPresentables.blaPositions(from: orchestrator.getPointDetails())
        housePositions = BlaSchemaPresentables.housePositions(from: orchestrator.getHouseDetails())
        crossesCounts = BlaSchemaPresentables.crossesCounts(
            signCounts: signCounts, houseCounts: houseCounts, planetsInHouses: planetsInHouses, signOnCusps: signsOnCusps
        )
        elementsCounts = BlaSchemaPresentables.elementsCounts(
            signCounts: signCounts, planetsInHouses: planetsInHouses, signOnCusps: signsOnCusps
        )
        quadrantCounts = BlaSchemaPresentables.quadrantCounts(from: orchestrator.getQuadrantCounts())
        dispositorCounts = BlaSchemaPresentables.dispositorCounts(from: orchestrator.getDispositors(useDecanates: useDecanates))
        blaDetails = BlaSchemaPresentables.blaDetails(from: orchestrator.getDetails())
        blaCycles = BlaSchemaPresentables.blaCycles(from: orchestrator.getCycles())
        shortenedCycles = BlaSchemaPresentables.shortenedCycles(from: orchestrator.getShortenedCycles())
        factorsInOwnSigns = BlaSchemaPresentables.reinforcementFactors(
            from: orchestrator.getPointsInOwnSign(), blackMoonCorrectionType: blackMoonCorrectionType
        )
        factorsInOwnHouses = BlaSchemaPresentables.reinforcementFactors(
            from: orchestrator.getPointsInOwnHouse(), blackMoonCorrectionType: blackMoonCorrectionType
        )
        factorsInOwnMundaneHouses = BlaSchemaPresentables.reinforcementFactors(
            from: orchestrator.getPointsInOwnMundaneHouse(), blackMoonCorrectionType: blackMoonCorrectionType
        )
        houseLordsInAnalogSigns = BlaSchemaPresentables.reinforcementFactors(
            from: orchestrator.getRulersInHouseAsSign(), blackMoonCorrectionType: blackMoonCorrectionType
        )
        pairAnalogHouseSigns = BlaSchemaPresentables.pairsAnalogHouseSign(from: orchestrator.getFactorPairsAnalogHouseSigns())
        receptionsInSigns = BlaSchemaPresentables.receptionsInSigns(from: orchestrator.getReceptionsInSigns())
        receptionsInHouses = BlaSchemaPresentables.receptionsInHouses(from: orchestrator.getReceptionsInHouses())
        receptionsInMundaneHouses = BlaSchemaPresentables.receptionsInHouses(from: orchestrator.getReceptionsInMundaneHouses())
        hasChart = true
    }

    func clear() {
        hasChart = false
    }
}
