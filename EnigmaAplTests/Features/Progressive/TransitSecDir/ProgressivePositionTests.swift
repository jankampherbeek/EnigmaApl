// ProgressivePositionTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct ProgressivePositionTests {

    @Test("ProgressivePosition: stores longitude and declination correctly")
    func testInitStoresValues() {
        let pos = ProgressivePosition(longitude: 280.45, declination: -23.01)
        #expect(pos.longitude == 280.45)
        #expect(pos.declination == -23.01)
    }

    @Test("ProgressivePosition: accepts negative declination (southern hemisphere)")
    func testNegativeDeclination() {
        let pos = ProgressivePosition(longitude: 100.0, declination: -45.0)
        #expect(pos.declination == -45.0)
    }

    @Test("ProgressivePosition: accepts zero values")
    func testZeroValues() {
        let pos = ProgressivePosition(longitude: 0.0, declination: 0.0)
        #expect(pos.longitude == 0.0)
        #expect(pos.declination == 0.0)
    }

    @Test("ProgressivePosition: accepts longitude at upper boundary")
    func testLongitudeBoundary() {
        let pos = ProgressivePosition(longitude: 359.9999, declination: 0.0)
        #expect(pos.longitude == 359.9999)
    }
}
