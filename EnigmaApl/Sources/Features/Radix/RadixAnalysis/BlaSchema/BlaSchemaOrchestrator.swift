// BlaSchemaOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Orchestrator for the BLA schema ("Invisible Luminaries Astrology") calculations.
/// Precomputes point/house details once for a chart, then exposes the same getter
/// surface as Enigma.Core/Slices/BlaSchema/BlaSchemaOrchestrator.cs.
final class BlaSchemaOrchestrator {
    private let chart: BlaChartLongitudes
    private let pointDetails: [BlaPointDetails]
    private let houseDetails: [BlaHouseDetails]
    private let houseCounts: [Int: Int]
    private let signCounts: [Int: Int]
    private let planetsInSigns: [Factors: Int]
    private let planetsInHouses: [Factors: Int]
    private let signsOnCusps: [Int: Int]
    private let planetsInDecanates: [Factors: Int]

    init(chart: BlaChartLongitudes, useDecanates: Bool, blackMoonCorrectionType: BlackMoonCorrectionType = .duval) {
        self.chart = chart

        let sequence = BlaSchemaDomain.standardSequence(blackMoonCorrectionType: blackMoonCorrectionType)
        let knownPoints = sequence.filter { chart.points[$0] != nil }
        let extraPoints = chart.points.keys
            .filter { !sequence.contains($0) }
            .sorted { $0.rawValue < $1.rawValue }
        let orderedPoints = knownPoints + extraPoints
        let details = orderedPoints.map { BlaSchemaPositions.createBlaPointDetails(point: $0, chart: chart) }
        self.pointDetails = details

        var decanates: [Factors: Int] = [:]
        if useDecanates {
            for detail in details { decanates[detail.point] = detail.decanate }
        }
        self.planetsInDecanates = decanates

        self.houseDetails = (1...12).map { BlaSchemaPositions.createBlaHouseDetails(houseNr: $0, chart: chart) }
        self.houseCounts = BlaSchemaPositions.defineHouseCounts(pointDetails: details)
        self.signCounts = BlaSchemaPositions.defineSignCounts(pointDetails: details)
        self.planetsInSigns = Dictionary(uniqueKeysWithValues: details.map { ($0.point, $0.sign) })
        self.planetsInHouses = BlaSchemaPositions.definePositions(chart: chart)
        self.signsOnCusps = BlaSchemaPositions.defineSignsOnCusps(cusps: chart.cusps)
    }

    func getPointDetails() -> [BlaPointDetails] { pointDetails }
    func getHouseDetails() -> [BlaHouseDetails] { houseDetails }
    func getSignCounts() -> [Int: Int] { signCounts }
    func getHouseCounts() -> [Int: Int] { houseCounts }
    func getPlanetsInSigns() -> [Factors: Int] { planetsInSigns }
    func getPlanetsInHouses() -> [Factors: Int] { planetsInHouses }
    func getSignsOnCusps() -> [Int: Int] { signsOnCusps }

    func getQuadrantCounts() -> [Int: Int] {
        BlaSchemaPositions.defineQuadrants(houseDetails: houseDetails)
    }

    func getDecanateCounts() -> [Factors: Int] {
        BlaSchemaPositions.defineDecanateCounts(planetsInDecanates: planetsInDecanates)
    }

    func getDispositors(useDecanates: Bool) -> [BlaDispositorLine] {
        BlaSchemaDispositors.createDispositors(
            signCounts: signCounts, houseCounts: houseCounts, signsOnHouseCusps: signsOnCusps,
            planetsInSign: planetsInSigns, planetsInHouses: planetsInHouses,
            planetsInDecanates: planetsInDecanates, useDecanates: useDecanates
        )
    }

    func getDetails() -> BlaDetailsData {
        BlaSchemaCyclesDetails.createDetails(chart: chart, signsOnCusps: signsOnCusps, planetsInHouses: planetsInHouses)
    }

    func getCycles() -> BlaCyclesData {
        BlaSchemaCyclesDetails.createCyclesData(planetsInHouses: planetsInHouses, signsOnCusps: signsOnCusps)
    }

    func getShortenedCycles() -> BlaCyclesData {
        BlaSchemaCyclesDetails.createShortenedCyclesData(planetsInHouses: planetsInHouses, signsOnCusps: signsOnCusps)
    }

    // MARK: - Reinforcements

    func getPointsInOwnSign() -> [Factors: Int] {
        BlaSchemaReinforcements.findPointsInOwnSign(planetsInSigns: planetsInSigns)
    }

    func getPointsInOwnHouse() -> [Factors: Int] {
        BlaSchemaReinforcements.findPointsInOwnHouse(planetsInHouses: planetsInHouses, signsOnCusps: signsOnCusps)
    }

    func getPointsInOwnMundaneHouse() -> [Factors: Int] {
        BlaSchemaReinforcements.findPointsInMundaneHouses(planetsInHouses: planetsInHouses)
    }

    func getRulersInHouseAsSign() -> [Factors: Int] {
        BlaSchemaReinforcements.findRulerInHouseAsSign(signsOnCusps: signsOnCusps, planetsInSigns: planetsInSigns)
    }

    func getFactorPairsAnalogHouseSigns() -> [FactorPairAnalogHouseSign] {
        BlaSchemaReinforcements.findFactorPairs(planetsInSigns: planetsInSigns, planetsInHouses: planetsInHouses)
    }

    func getReceptionsInSigns() -> [Reception] {
        BlaSchemaReinforcements.findReceptionInSigns(planetsInSigns: planetsInSigns)
    }

    func getReceptionsInHouses() -> [Reception] {
        BlaSchemaReinforcements.findReceptionInHouses(planetsInHouses: planetsInHouses, signsOnCusps: signsOnCusps)
    }

    func getReceptionsInMundaneHouses() -> [Reception] {
        BlaSchemaReinforcements.findReceptionInMundaneHouses(planetsInHouses: planetsInHouses, signsOnCusps: signsOnCusps)
    }
}
