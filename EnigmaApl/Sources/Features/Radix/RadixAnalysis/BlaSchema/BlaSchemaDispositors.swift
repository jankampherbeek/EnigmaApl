// BlaSchemaDispositors.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Dispositor-chain calculation for the BLA schema.
/// Ported from Enigma.Core/Slices/BlaSchema/Dispositors.cs.
enum BlaSchemaDispositors {

    /// Only 6 ruler-pair axes are reported (one representative per sister-sign axis; the mirrored
    /// signs 6,7,8,10,11,12 are implied since main/sub swap on the sister axis).
    private static func rulerPairsForDispositors() -> [RulerPair] {
        [
            RulerPair(signIndex: 1, mainRuler: .mars, subRuler: .pluto),
            RulerPair(signIndex: 2, mainRuler: .venus, subRuler: .persephoneCarteret),
            RulerPair(signIndex: 3, mainRuler: .mercury, subRuler: .vulcanusCarteret),
            RulerPair(signIndex: 4, mainRuler: .moon, subRuler: .priapus),
            RulerPair(signIndex: 5, mainRuler: .sun, subRuler: .apogeeMean),
            RulerPair(signIndex: 9, mainRuler: .jupiter, subRuler: .neptune)
        ]
    }

    /// The 12 sign-rulers that can trigger "indirect" dignity contributions.
    /// Saturn/Uranus/Nodes/Beast/Dragon/Angles never trigger indirect dignities.
    private static func isRuler(_ factor: Factors) -> Bool {
        switch factor {
        case .sun, .moon, .mercury, .venus, .mars, .jupiter, .neptune, .pluto,
             .apogeeMean, .priapus, .persephoneCarteret, .vulcanusCarteret:
            return true
        default:
            return false
        }
    }

    private static func cusps(ruledBy ruler: Factors, signsOnCusps: [Int: Int]) -> [Int] {
        let (signMain, signSub) = BlaSchemaPositions.signsRuled(byPoint: ruler)
        return signsOnCusps
            .filter { $0.value == signMain || $0.value == signSub }
            .map { $0.key }
    }

    static func createDispositors(
        signCounts: [Int: Int],
        houseCounts: [Int: Int],
        signsOnHouseCusps: [Int: Int],
        planetsInSign: [Factors: Int],
        planetsInHouses: [Factors: Int],
        planetsInDecanates: [Factors: Int],
        useDecanates: Bool
    ) -> [BlaDispositorLine] {
        var decansWithFactors: [Int: [Factors]] = Dictionary(uniqueKeysWithValues: (1...7).map { ($0, []) })
        for (factor, decanate) in planetsInDecanates {
            decansWithFactors[decanate, default: []].append(factor)
        }

        var lines: [BlaDispositorLine] = []

        for pair in rulerPairsForDispositors() {
            let mainRuler = pair.mainRuler
            let subRuler = pair.subRuler

            // Rulers in signs
            let (signMainRuler, signSubRuler) = BlaSchemaPositions.signsRuled(byPoint: mainRuler)
            let signMainRulerCount = signCounts[signMainRuler] ?? 0
            let signSubRulerCount = signCounts[signSubRuler] ?? 0
            let directSignCount = signMainRulerCount + signSubRulerCount

            var indirectSignCount = 0
            var processedSigns: [Int] = []
            for (point, value) in planetsInSign {
                if point == mainRuler || point == subRuler || !isRuler(point) { continue }
                if value == signMainRuler || value == signSubRuler {
                    let signs = BlaSchemaPositions.signsRuled(byPoint: point)
                    if processedSigns.contains(signs.main) || processedSigns.contains(signs.sub) { continue }
                    indirectSignCount += signCounts[signs.main] ?? 0
                    indirectSignCount += signCounts[signs.sub] ?? 0
                    processedSigns.append(signs.main)
                    processedSigns.append(signs.sub)
                }
            }
            let totalSignCount = directSignCount + indirectSignCount

            // Rulers in decanates
            var directDecanateCount = 0
            if useDecanates {
                for decanateRuler in BlaSchemaDomain.decanateRulers() where decanateRuler.ruler == mainRuler || decanateRuler.ruler == subRuler {
                    directDecanateCount = decansWithFactors[decanateRuler.decan]?.count ?? 0
                }
            }

            // Rulers in houses
            let housesRuledByMainRuler = cusps(ruledBy: mainRuler, signsOnCusps: signsOnHouseCusps)
            var directHouseCount = 0
            for house in housesRuledByMainRuler {
                directHouseCount += houseCounts[house] ?? 0
            }

            var pointsInHousesForIndirectRulership: [Factors] = []
            for house in housesRuledByMainRuler {
                for (point, value) in planetsInHouses {
                    if point == mainRuler || point == subRuler || !isRuler(point) { continue }
                    if value == house {
                        pointsInHousesForIndirectRulership.append(point)
                    }
                }
            }

            // Dedup: only one point per ruler-pair axis
            var uniquePoints: [Factors] = []
            for pair in BlaSchemaDomain.rulerPairs() {
                var handledPairSignIndices: Set<Int> = []
                for point in pointsInHousesForIndirectRulership {
                    guard point == pair.mainRuler || point == pair.subRuler else { continue }
                    if handledPairSignIndices.contains(pair.signIndex) { continue }
                    handledPairSignIndices.insert(pair.signIndex)
                    if !uniquePoints.contains(point) {
                        uniquePoints.append(point)
                    }
                }
            }

            var indirectHouseCount = 0
            for point in uniquePoints {
                for house in cusps(ruledBy: point, signsOnCusps: signsOnHouseCusps) {
                    indirectHouseCount += houseCounts[house] ?? 0
                }
            }
            let totalHouseCount = directHouseCount + indirectHouseCount
            let total = totalSignCount + totalHouseCount + directDecanateCount

            lines.append(BlaDispositorLine(
                mainRuler: mainRuler, subRuler: subRuler,
                mainRulerSignCount: signMainRulerCount, subRulerSignCount: signSubRulerCount,
                sumRulerSignCount: directSignCount, indirectRulerSignCount: indirectSignCount,
                totalRulerSignCount: totalSignCount,
                directRulerHouseCount: directHouseCount, indirectRulerHouseCount: indirectHouseCount,
                sumRulerHouseCount: totalHouseCount,
                directRulerDecanateCount: directDecanateCount, total: total
            ))
        }
        return lines
    }
}
