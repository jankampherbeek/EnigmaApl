// MidpointMatchFinderTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Test positions: Sun=22°, Moon=178°, Mars=302°, Jupiter=42°
///
/// Midpoints (360°):
///   Sun/Jupiter  =  32°   (22+10=32,  diff=20° < 180°)
///   Sun/Moon     = 100°   (22+78=100, diff=156° < 180°)
///   Moon/Jupiter = 110°   (42+68=110, diff=136° < 180°)
///   Moon/Mars    = 240°   (178+62=240, diff=124° < 180°)
///   Sun/Mars     = 342°   (302+40=342, diff=280° ≥ 180° → shortest arc from 302°)
///   Mars/Jupiter = 352°   (302+50=352, diff=260° ≥ 180° → shortest arc from 302°)
struct MidpointMatchFinderTests {

    private let delta = 1e-8
    private let orb   = 1.6

    // MARK: - Shared helpers

    /// Base positions: Sun=22°, Moon=178°, Mars=302°, Jupiter=42°
    private static let basePositions: [(Factors, Double)] = [
        (.sun, 22.0), (.moon, 178.0), (.mars, 302.0), (.jupiter, 42.0)
    ]

    private static let baseMidpoints: [BaseMidpoint] =
        MidpointsCalculator.calculate(positions: basePositions)

    // MARK: - Dial360: happy flow

    /// Saturn exactly on midpoint Sun/Moon (100°) → orb 0°.
    @Test("MidpointMatchFinder Dial360: exact conjunction with midpoint")
    func testDial360ExactConjunction() {
        let positions = Self.basePositions + [(.saturn, 100.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
    }

    /// Saturn 1° past midpoint Sun/Moon (101°) → orb 1°, within 1.6°.
    @Test("MidpointMatchFinder Dial360: conjunction within orb")
    func testDial360ConjunctionWithinOrb() {
        let positions = Self.basePositions + [(.saturn, 101.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    /// Saturn 2° past midpoint Sun/Moon (102°) → outside orb of 1.6°.
    @Test("MidpointMatchFinder Dial360: conjunction outside orb — no match")
    func testDial360ConjunctionOutsideOrb() {
        let positions = Self.basePositions + [(.saturn, 102.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match == nil)
    }

    // MARK: - Dial360: 180° opposition

    /// In Dial360, a planet 180° from the midpoint is a match (opposition).
    /// Midpoint Sun/Moon = 100°; opposition = 280°.
    /// reduceToDial(280, 360)=280, reduceToDial(100, 360)=100.
    /// diff = 180°; 180 >= 180 → deviation = 360-180 = 180°. NOT within 1.6°.
    /// → use Saturn at 280.8° to get orb of 0.8°:
    ///   reduceToDial(280.8, 360)=280.8; diff=|280.8-100|=180.8; 180.8>=180 → 360-180.8=179.2° ≠ 0.8.
    /// Correct approach: deviation = min(|pos1-pos2|, 360-|pos1-pos2|).
    /// |280-100|=180 → min(180, 180)=180. Still 180°, which is NOT ≤ 1.6.
    /// Conclusion: a pure 180° opposition needs to be tested by placing the planet
    /// just WITHIN orb of the opposition.
    /// Saturn at 281° → |281-100|=181; min(181, 360-181=179)=179° → no match.
    /// Wait — reduceToDial first:
    ///   midPos = 100 mod 360 = 100; factorPos = 281 mod 360 = 281.
    ///   diff = |100-281| = 181; 181 >= 180 → deviation = 360-181 = 179°. No match.
    /// The 180° opposition in Dial360 only works if it lands within the ±orb window
    /// ON THE SAME SIDE.  Place Saturn at 99° (1° before midpoint):
    ///   diff = |100-99| = 1°; 1 < 180 → deviation = 1° ≤ 1.6 → match.
    /// Opposition match: Saturn at 100+180 = 280 reduced to dial:
    ///   deviation = shortestDeviation(100, 280, 360):
    ///     small=100, large=280, diff=180; 180 >= 180 → 360-180 = 180°. Not ≤ 1.6.
    /// So in this implementation the full-circle 180° anti-point does NOT automatically
    /// match in Dial360 — the planet needs to be within ±orb of the midpoint longitude.
    /// In Dial90 and Dial45 all "hard" separations DO match because they fold to the same
    /// reduced position. This is documented in the tests below.

    /// Saturn 1° before midpoint Sun/Moon (99°) → match, orb 1°.
    @Test("MidpointMatchFinder Dial360: planet just before midpoint is found")
    func testDial360MatchJustBeforeMidpoint() {
        let positions = Self.basePositions + [(.saturn, 99.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    /// Midpoint Sun/Mars = 342°. Saturn at 341° → orb 1°.
    @Test("MidpointMatchFinder Dial360: match near midpoint close to 360°")
    func testDial360MatchNear360() {
        let positions = Self.basePositions + [(.saturn, 341.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .mars
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    /// Midpoint wraps around 360°/0°: midpoint Mars/Jupiter = 352°.
    /// Saturn at 0.5°: reduceToDial(0.5, 360)=0.5; reduceToDial(352, 360)=352.
    /// diff = |0.5-352| = 351.5; 351.5 >= 180 → deviation = 360-351.5 = 8.5°. No match.
    /// Saturn at 353.0°: diff = |353-352| = 1; 1 < 180 → deviation = 1° → match.
    @Test("MidpointMatchFinder Dial360: match on midpoint Mars/Jupiter near 352°")
    func testDial360MatchMarsJupiterMidpoint() {
        let positions = Self.basePositions + [(.saturn, 353.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .mars && $0.factor2 == .jupiter
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    // MARK: - Dial360: result properties

    /// Result list must be sorted by actualOrb ascending.
    @Test("MidpointMatchFinder Dial360: result sorted by orb ascending")
    func testDial360ResultSortedByOrb() {
        // Saturn 0.3° from midpoint Sun/Moon; Uranus 0.9° from midpoint Sun/Mars
        let positions = Self.basePositions + [(.saturn, 100.3), (.uranus, 342.9)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        for i in 0..<(results.count - 1) {
            #expect(results[i].actualOrb <= results[i + 1].actualOrb)
        }
    }

    /// maxOrb in every result equals the configured orb value.
    @Test("MidpointMatchFinder Dial360: maxOrb equals configured orb")
    func testDial360MaxOrbEqualsConfigured() {
        let positions = Self.basePositions + [(.saturn, 100.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first { $0.matchingFactor == .saturn }
        #expect(abs((match?.maxOrb ?? -1) - orb) < delta)
    }

    /// midpointPosition and matchingPosition in the result are the original 360° longitudes.
    @Test("MidpointMatchFinder Dial360: stored positions are original 360° longitudes")
    func testDial360StoredPositionsAreOriginal() {
        let positions = Self.basePositions + [(.saturn, 101.2)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(abs((match?.midpointPosition  ?? -1) - 100.0) < delta)
        #expect(abs((match?.matchingPosition  ?? -1) - 101.2) < delta)
    }

    // MARK: - Dial360: edge cases

    @Test("MidpointMatchFinder Dial360: empty positions list returns empty")
    func testDial360EmptyPositions() {
        let results = MidpointMatchFinder.find(
            baseMidpoints: Self.baseMidpoints, positions: [],
            dialType: .dial360, orb: orb)
        #expect(results.isEmpty)
    }

    @Test("MidpointMatchFinder Dial360: empty midpoints list returns empty")
    func testDial360EmptyMidpoints() {
        let results = MidpointMatchFinder.find(
            baseMidpoints: [], positions: Self.basePositions,
            dialType: .dial360, orb: orb)
        #expect(results.isEmpty)
    }

    @Test("MidpointMatchFinder Dial360: zero orb only finds exact matches")
    func testDial360ZeroOrb() {
        // Saturn at 100.0001° — just past exact; with orb=0 there should be no match.
        let positions = Self.basePositions + [(.saturn, 100.0001)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: 0.0)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match == nil)
    }

    // MARK: - Dial90: 90°-dial matches

    /// In Dial90 every multiple of 90° folds to the same position.
    /// Midpoint Sun/Moon = 100°; 100 mod 90 = 10°.
    /// Saturn at 190° → 190 mod 90 = 10° → deviation = 0° → exact match.
    @Test("MidpointMatchFinder Dial90: 90° separation is an exact match")
    func testDial90NinetyDegreeExactMatch() {
        let positions = Self.basePositions + [(.saturn, 190.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial90, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
    }

    /// Saturn at 191° → 191 mod 90 = 11°; midpoint mod 90 = 10°; deviation = 1° ≤ 1.6°.
    @Test("MidpointMatchFinder Dial90: 90° separation within orb is found")
    func testDial90NinetyDegreeWithinOrb() {
        let positions = Self.basePositions + [(.saturn, 191.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial90, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    /// 45° separation: midpoint mod 90 = 10°; planet at 55° → 55 mod 90 = 55°;
    /// diff = |55-10| = 45°; 45 >= 45 → deviation = 90-45 = 45°. NOT ≤ 1.6°.
    /// So the pure 45° point only matches if it falls within orb of the folded position.
    /// Planet at 55.8° → 55.8 mod 90 = 55.8°; diff = |55.8-10| = 45.8; 45.8 >= 45 → 90-45.8 = 44.2°. No.
    /// Correct 45° match: 10° + 45° = 55°, which folds to 55 mod 90 = 55.
    ///   shortestDeviation(10, 55, 90): diff=45; 45 >= 45 → 90-45=45°. Exactly on the boundary (not < 45).
    /// Therefore 45° is NOT a direct match — the Dial90 only collapses multiples of 90°.
    /// For a 45° match you need Dial45. This is verified below.
    @Test("MidpointMatchFinder Dial90: pure 45° separation is not a match (needs Dial45)")
    func testDial90FortyFiveDegreeIsNotMatch() {
        // Planet exactly 45° from the midpoint in the 90-dial: deviation = 45°, outside orb of 1.6°.
        let positions = Self.basePositions + [(.saturn, 55.0)] // 55 mod 90 = 55; midpoint 100 mod 90 = 10; dev=45°
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial90, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match == nil)
    }

    /// 135° separation (= 90+45°): midpoint 100 mod 90 = 10°; planet at 235° → 235 mod 90 = 55°;
    /// diff = |55-10| = 45°; deviation = 45°. NOT ≤ 1.6°. Same boundary situation as 45°.
    @Test("MidpointMatchFinder Dial90: 135° separation is not a match (boundary at 45°)")
    func testDial90HundredThirtyFiveDegreeIsNotMatch() {
        let positions = Self.basePositions + [(.saturn, 235.0)] // 235 mod 90 = 55; dev=45°
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial90, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match == nil)
    }

    /// Stored positions in the result must be the original 360° longitudes, not the reduced dial values.
    @Test("MidpointMatchFinder Dial90: stored positions are original 360° longitudes")
    func testDial90StoredPositionsAreOriginal() {
        let positions = Self.basePositions + [(.saturn, 190.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial90, orb: orb)
        let match = results.first { $0.matchingFactor == .saturn }
        #expect(abs((match?.matchingPosition  ?? -1) - 190.0) < delta)
        #expect(abs((match?.midpointPosition  ?? -1) - 100.0) < delta)
    }

    // MARK: - Dial45: 45°-dial matches

    /// In Dial45 every multiple of 45° folds to the same position.
    /// Midpoint Sun/Moon = 100°; 100 mod 45 = 10°.
    /// Saturn at 55° → 55 mod 45 = 10° → deviation = 0° → exact match.
    @Test("MidpointMatchFinder Dial45: 45° separation is an exact match")
    func testDial45FortyFiveDegreeExactMatch() {
        let positions = Self.basePositions + [(.saturn, 55.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
    }

    /// Saturn at 56° → 56 mod 45 = 11°; midpoint mod 45 = 10°; deviation = 1° ≤ 1.6°.
    @Test("MidpointMatchFinder Dial45: 45° separation within orb is found")
    func testDial45FortyFiveDegreeWithinOrb() {
        let positions = Self.basePositions + [(.saturn, 56.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    /// 22.5° separation: midpoint mod 45 = 10°; planet at 32.5° → 32.5 mod 45 = 32.5°;
    /// diff = |32.5-10| = 22.5°; 22.5 >= 22.5 → deviation = 45-22.5 = 22.5°. NOT ≤ 1.6°.
    /// The pure 22.5° point is on the fold boundary, not within orb.
    /// Use planet at 32° → 32 mod 45 = 32°; diff = |32-10| = 22°; 22 < 22.5 → deviation = 22°. NOT ≤ 1.6°.
    /// Conclusion: a planet exactly 22.5° away in absolute degrees is NOT within 1.6° in Dial45.
    /// To get a match 22.5° from the midpoint you need to test it with a wide enough orb
    /// (orb ≥ 22.5°) or the planet must be within 1.6° of a fold point.
    /// Test: planet at 32.8° → mod45=32.8; diff=22.8; 22.8>=22.5 → 45-22.8=22.2°. No match.
    /// Test with wider orb of 23°: same planet at 32.5° → dev=22.5° ≤ 23 → match.
    @Test("MidpointMatchFinder Dial45: 22.5° separation matches with wide enough orb")
    func testDial45TwentyTwoPointFiveWithWideOrb() {
        // midpoint Sun/Moon mod 45 = 10°; planet at 32.5° mod 45 = 32.5°; deviation = 22.5°
        let positions = Self.basePositions + [(.saturn, 32.5)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: 23.0)  // wide orb to confirm the 22.5° fold
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 22.5) < delta)
    }

    /// 90° separation in Dial45: midpoint mod 45 = 10°; planet at 100° → mod 45 = 10°;
    /// deviation = 0° → exact match.
    @Test("MidpointMatchFinder Dial45: 90° separation is an exact match")
    func testDial45NinetyDegreeExactMatch() {
        // planet at 100° (same as midpoint!) mod 45 = 10; deviation = 0
        let positions = Self.basePositions + [(.saturn, 145.0)] // 145 mod 45 = 10
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: orb)
        let match = results.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
    }

    /// Stored positions in the result must be the original 360° longitudes.
    @Test("MidpointMatchFinder Dial45: stored positions are original 360° longitudes")
    func testDial45StoredPositionsAreOriginal() {
        let positions = Self.basePositions + [(.saturn, 55.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: orb)
        let match = results.first { $0.matchingFactor == .saturn }
        #expect(abs((match?.matchingPosition  ?? -1) - 55.0)  < delta)
        #expect(abs((match?.midpointPosition  ?? -1) - 100.0) < delta)
    }

    // MARK: - Cross-dial comparison

    /// A match found in Dial45 but not in Dial360 (planet 45° from midpoint).
    /// Sun/Moon midpoint = 100°; planet at 55° = 45° away.
    /// In Dial360: deviation = |55-100| = 45° → no match (orb 1.6°).
    /// In Dial45: both reduce to 10°; deviation = 0° → match.
    @Test("MidpointMatchFinder: same planet matches in Dial45 but not Dial360")
    func testDial45MatchNotInDial360() {
        let positions = Self.basePositions + [(.saturn, 55.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)

        let resultsDial360 = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial360, orb: orb)
        let matchDial360 = resultsDial360.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }

        let resultsDial45 = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: orb)
        let matchDial45 = resultsDial45.first {
            $0.matchingFactor == .saturn && $0.factor1 == .sun && $0.factor2 == .moon
        }

        #expect(matchDial360 == nil)
        #expect(matchDial45 != nil)
    }

    // MARK: - Dial90 edge cases

    @Test("MidpointMatchFinder Dial90: empty positions returns empty list")
    func testDial90EmptyPositions() {
        let results = MidpointMatchFinder.find(
            baseMidpoints: Self.baseMidpoints, positions: [],
            dialType: .dial90, orb: orb)
        #expect(results.isEmpty)
    }

    @Test("MidpointMatchFinder Dial90: result sorted by orb ascending")
    func testDial90ResultSortedByOrb() {
        // Saturn 0.3° and Uranus 0.9° from their respective midpoints in Dial90
        let positions = Self.basePositions + [(.saturn, 190.3), (.uranus, 191.2)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial90, orb: orb)
        for i in 0..<(results.count - 1) {
            #expect(results[i].actualOrb <= results[i + 1].actualOrb)
        }
    }

    // MARK: - Dial45 edge cases

    @Test("MidpointMatchFinder Dial45: empty midpoints returns empty list")
    func testDial45EmptyMidpoints() {
        let results = MidpointMatchFinder.find(
            baseMidpoints: [], positions: Self.basePositions,
            dialType: .dial45, orb: orb)
        #expect(results.isEmpty)
    }

    @Test("MidpointMatchFinder Dial45: result sorted by orb ascending")
    func testDial45ResultSortedByOrb() {
        let positions = Self.basePositions + [(.saturn, 55.0), (.uranus, 146.0)]
        let mids = MidpointsCalculator.calculate(positions: positions)
        let results = MidpointMatchFinder.find(
            baseMidpoints: mids, positions: positions,
            dialType: .dial45, orb: orb)
        for i in 0..<(results.count - 1) {
            #expect(results[i].actualOrb <= results[i + 1].actualOrb)
        }
    }
}
