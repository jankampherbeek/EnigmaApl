// PrimaryMethodTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct PrimaryMethodTests {

    @Test("PrimaryMethod: regiomontanus has correct rbKey")
    func testRetrievingDetails() {
        #expect(PrimaryMethod.regiomontanus.rbKey == "enum.primarymethod.regiomontanus")
    }

    @Test("PrimaryMethod: all cases have a non-empty rbKey")
    func testAvailabilityOfDetailsForAllCases() {
        for method in PrimaryMethod.allCases {
            #expect(!method.rbKey.isEmpty)
        }
    }

    @Test("PrimaryMethod: rawValue 1 maps to regiomontanus")
    func testRetrievingWithRawValue() {
        #expect(PrimaryMethod(rawValue: 1) == .regiomontanus)
    }

    @Test("PrimaryMethod: invalid rawValue returns nil")
    func testRetrievingWithInvalidRawValue() {
        #expect(PrimaryMethod(rawValue: 500) == nil)
    }

    @Test("PrimaryMethod: allCases has exactly 2 elements with correct rbKeys")
    func testAllPrimaryMethodDetails() {
        let cases = PrimaryMethod.allCases
        #expect(cases.count == 2)
        #expect(cases[0].rbKey == "enum.primarymethod.placidus")
        #expect(cases[1].rbKey == "enum.primarymethod.regiomontanus")
    }
}
