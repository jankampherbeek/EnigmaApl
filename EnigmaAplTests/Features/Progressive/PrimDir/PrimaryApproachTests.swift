// PrimaryApproachTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct PrimaryApproachTests {

    @Test("PrimaryApproach: mundane has correct rbKey")
    func testRetrievingDetails() {
        #expect(PrimaryApproach.mundane.rbKey == "enum.primaryapproach.mundane")
    }

    @Test("PrimaryApproach: all cases have a non-empty rbKey")
    func testAvailabilityOfDetailsForAllCases() {
        for approach in PrimaryApproach.allCases {
            #expect(!approach.rbKey.isEmpty)
        }
    }

    @Test("PrimaryApproach: rawValue 1 maps to ecliptical (zodiacal)")
    func testRetrievingWithRawValue() {
        #expect(PrimaryApproach(rawValue: 1) == .ecliptical)
    }

    @Test("PrimaryApproach: invalid rawValue returns nil")
    func testRetrievingWithInvalidRawValue() {
        #expect(PrimaryApproach(rawValue: 333) == nil)
    }

    @Test("PrimaryApproach: allCases has exactly 2 elements with correct rbKeys")
    func testAllPrimaryApproachDetails() {
        let cases = PrimaryApproach.allCases
        #expect(cases.count == 2)
        #expect(cases[0].rbKey == "enum.primaryapproach.mundane")
        #expect(cases[1].rbKey == "enum.primaryapproach.ecliptical")
    }
}
