// ProgressiveCalcRequestTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct ProgressiveCalcRequestTests {

    @Test("ProgressiveCalcRequest: stores julianDay correctly")
    func testInitStoresJulianDay() {
        let jd = 2455197.5
        let request = ProgressiveCalcRequest(julianDay: jd)
        #expect(request.julianDay == jd)
    }

    @Test("ProgressiveCalcRequest: accepts Julian Day for year 1900")
    func testJulianDayYear1900() {
        let request = ProgressiveCalcRequest(julianDay: 2415021.0)
        #expect(request.julianDay == 2415021.0)
    }

    @Test("ProgressiveCalcRequest: accepts Julian Day for year 2100")
    func testJulianDayYear2100() {
        let request = ProgressiveCalcRequest(julianDay: 2488070.0)
        #expect(request.julianDay == 2488070.0)
    }
}
