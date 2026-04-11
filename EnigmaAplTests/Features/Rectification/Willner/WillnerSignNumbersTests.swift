// WillnerSignNumbersTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Tests for WillnerSignNumbers.calculate().
///
/// The number arrays are derived from the C# Number.cs sign arithmetic.
/// Index 0 is always 0 (unused). Indices 1–4 may be 0 (skip) or positive.
struct WillnerSignNumbersTests {

    @Test("WillnerSignNumbers: arrays have length 5")
    func testArrayLength() {
        let (moon, uranus) = WillnerSignNumbers.calculate(sunSign: 3, moonSign: 6, uranusSign: 9)
        #expect(moon.count   == 5)
        #expect(uranus.count == 5)
    }

    @Test("WillnerSignNumbers: index 0 is always 0")
    func testIndexZeroIsZero() {
        let (moon, uranus) = WillnerSignNumbers.calculate(sunSign: 1, moonSign: 1, uranusSign: 1)
        #expect(moon[0]   == 0)
        #expect(uranus[0] == 0)
    }

    @Test("WillnerSignNumbers: no duplicate non-zero values in moon array")
    func testMoonNoDuplicates() {
        let (moon, _) = WillnerSignNumbers.calculate(sunSign: 4, moonSign: 7, uranusSign: 10)
        let nonZero = moon.filter { $0 != 0 }
        #expect(nonZero.count == Set(nonZero).count)
    }

    @Test("WillnerSignNumbers: no duplicate non-zero values in uranus array")
    func testUranusNoDuplicates() {
        let (_, uranus) = WillnerSignNumbers.calculate(sunSign: 4, moonSign: 7, uranusSign: 10)
        let nonZero = uranus.filter { $0 != 0 }
        #expect(nonZero.count == Set(nonZero).count)
    }

    @Test("WillnerSignNumbers: all non-zero numbers are positive")
    func testAllNumbersPositive() {
        for sun in 1...12 {
            for moon in 1...12 {
                let (moonNums, uranusNums) = WillnerSignNumbers.calculate(sunSign: sun, moonSign: moon, uranusSign: 6)
                for i in 1...4 {
                    #expect(moonNums[i]   >= 0)
                    #expect(uranusNums[i] >= 0)
                }
            }
        }
    }

    @Test("WillnerSignNumbers: sun=3 moon=6 uranus=9 produces expected moon[1]")
    func testKnownMoonNumber() {
        // Manual calculation for sunSign=3, moonSign=6, offset=17:
        //   num  = 17 - 6 = 11
        //   num2 = 17 - 3 = 14 → > 12 → 2
        //   num3 = 11 * 2 + 30 = 52
        //   num4 = floor((52 - 2) / 12) = floor(50/12) = 4
        //   moonNums[1] = 2 + 4*12 = 50
        let (moon, _) = WillnerSignNumbers.calculate(sunSign: 3, moonSign: 6, uranusSign: 9)
        #expect(moon[1] == 50)
    }

    @Test("WillnerSignNumbers: sun=3 moon=6 uranus=9 produces expected uranus[1]")
    func testKnownUranusNumber() {
        // Manual calculation for sunSign=3, uranusSign=9, offset=22:
        //   num5 = 22 - 9 = 13 → > 12 → 1
        //   num6 = 22 - 3 = 19 → > 12 → 7
        //   num7 = 1 * 7 + 30 = 37
        //   num8 = floor((37 - 7) / 12) = floor(30/12) = 2
        //   uranusNums[1] = 7 + 2*12 = 31
        let (_, uranus) = WillnerSignNumbers.calculate(sunSign: 3, moonSign: 6, uranusSign: 9)
        #expect(uranus[1] == 31)
    }
}
