//
//  DrawCuspsTests.swift
//  EnigmaAplTests
//

import Testing
@testable import EnigmaApl

struct DrawCuspsTests {

    private let accuracy = 1e-10

    // MARK: - cuspPositionText()

    @Test("cuspPositionText: 0° geeft '0°00''")
    func testCuspPositionTextZero() {
        let result = cuspPositionText(longitude: 0.0)
        #expect(result == "0°00'")
    }

    @Test("cuspPositionText: 15°30' binnen een teken")
    func testCuspPositionText15_30() {
        // 15.5° × 60 = 930 totaal seconden. 930/60=15 graden, 930%60=30 minuten
        let result = cuspPositionText(longitude: 15.5)
        #expect(result == "15°30'")
    }

    @Test("cuspPositionText: longitude in tweede teken (45.5°) geeft zelfde als 15.5°")
    func testCuspPositionTextSecondSign() {
        // 45.5 % 30 = 15.5 → zelfde als longitude 15.5
        let result = cuspPositionText(longitude: 45.5)
        #expect(result == "15°30'")
    }

    @Test("cuspPositionText: 29° geeft '29°00''")
    func testCuspPositionText29() {
        let result = cuspPositionText(longitude: 29.0)
        #expect(result == "29°00'")
    }

    @Test("cuspPositionText: 1 minuut (1/60 graden) geeft '0°01''")
    func testCuspPositionTextOneMinute() {
        let result = cuspPositionText(longitude: 1.0 / 60.0)
        #expect(result == "0°01'")
    }

    @Test("cuspPositionText: minuten worden nul-gevuld tot twee cijfers")
    func testCuspPositionTextZeroPadding() {
        // 10 + 5/60 = 10.0833... → inSign = 10.0833, total = Int(10.0833 * 60) = 605 → 10°05'
        let result = cuspPositionText(longitude: 10.0 + 5.0 / 60.0)
        #expect(result == "10°05'")
    }

    // MARK: - cuspTextRotation()

    @Test("cuspTextRotation: hoek 0° geeft 360°")
    func testCuspTextRotationAngle0() {
        // angle <= 90: r = 0 - 90 = -90. return 180 + (90 - (-90)) = 360
        let result = cuspTextRotation(angle: 0)
        #expect(abs(result - 360.0) < accuracy)
    }

    @Test("cuspTextRotation: hoek 90° geeft 270°")
    func testCuspTextRotationAngle90() {
        // angle <= 90: r = 90 - 90 = 0. return 180 + 90 = 270
        let result = cuspTextRotation(angle: 90)
        #expect(abs(result - 270.0) < accuracy)
    }

    @Test("cuspTextRotation: hoek 180° geeft 360°")
    func testCuspTextRotationAngle180() {
        // else branch: r = 180 - 270 = -90. return 180 + (90 - (-90)) = 360
        let result = cuspTextRotation(angle: 180)
        #expect(abs(result - 360.0) < accuracy)
    }

    @Test("cuspTextRotation: hoek 270° geeft 270°")
    func testCuspTextRotationAngle270() {
        // else branch (270 is not > 270): r = 270 - 270 = 0. return 180 + 90 = 270
        let result = cuspTextRotation(angle: 270)
        #expect(abs(result - 270.0) < accuracy)
    }

    @Test("cuspTextRotation: hoek 300° (> 270) gebruikt eerste tak, geeft 60°")
    func testCuspTextRotationAngle300() {
        // angle > 270: r = 300 - 90 = 210. return 180 + (90 - 210) = 60
        let result = cuspTextRotation(angle: 300)
        #expect(abs(result - 60.0) < accuracy)
    }

    @Test("cuspTextRotation: hoek 45° geeft 315°")
    func testCuspTextRotationAngle45() {
        // angle <= 90: r = 45 - 90 = -45. return 180 + (90 - (-45)) = 315
        let result = cuspTextRotation(angle: 45)
        #expect(abs(result - 315.0) < accuracy)
    }
}
