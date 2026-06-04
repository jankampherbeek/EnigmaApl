// AgePointOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct AgePointOrchestratorTests {

    // Uniform cusps: 12 houses of exactly 30°, starting at 0°.
    // H1=0°, H2=30°, H3=60°, …, H12=330°
    private let uniformCusps: [Double] = stride(from: 0.0, to: 360.0, by: 30.0).map { $0 }

    // Realistic Koch cusps (northern latitude chart), all in ascending ecliptic order.
    // H5=86.926°, H6=106.505° are kept at the values used by the real-world longitude test.
    private let realisticCusps: [Double] = [
        10.0,    // H1 (ASC)
        32.0,    // H2
        57.0,    // H3
        80.0,    // H4 (IC)
        86.926,  // H5
        106.505, // H6
        190.0,   // H7 (DSC)
        212.0,   // H8
        237.0,   // H9
        260.0,   // H10 (MC)
        266.926, // H11
        286.505  // H12
    ]

    // Wrap-around cusps: H12 is near 350°, H1 is near 10° (crosses 0°/360°).
    private let wrapCusps: [Double] = [
        10.0, 40.0, 70.0, 100.0, 130.0, 160.0,
        190.0, 220.0, 250.0, 280.0, 310.0, 350.0
    ]

    private let sut = AgePointOrchestrator()

    // MARK: - agePointLongitude: at house cusps

    @Test("AgePoint: age 0 returns H1 (Ascendant)")
    func testAgeZeroReturnsH1() {
        let result = sut.agePointLongitude(age: 0, cusps: uniformCusps)
        #expect(abs(result - 0.0) < 0.001)
    }

    @Test("AgePoint: age 6 returns H2")
    func testAgeSixReturnsH2() {
        let result = sut.agePointLongitude(age: 6, cusps: uniformCusps)
        #expect(abs(result - 30.0) < 0.001)
    }

    @Test("AgePoint: age 12 returns H3")
    func testAgeTwelveReturnsH3() {
        let result = sut.agePointLongitude(age: 12, cusps: uniformCusps)
        #expect(abs(result - 60.0) < 0.001)
    }

    @Test("AgePoint: age 66 returns H12")
    func testAgeSixtySixReturnsH12() {
        let result = sut.agePointLongitude(age: 66, cusps: uniformCusps)
        #expect(abs(result - 330.0) < 0.001)
    }

    // MARK: - agePointLongitude: midpoints

    @Test("AgePoint: age 3 returns midpoint of H1-H2")
    func testAgeThreeReturnsMidpointH1H2() {
        // Uniform cusps: H1=0°, H2=30° → midpoint = 15°
        let result = sut.agePointLongitude(age: 3, cusps: uniformCusps)
        #expect(abs(result - 15.0) < 0.001)
    }

    @Test("AgePoint: age 9 returns midpoint of H2-H3")
    func testAgeNineReturnsMidpointH2H3() {
        let result = sut.agePointLongitude(age: 9, cusps: uniformCusps)
        #expect(abs(result - 45.0) < 0.001)
    }

    // MARK: - agePointLongitude: real-world case

    @Test("AgePoint: age 26.4131 with realistic cusps gives ~94.8°")
    func testRealWorldCase() {
        // H5=86.926°, H6=106.505°; age=26.4131 → houseIdx=4, fraction≈0.40218
        // expected ≈ 86.926 + 0.40218 * 19.579 ≈ 94.800°
        let result = sut.agePointLongitude(age: 26.4131, cusps: realisticCusps)
        #expect(abs(result - 94.800) < 0.01)
    }

    // MARK: - agePointLongitude: cycle repetition

    @Test("AgePoint: age 72 wraps back to H1")
    func testAgeSeventyTwoWrapsToH1() {
        let result = sut.agePointLongitude(age: 72, cusps: uniformCusps)
        #expect(abs(result - 0.0) < 0.001)
    }

    @Test("AgePoint: age 78 equals age 6")
    func testAgeSeventyEightEqualsAgeSix() {
        let at6  = sut.agePointLongitude(age: 6,  cusps: uniformCusps)
        let at78 = sut.agePointLongitude(age: 78, cusps: uniformCusps)
        #expect(abs(at6 - at78) < 0.001)
    }

    @Test("AgePoint: age 144 equals age 0 (two full cycles)")
    func testAgeTwoFullCycles() {
        let result = sut.agePointLongitude(age: 144, cusps: uniformCusps)
        #expect(abs(result - 0.0) < 0.001)
    }

    // MARK: - agePointLongitude: 0°/360° wrap-around (H12 → H1)

    @Test("AgePoint: H12→H1 wrap-around at age 69")
    func testH12ToH1WrapAround() {
        // wrapCusps: H12=350°, H1=10°; dist = 10-350 = -340+360 = 20°
        // age 69 → houseIdx=11, fraction=0.5 → 350 + 0.5*20 = 360 → 0° ... wait
        // Actually 350 + 10 = 360, mod 360 = 0. But midpoint of 350→10 is 0 (or 360).
        // fraction = (69-66)/6 = 0.5, position = 350 + 0.5*20 = 360 → normalised to 0°
        let result = sut.agePointLongitude(age: 69, cusps: wrapCusps)
        // The midpoint between 350° and 10° going forward is 0° (360°)
        let expected = 0.0
        #expect(abs(result - expected) < 0.001)
    }

    @Test("AgePoint: H12→H1 end of cycle reaches H1")
    func testH12EndReachesH1() {
        let result = sut.agePointLongitude(age: 72, cusps: wrapCusps)
        #expect(abs(result - wrapCusps[0]) < 0.001)
    }

    // MARK: - agePointLongitude: guard on short cusps array

    @Test("AgePoint: returns first cusp when array has fewer than 12 elements")
    func testShortCuspsArrayReturnsFirst() {
        let shortCusps = [45.0, 75.0, 105.0]
        let result = sut.agePointLongitude(age: 10, cusps: shortCusps)
        #expect(result == 45.0)
    }

    // MARK: - ageFromLongitude: at known cusps

    @Test("AgeFromLongitude: longitude at H1 returns age 0")
    func testLongitudeAtH1ReturnsAgeZero() {
        let (years, months, totalYears) = sut.ageFromLongitude(longitude: 0.0, cusps: uniformCusps)
        #expect(years == 0)
        #expect(months == 0)
        #expect(abs(totalYears) < 0.001)
    }

    @Test("AgeFromLongitude: longitude at H2 returns age 6")
    func testLongitudeAtH2ReturnsAgeSix() {
        let (years, months, totalYears) = sut.ageFromLongitude(longitude: 30.0, cusps: uniformCusps)
        #expect(years == 6)
        #expect(months == 0)
        #expect(abs(totalYears - 6.0) < 0.001)
    }

    @Test("AgeFromLongitude: longitude at midpoint H1-H2 returns age 3")
    func testLongitudeAtMidpointH1H2ReturnsAgeThree() {
        let (years, months, totalYears) = sut.ageFromLongitude(longitude: 15.0, cusps: uniformCusps)
        #expect(years == 3)
        #expect(months == 0)
        #expect(abs(totalYears - 3.0) < 0.001)
    }

    // MARK: - ageFromLongitude: roundtrip consistency

    @Test("AgeFromLongitude: roundtrip age 26.4131 with realistic cusps")
    func testRoundtripRealWorldCase() {
        let longitude = sut.agePointLongitude(age: 26.4131, cusps: realisticCusps)
        let (_, _, totalYears) = sut.ageFromLongitude(longitude: longitude, cusps: realisticCusps)
        #expect(abs(totalYears - 26.4131) < 0.001)
    }

    @Test("AgeFromLongitude: roundtrip age 3 with uniform cusps")
    func testRoundtripAgeThree() {
        let longitude = sut.agePointLongitude(age: 3, cusps: uniformCusps)
        let (_, _, totalYears) = sut.ageFromLongitude(longitude: longitude, cusps: uniformCusps)
        #expect(abs(totalYears - 3.0) < 0.001)
    }

    @Test("AgeFromLongitude: roundtrip age 45 with uniform cusps")
    func testRoundtripAgeFortyFive() {
        let longitude = sut.agePointLongitude(age: 45, cusps: uniformCusps)
        let (_, _, totalYears) = sut.ageFromLongitude(longitude: longitude, cusps: uniformCusps)
        #expect(abs(totalYears - 45.0) < 0.001)
    }

    // MARK: - ageFromLongitude: guard on short cusps array

    @Test("AgeFromLongitude: returns (0,0,0) when array has fewer than 12 elements")
    func testShortCuspsArrayReturnsZero() {
        let shortCusps = [45.0, 75.0]
        let (years, months, totalYears) = sut.ageFromLongitude(longitude: 50.0, cusps: shortCusps)
        #expect(years == 0)
        #expect(months == 0)
        #expect(totalYears == 0.0)
    }
}
