// BlaSchemaCyclesDetails.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// "Details" and "cycles" calculations for the BLA schema.
/// Ported from Enigma.Core/Slices/BlaSchema/{BlaDetails,BlaCycles}.cs.
enum BlaSchemaCyclesDetails {

    // MARK: - Details

    static func createDetails(
        chart: BlaChartLongitudes,
        signsOnCusps: [Int: Int],
        planetsInHouses: [Factors: Int]
    ) -> BlaDetailsData {
        let rulerPairs = BlaSchemaDomain.rulerPairs()
        let asc = signsOnCusps[1] ?? 0
        let ascRulers = rulerPairs[asc - 1]
        let subRulerAsc = ascRulers.subRuler

        var sisterSignAsc = 0
        for pair in rulerPairs where pair.mainRuler == subRulerAsc {
            sisterSignAsc = pair.signIndex
        }

        let clampedHouses = BlaSchemaPositions.defineClampedHouses(chart: chart)
        let interceptedSigns = BlaSchemaPositions.defineInterceptedSigns(chart: chart)

        var groundNote: [Int] = [1, asc]
        // Houses whose cusp carries the sister sign of the ascendant
        for pair in rulerPairs where pair.mainRuler == subRulerAsc {
            let signIndex = pair.signIndex
            for (house, sign) in signsOnCusps.sorted(by: { $0.key < $1.key }) where sign == signIndex {
                groundNote.append(house)
            }
        }
        // Other houses whose cusp carries the ascendant's own sign
        for (house, sign) in signsOnCusps.sorted(by: { $0.key < $1.key }) where house != 1 && sign == asc {
            groundNote.append(house)
        }

        let lordAscInHouses = [
            planetsInHouses[ascRulers.mainRuler] ?? 0,
            planetsInHouses[ascRulers.subRuler] ?? 0
        ]
        let moonInHouse = planetsInHouses[.moon] ?? 0

        return BlaDetailsData(
            sisterSignAsc: sisterSignAsc, clampedHouses: clampedHouses, interceptedSigns: interceptedSigns,
            groundNote: groundNote, lordAscInHouses: lordAscInHouses, moonInHouse: moonInHouse
        )
    }

    // MARK: - Cycles

    static func createCyclesData(planetsInHouses: [Factors: Int], signsOnCusps: [Int: Int]) -> BlaCyclesData {
        let rulersForHouses = rulersForHouses(signsOnCusps: signsOnCusps)
        let triples = ruledHouseRulerInHouse(rulersForHouses: rulersForHouses, planetsInHouses: planetsInHouses)
        return BlaCyclesData(
            cardinal: findCycles(houses: [1, 4, 7, 10], triples: triples),
            fixed: findCycles(houses: [2, 5, 8, 11], triples: triples),
            mutable: findCycles(houses: [3, 6, 9, 12], triples: triples),
            fire: findCycles(houses: [1, 5, 9], triples: triples),
            earth: findCycles(houses: [2, 6, 10], triples: triples),
            air: findCycles(houses: [3, 7, 11], triples: triples),
            water: findCycles(houses: [4, 8, 12], triples: triples)
        )
    }

    static func createShortenedCyclesData(planetsInHouses: [Factors: Int], signsOnCusps: [Int: Int]) -> BlaCyclesData {
        let rulersForHouses = rulersForHouses(signsOnCusps: signsOnCusps)
        return BlaCyclesData(
            cardinal: findShortenedCycles(houses: [1, 4, 7, 10], rulersForHouses: rulersForHouses),
            fixed: findShortenedCycles(houses: [2, 5, 8, 11], rulersForHouses: rulersForHouses),
            mutable: findShortenedCycles(houses: [3, 6, 9, 12], rulersForHouses: rulersForHouses),
            fire: findShortenedCycles(houses: [1, 5, 9], rulersForHouses: rulersForHouses),
            earth: findShortenedCycles(houses: [2, 6, 10], rulersForHouses: rulersForHouses),
            air: findShortenedCycles(houses: [3, 7, 11], rulersForHouses: rulersForHouses),
            water: findShortenedCycles(houses: [4, 8, 12], rulersForHouses: rulersForHouses)
        )
    }

    /// For each house, its cusp sign's [mainRuler, subRuler].
    private static func rulersForHouses(signsOnCusps: [Int: Int]) -> [Int: [Factors]] {
        var result: [Int: [Factors]] = [:]
        let rulerPairs = BlaSchemaDomain.rulerPairs()
        for (house, sign) in signsOnCusps {
            let pair = rulerPairs[sign - 1]
            result[house] = [pair.mainRuler, pair.subRuler]
        }
        return result
    }

    /// (ruler point, house it rules, house it is currently located in).
    private static func ruledHouseRulerInHouse(
        rulersForHouses: [Int: [Factors]],
        planetsInHouses: [Factors: Int]
    ) -> [(ruler: Factors, ruledHouse: Int, rulerLocationHouse: Int)] {
        var triples: [(Factors, Int, Int)] = []
        for (ruledHouse, rulers) in rulersForHouses {
            for ruler in rulers {
                triples.append((ruler, ruledHouse, planetsInHouses[ruler] ?? 0))
            }
        }
        return triples
    }

    /// A "cycle" is a same-group house pair where the ruler of one house is physically located in the other.
    private static func findCycles(houses: [Int], triples: [(ruler: Factors, ruledHouse: Int, rulerLocationHouse: Int)]) -> [(Int, Int)] {
        var cycles: [(Int, Int)] = []
        for triple in triples where houses.contains(triple.ruledHouse) && houses.contains(triple.rulerLocationHouse) {
            cycles.append((triple.ruledHouse, triple.rulerLocationHouse))
        }
        return cycles
    }

    /// A "shortened cycle" is a symbolic house pair within the same group whose cusp-sign rulers are
    /// sister rulers of each other (main/sub pair), independent of where planets actually sit.
    private static func findShortenedCycles(houses: [Int], rulersForHouses: [Int: [Factors]]) -> [(Int, Int)] {
        var cycles: [(Int, Int)] = []
        var rulers: [(ruler: Factors, house: Int)] = []
        for house in houses {
            guard let pair = rulersForHouses[house] else { continue }
            rulers.append((pair[0], house))
            rulers.append((pair[1], house))
        }

        for i in 0..<rulers.count {
            for j in (i + 1)..<rulers.count {
                for rulerPair in BlaSchemaDomain.rulerPairs() {
                    let matchesForward = rulerPair.mainRuler == rulers[i].ruler && rulerPair.subRuler == rulers[j].ruler
                    let matchesBackward = rulerPair.mainRuler == rulers[j].ruler && rulerPair.subRuler == rulers[i].ruler
                    guard matchesForward || matchesBackward else { continue }
                    guard rulers[i].house != rulers[j].house else { continue }
                    guard houses.contains(rulers[i].house), houses.contains(rulers[j].house) else { continue }
                    let candidate = (rulers[i].house, rulers[j].house)
                    if !cycles.contains(where: { $0 == candidate }) {
                        cycles.append(candidate)
                    }
                }
            }
        }
        return cycles
    }
}
