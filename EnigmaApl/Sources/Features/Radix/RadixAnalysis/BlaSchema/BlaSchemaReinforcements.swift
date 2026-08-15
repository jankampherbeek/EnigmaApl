// BlaSchemaReinforcements.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Reinforcement and reception calculations for the BLA schema.
/// Ported from Enigma.Core/Slices/BlaSchema/ReinforcementCalc.cs.
enum BlaSchemaReinforcements {

    private struct HousePosAndRuler {
        let point: Factors
        let housePos: Int
        let houseRuled: [Int]
    }

    private static func isSisterRulerPair(_ point1: Factors, _ point2: Factors) -> Bool {
        BlaSchemaDomain.rulerPairs().contains {
            ($0.mainRuler == point1 && $0.subRuler == point2) || ($0.mainRuler == point2 && $0.subRuler == point1)
        }
    }

    /// Points that sit in the sign they rule (main or sub).
    static func findPointsInOwnSign(planetsInSigns: [Factors: Int]) -> [Factors: Int] {
        var result: [Factors: Int] = [:]
        for pair in BlaSchemaDomain.rulerPairs() {
            for (point, sign) in planetsInSigns where (point == pair.mainRuler || point == pair.subRuler) && sign == pair.signIndex {
                result[point] = sign
            }
        }
        return result
    }

    /// Points that sit in the house whose cusp sign they rule (main or sub).
    static func findPointsInOwnHouse(planetsInHouses: [Factors: Int], signsOnCusps: [Int: Int]) -> [Factors: Int] {
        var result: [Factors: Int] = [:]
        for (point, house) in planetsInHouses {
            guard let sign = signsOnCusps[house] else { continue }
            guard let pair = BlaSchemaDomain.rulerPairs().first(where: { $0.signIndex == sign }) else { continue }
            if point == pair.mainRuler || point == pair.subRuler {
                result[point] = house
            }
        }
        return result
    }

    /// Points that sit in the *mundane* house they rule: house number equals the ruled sign's index,
    /// ignoring the sign actually on that house's cusp.
    static func findPointsInMundaneHouses(planetsInHouses: [Factors: Int]) -> [Factors: Int] {
        var result: [Factors: Int] = [:]
        for (point, house) in planetsInHouses {
            let rulesThisHouseAsSign = BlaSchemaDomain.rulerPairs().contains {
                ($0.mainRuler == point || $0.subRuler == point) && $0.signIndex == house
            }
            if rulesThisHouseAsSign {
                result[point] = house
            }
        }
        return result
    }

    /// Rulers of a cusp sign that are themselves located in a sign whose index equals that house number.
    static func findRulerInHouseAsSign(signsOnCusps: [Int: Int], planetsInSigns: [Factors: Int]) -> [Factors: Int] {
        var result: [Factors: Int] = [:]
        for (house, sign) in signsOnCusps {
            guard let pair = BlaSchemaDomain.rulerPairs().first(where: { $0.signIndex == sign }) else { continue }
            let signMainRuler = planetsInSigns[pair.mainRuler] ?? 0
            let signSubRuler = planetsInSigns[pair.subRuler] ?? 0
            if signMainRuler == house {
                result[pair.mainRuler] = signMainRuler
            }
            if signSubRuler == house {
                result[pair.subRuler] = signSubRuler
            }
        }
        return result
    }

    /// Analog factor pairs: one point's sign index equals the paired point's house index (or vice versa).
    static func findFactorPairs(planetsInSigns: [Factors: Int], planetsInHouses: [Factors: Int]) -> [FactorPairAnalogHouseSign] {
        var result: [FactorPairAnalogHouseSign] = []
        for (point1, point2) in BlaSchemaDomain.factorPairs() {
            guard let sign1 = planetsInSigns[point1], let sign2 = planetsInSigns[point2],
                  let house1 = planetsInHouses[point1], let house2 = planetsInHouses[point2] else { continue }
            if sign1 == house2 {
                result.append(FactorPairAnalogHouseSign(pointInSign: point1, sign: sign1, pointInHouse: point2, house: house2))
            } else if sign2 == house1 {
                result.append(FactorPairAnalogHouseSign(pointInSign: point2, sign: sign2, pointInHouse: point1, house: house1))
            }
        }
        return result
    }

    /// Mutual dignity in signs: point1 sits in a sign point2 rules and vice versa, excluding sister-ruler pairs.
    static func findReceptionInSigns(planetsInSigns: [Factors: Int]) -> [Reception] {
        var receptions: [Reception] = []
        let rulerPairs = BlaSchemaDomain.rulerPairs()

        for pair1 in rulerPairs {
            let point1 = pair1.mainRuler
            for pair2 in rulerPairs {
                let point2 = pair2.mainRuler
                if point1 == point2 { continue }

                let sign1 = planetsInSigns[point1] ?? 0
                let sign2 = planetsInSigns[point2] ?? 0

                let ruledBy1 = rulerPairs.filter { $0.mainRuler == point1 || $0.subRuler == point1 }.map { $0.signIndex }
                let ruledBy2 = rulerPairs.filter { $0.mainRuler == point2 || $0.subRuler == point2 }.map { $0.signIndex }
                guard ruledBy1.count >= 2, ruledBy2.count >= 2 else { continue }

                guard ruledBy2.contains(sign1), ruledBy1.contains(sign2) else { continue }

                let reception = Reception(point1: point1, signOrHouse1: sign1, point2: point2, signOrHouse2: sign2)
                let reversed = Reception(point1: point2, signOrHouse1: sign2, point2: point1, signOrHouse2: sign1)
                if receptions.contains(reception) || receptions.contains(reversed) { continue }
                if !isSisterRulerPair(point1, point2) {
                    receptions.append(reception)
                }
            }
        }
        return receptions
    }

    /// Mutual dignity in houses: point1 sits in a house point2 rules and vice versa, excluding sister-ruler pairs.
    static func findReceptionInHouses(planetsInHouses: [Factors: Int], signsOnCusps: [Int: Int]) -> [Reception] {
        var housesPosAndRuler: [HousePosAndRuler] = []
        for rulerAndSigns in BlaSchemaDomain.allRulerAndSigns() {
            let housePos = planetsInHouses[rulerAndSigns.ruler] ?? 0
            let housesRuled = signsOnCusps
                .filter { $0.value == rulerAndSigns.mainSign || $0.value == rulerAndSigns.subSign }
                .map { $0.key }
            if housesRuled.isEmpty { continue } // sign is intercepted: no house is ruled
            housesPosAndRuler.append(HousePosAndRuler(point: rulerAndSigns.ruler, housePos: housePos, houseRuled: housesRuled))
        }
        return receptionsFromMutualHouseRulership(housesPosAndRuler)
    }

    /// Mutual dignity in mundane houses: house-number/sign-index equivalence in both directions.
    static func findReceptionInMundaneHouses(planetsInHouses: [Factors: Int], signsOnCusps: [Int: Int]) -> [Reception] {
        var housesPosAndRuler: [HousePosAndRuler] = []
        for rulerAndSigns in BlaSchemaDomain.allRulerAndSigns() {
            let housePos = planetsInHouses[rulerAndSigns.ruler] ?? 0
            housesPosAndRuler.append(HousePosAndRuler(
                point: rulerAndSigns.ruler, housePos: housePos,
                houseRuled: [rulerAndSigns.mainSign, rulerAndSigns.subSign]
            ))
        }
        return receptionsFromMutualHouseRulership(housesPosAndRuler)
    }

    private static func receptionsFromMutualHouseRulership(_ housesPosAndRuler: [HousePosAndRuler]) -> [Reception] {
        var receptions: [Reception] = []
        let count = housesPosAndRuler.count
        guard count > 1 else { return receptions }
        for i in 0..<count {
            let hpr1 = housesPosAndRuler[i]
            for j in (i + 1)..<count {
                let hpr2 = housesPosAndRuler[j]
                if hpr2.houseRuled.contains(hpr1.housePos) && hpr1.houseRuled.contains(hpr2.housePos) {
                    if !isSisterRulerPair(hpr1.point, hpr2.point) {
                        receptions.append(Reception(point1: hpr1.point, signOrHouse1: hpr1.housePos, point2: hpr2.point, signOrHouse2: hpr2.housePos))
                    }
                }
            }
        }
        return receptions
    }
}
