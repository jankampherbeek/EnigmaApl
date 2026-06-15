// PrimaryTimeKeyTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct PrimaryTimeKeyTests {

    @Test("PrimaryTimeKey: brahe has correct rbKey")
    func testRetrievingDetails() {
        #expect(PrimaryTimeKey.brahe.rbKey == "enum.primarytimekey.brahe")
    }

    @Test("PrimaryTimeKey: all cases have a non-empty rbKey")
    func testAvailabilityOfDetailsForAllCases() {
        for timeKey in PrimaryTimeKey.allCases {
            #expect(!timeKey.rbKey.isEmpty)
        }
    }

    @Test("PrimaryTimeKey: rawValue 4 maps to vanDam")
    func testRetrievingWithRawValue() {
        #expect(PrimaryTimeKey(rawValue: 4) == .vanDam)
    }

    @Test("PrimaryTimeKey: invalid rawValue returns nil")
    func testRetrievingWithInvalidRawValue() {
        #expect(PrimaryTimeKey(rawValue: 333) == nil)
    }

    @Test("PrimaryTimeKey: allCases has exactly 5 elements with correct rbKeys")
    func testAllPrimaryTimeKeyDetails() {
        let cases = PrimaryTimeKey.allCases
        #expect(cases.count == 5)
        #expect(cases[0].rbKey == "enum.primarytimekey.placidus")
        #expect(cases[1].rbKey == "enum.primarytimekey.naibod")
        #expect(cases[2].rbKey == "enum.primarytimekey.brahe")
        #expect(cases[3].rbKey == "enum.primarytimekey.ptolemy")
        #expect(cases[4].rbKey == "enum.primarytimekey.vandam")
    }
}
