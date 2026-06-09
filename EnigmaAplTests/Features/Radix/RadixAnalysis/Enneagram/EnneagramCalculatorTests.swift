// EnneagramCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

// MARK: - Test data helpers

/// Standard cusps (evenly spaced, 30° apart, starting at 15°).
/// House 1 = 15..45°, house 2 = 45..75°, ..., house 10 = 285..315°, etc.
private let standardCusps: [Double] = [
    0.0, 15.0, 45.0, 75.0, 105.0, 135.0, 165.0, 195.0, 225.0, 255.0, 285.0, 315.0, 345.0
]

/// Signs-dict entry: `pointId * 100 + signIndex` → 9 type multipliers.
private func signsEntry(pointId: Int, sign: Int, values: [Double]) -> (Int, [Double]) {
    (pointId * 100 + sign, values)
}

/// Houses-dict entry: same key formula, but indexing by house number.
private func housesEntry(pointId: Int, house: Int, values: [Double]) -> (Int, [Double]) {
    (pointId * 100 + house, values)
}

private let ones9: [Double] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

// MARK: - signIndex tests

struct EnneagramSignIndexTests {

    @Test("signIndex: 0° is sign 1 (Aries)")
    func testSignIndex_zeroDegrees() {
        #expect(EnneagramCalculator.signIndex(0.0) == 1)
    }

    @Test("signIndex: 29.9° is still sign 1")
    func testSignIndex_justBeforeSign2() {
        #expect(EnneagramCalculator.signIndex(29.9) == 1)
    }

    @Test("signIndex: 30.0° is sign 2 (Taurus)")
    func testSignIndex_exactlySign2() {
        #expect(EnneagramCalculator.signIndex(30.0) == 2)
    }

    @Test("signIndex: 180° is sign 7 (Libra)")
    func testSignIndex_180degrees() {
        #expect(EnneagramCalculator.signIndex(180.0) == 7)
    }

    @Test("signIndex: 330° is sign 12 (Pisces)")
    func testSignIndex_330degrees() {
        #expect(EnneagramCalculator.signIndex(330.0) == 12)
    }

    @Test("signIndex: 359.9° is sign 12")
    func testSignIndex_justBefore360() {
        #expect(EnneagramCalculator.signIndex(359.9) == 12)
    }

    @Test("signIndex: 360° wraps back to sign 1")
    func testSignIndex_360wrapsToSign1() {
        #expect(EnneagramCalculator.signIndex(360.0) == 1)
    }

    @Test("signIndex: negative longitude wraps correctly (−30° → sign 12)")
    func testSignIndex_negativeLongitude() {
        #expect(EnneagramCalculator.signIndex(-30.0) == 12)
    }

    @Test("signIndex: 375° (= 15°) is sign 1")
    func testSignIndex_moreThan360() {
        #expect(EnneagramCalculator.signIndex(375.0) == 1)
    }
}

// MARK: - houseIndex tests

struct EnneagramHouseIndexTests {

    @Test("houseIndex: 15° with standard cusps is house 1")
    func testHouseIndex_exactCuspBoundary() {
        #expect(EnneagramCalculator.houseIndex(15.0, cusps: standardCusps) == 1)
    }

    @Test("houseIndex: 44.9° is still house 1")
    func testHouseIndex_justBeforeHouse2() {
        #expect(EnneagramCalculator.houseIndex(44.9, cusps: standardCusps) == 1)
    }

    @Test("houseIndex: 45.0° is house 2")
    func testHouseIndex_exactlyHouse2() {
        #expect(EnneagramCalculator.houseIndex(45.0, cusps: standardCusps) == 2)
    }

    @Test("houseIndex: 285.0° is house 10 (MC cusp)")
    func testHouseIndex_house10() {
        #expect(EnneagramCalculator.houseIndex(285.0, cusps: standardCusps) == 10)
    }

    @Test("houseIndex: 344.9° is house 11 (between cusp 11 at 315° and cusp 12 at 345°)")
    func testHouseIndex_nearEndOfHouse11() {
        #expect(EnneagramCalculator.houseIndex(344.9, cusps: standardCusps) == 11)
    }

    @Test("houseIndex: 345.0° is house 12 (starts at cusp 12)")
    func testHouseIndex_startOfHouse12() {
        #expect(EnneagramCalculator.houseIndex(345.0, cusps: standardCusps) == 12)
    }

    @Test("houseIndex: 5.0° wraps into house 12 (between cusp 12 at 345° and cusp 1 at 15°)")
    func testHouseIndex_wrapAround() {
        #expect(EnneagramCalculator.houseIndex(5.0, cusps: standardCusps) == 12)
    }
}

// MARK: - calculateStrengths tests

struct EnneagramCalculateStrengthsTests {

    @Test("calculateStrengths: returns exactly 9 results")
    func testReturnsNineResults() {
        let results = EnneagramCalculator.calculateStrengths(
            signs: [:], houses: [:], factorPositions: [],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        #expect(results.count == 9)
    }

    @Test("calculateStrengths: all types 1–9 are present")
    func testAllNineTypesPresent() {
        let results = EnneagramCalculator.calculateStrengths(
            signs: [:], houses: [:], factorPositions: [],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        for t in 1...9 {
            #expect(results.contains(where: { $0.type == t }),
                    "Type \(t) missing from results")
        }
    }

    @Test("calculateStrengths: empty positions give all strengths = 1.0")
    func testEmptyPositions_allOnes() {
        let results = EnneagramCalculator.calculateStrengths(
            signs: [:], houses: [:], factorPositions: [],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        for r in results {
            #expect(r.strength == 1.0,
                    "Type \(r.type) expected 1.0, got \(r.strength)")
        }
    }

    @Test("calculateStrengths: results are sorted highest-first")
    func testSortedDescending() {
        // Sun in Aries with a high factor for type 3
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 0, sign: 1, values: [1.0, 1.0, 5.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        let results = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [(.sun, 15.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        #expect(results.first?.type == 3, "Type 3 should lead (factor 5.0)")
        for i in 0..<results.count - 1 {
            #expect(results[i].strength >= results[i + 1].strength,
                    "Results must be sorted descending at index \(i)")
        }
    }

    @Test("calculateStrengths: multiplication logic — Sun×Moon for type 1 = 6.0")
    func testMultiplicationLogic() {
        // Sun(pointId=0) in sign 1 → type 1 factor = 2.0
        // Moon(pointId=1) in sign 1 → type 1 factor = 3.0
        // Expected type 1 = 2.0 × 3.0 = 6.0; all others = 1.0
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 0, sign: 1, values: [2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]),
            signsEntry(pointId: 1, sign: 1, values: [3.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        let results = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:],
            factorPositions: [(.sun, 15.0), (.moon, 5.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        let type1 = results.first(where: { $0.type == 1 })
        #expect(type1?.strength == 6.0, "Sun×Moon in sign 1 should give type 1 = 6.0")
        for t in 2...9 {
            let r = results.first(where: { $0.type == t })
            #expect(r?.strength == 1.0, "Type \(t) should be 1.0 (identity)")
        }
    }

    @Test("calculateStrengths: useHouses=false excludes ASC, MC, and house contributions")
    func testUseHousesFalse_excludesAngles() {
        // Put all strength in ASC-in-sign; should not affect result when useHouses=false
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 1001, sign: 1, values: [9.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        let results = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [],
            cuspLongitudes: standardCusps, useHouses: false, doublePluto: false
        )
        // Type 1 should stay at 1.0 because ASC is not used
        let type1 = results.first(where: { $0.type == 1 })
        #expect(type1?.strength == 1.0)
    }

    @Test("calculateStrengths: useHouses=true includes ASC-in-sign contribution")
    func testUseHousesTrue_includesAsc() {
        // ASC (id=1001) in sign 1 with factor 4.0 for type 1
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 1001, sign: 1, values: [4.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        // standardCusps[1] = 15° → signIndex = 1 → key = 1001*100+1 = 100101 ✓
        let results = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [],
            cuspLongitudes: standardCusps, useHouses: true, doublePluto: false
        )
        let type1 = results.first(where: { $0.type == 1 })
        #expect(type1?.strength == 4.0)
    }

    @Test("calculateStrengths: doublePluto=true doubles Pluto's contribution")
    func testDoublePluto_doubleContribution() {
        // Pluto(pointId=10) in sign 10 (Capricorn, 285°), factor 2.0 for type 1
        // Without double: type 1 = 2.0; with double: type 1 = 2.0 × 2.0 = 4.0
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 10, sign: 10, values: [2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        let noDouble = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [(.pluto, 285.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        let withDouble = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [(.pluto, 285.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: true
        )
        let t1NoDouble = noDouble.first(where: { $0.type == 1 })?.strength ?? 0
        let t1Double   = withDouble.first(where: { $0.type == 1 })?.strength ?? 0
        #expect(t1NoDouble == 2.0, "Without double Pluto: type 1 = 2.0")
        #expect(t1Double   == 4.0, "With double Pluto: type 1 = 2.0 × 2.0 = 4.0")
    }

    @Test("calculateStrengths: factor not in selectedFactors is ignored")
    func testUnknownFactor_ignored() {
        // .earth has no entry in factorToPointId — its position should produce no effect
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 4, sign: 1, values: [9.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        let results = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [(.earth, 15.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        // .earth is not in factorToPointId, so type 1 stays 1.0
        let type1 = results.first(where: { $0.type == 1 })
        #expect(type1?.strength == 1.0)
    }

    @Test("calculateStrengths: same input always returns same output")
    func testDeterministic() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 0, sign: 3, values: [1.2, 0.9, 1.5, 1.1, 0.8, 1.3, 1.0, 0.7, 1.4])
        ])
        let r1 = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [(.sun, 75.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        let r2 = EnneagramCalculator.calculateStrengths(
            signs: signsData, houses: [:], factorPositions: [(.sun, 75.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        for i in 0..<9 {
            #expect(r1[i].type     == r2[i].type)
            #expect(r1[i].strength == r2[i].strength)
        }
    }
}

// MARK: - calculateDetails tests

struct EnneagramCalculateDetailsTests {

    @Test("calculateDetails: single factor in sign produces one line with inSigns=true")
    func testSingleFactorInSign() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 0, sign: 1, values: [1.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: [:], factorPositions: [(.sun, 15.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        #expect(details.count == 1)
        let line = details[0]
        #expect(line.factor == .sun)
        #expect(line.inSigns == true)
        #expect(line.positionIndex == 1)
        #expect(line.typeValues.count == 9)
        #expect(line.typeValues[0] == 1.5)
    }

    @Test("calculateDetails: useHouses=false produces only sign lines (no house, ASC, or MC lines)")
    func testUseHousesFalse_onlySignLines() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 0, sign: 1, values: ones9),
            signsEntry(pointId: 1001, sign: 1, values: ones9)  // ASC — should be ignored
        ])
        let housesData = Dictionary(uniqueKeysWithValues: [
            housesEntry(pointId: 0, house: 1, values: ones9)
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: housesData,
            factorPositions: [(.sun, 15.0)],
            cuspLongitudes: standardCusps, useHouses: false, doublePluto: false
        )
        #expect(details.allSatisfy { $0.inSigns }, "All lines should be in-signs when useHouses=false")
        #expect(!details.contains(where: { $0.factor == nil }), "No ASC/MC lines when useHouses=false")
    }

    @Test("calculateDetails: useHouses=true includes ASC in-sign line (factor==nil, specialLabel=ASC)")
    func testUseHousesTrue_includesAscLine() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 1001, sign: 1, values: ones9)
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: [:], factorPositions: [],
            cuspLongitudes: standardCusps, useHouses: true, doublePluto: false
        )
        let ascLine = details.first(where: { $0.specialLabel == "ASC" && $0.inSigns })
        #expect(ascLine != nil, "Should have ASC in-sign line when useHouses=true")
        #expect(ascLine?.factor == nil)
        #expect(ascLine?.positionIndex == 1)  // ASC at 15° = sign 1
    }

    @Test("calculateDetails: useHouses=true includes MC in-sign line (specialLabel=MC)")
    func testUseHousesTrue_includesMcLine() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 1002, sign: 10, values: ones9)  // MC in Capricorn
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: [:], factorPositions: [],
            cuspLongitudes: standardCusps, useHouses: true, doublePluto: false
        )
        let mcLine = details.first(where: { $0.specialLabel == "MC" && $0.inSigns })
        #expect(mcLine != nil, "Should have MC in-sign line when useHouses=true")
        #expect(mcLine?.positionIndex == 10)  // cusps[10]=285° = sign 10
    }

    @Test("calculateDetails: doublePluto=false gives one Pluto sign line")
    func testDoublePlutoFalse_onePlutoLine() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 10, sign: 10, values: ones9)
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: [:], factorPositions: [(.pluto, 285.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        let plutoLines = details.filter { $0.factor == .pluto }
        #expect(plutoLines.count == 1)
    }

    @Test("calculateDetails: doublePluto=true gives two Pluto sign lines")
    func testDoublePlutoTrue_twoPlutoLines() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 10, sign: 10, values: ones9)
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: [:], factorPositions: [(.pluto, 285.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: true
        )
        let plutoLines = details.filter { $0.factor == .pluto }
        #expect(plutoLines.count == 2, "doublePluto=true must yield two Pluto lines")
        #expect(plutoLines[0].typeValues == plutoLines[1].typeValues, "Both lines must carry identical values")
    }

    @Test("calculateDetails: each line contains exactly 9 type values")
    func testEachLineHasNineValues() {
        let signsData = Dictionary(uniqueKeysWithValues: [
            signsEntry(pointId: 0, sign: 1, values: [1.2, 0.9, 1.5, 1.1, 0.8, 1.3, 1.0, 0.7, 1.4])
        ])
        let details = EnneagramCalculator.calculateDetails(
            signs: signsData, houses: [:], factorPositions: [(.sun, 15.0)],
            cuspLongitudes: [], useHouses: false, doublePluto: false
        )
        for line in details {
            #expect(line.typeValues.count == 9, "Line for \(line.factor?.rawValue ?? -1) must have 9 values")
        }
    }
}

// MARK: - EnneagramDataLoader tests

struct EnneagramDataLoaderTests {

    @Test("EnneagramDataLoader: signs(updated:true) returns non-empty dictionary")
    func testSigns2012NonEmpty() {
        let data = EnneagramDataLoader.signs(updated: true)
        #expect(!data.isEmpty)
    }

    @Test("EnneagramDataLoader: signs(updated:false) returns non-empty dictionary")
    func testSignsOriginalNonEmpty() {
        let data = EnneagramDataLoader.signs(updated: false)
        #expect(!data.isEmpty)
    }

    @Test("EnneagramDataLoader: houses(updated:true) returns non-empty dictionary")
    func testHouses2012NonEmpty() {
        let data = EnneagramDataLoader.houses(updated: true)
        #expect(!data.isEmpty)
    }

    @Test("EnneagramDataLoader: houses(updated:false) returns non-empty dictionary")
    func testHousesOriginalNonEmpty() {
        let data = EnneagramDataLoader.houses(updated: false)
        #expect(!data.isEmpty)
    }

    @Test("EnneagramDataLoader: updated and original signs data differ")
    func testSignsDiffer() {
        let original = EnneagramDataLoader.signs(updated: false)
        let updated  = EnneagramDataLoader.signs(updated: true)
        #expect(original != updated, "2010 and 2012 sign tables should be different")
    }

    @Test("EnneagramDataLoader: all sign entries have exactly 9 values")
    func testSignsEntriesHaveNineValues() {
        let data = EnneagramDataLoader.signs(updated: true)
        for (key, values) in data {
            #expect(values.count == 9, "Key \(key) should have 9 values, got \(values.count)")
        }
    }

    @Test("EnneagramDataLoader: all house entries have exactly 9 values")
    func testHouseEntriesHaveNineValues() {
        let data = EnneagramDataLoader.houses(updated: true)
        for (key, values) in data {
            #expect(values.count == 9, "Key \(key) should have 9 values, got \(values.count)")
        }
    }

    @Test("EnneagramDataLoader: Sun in Aries (key=1) is present in original signs table")
    func testSunAriesKeyPresent() {
        let data = EnneagramDataLoader.signs(updated: false)
        #expect(data[1] != nil, "Key 1 (Sun in Aries) should exist in original signs data")
    }
}
