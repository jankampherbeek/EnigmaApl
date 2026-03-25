// DrawSignsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct DrawSignsTests {

    private let accuracy = 1e-10

    // MARK: - signOffsetAsc()

    @Test("signOffsetAsc: ascendant op 0° → offset 30°")
    func testSignOffsetAscAt0() {
        #expect(signOffsetAsc(0.0) == 30.0)
    }

    @Test("signOffsetAsc: ascendant halverwege teken (15°) → offset 15°")
    func testSignOffsetAscAt15() {
        #expect(signOffsetAsc(15.0) == 15.0)
    }

    @Test("signOffsetAsc: ascendant precies op tekengrens (30°) → offset 30°")
    func testSignOffsetAscAt30() {
        // 30 % 30 = 0 → 30 - 0 = 30
        #expect(signOffsetAsc(30.0) == 30.0)
    }

    @Test("signOffsetAsc: ascendant op 29° → offset 1°")
    func testSignOffsetAscAt29() {
        #expect(signOffsetAsc(29.0) == 1.0)
    }

    @Test("signOffsetAsc: ascendant op 60° (tekengrens Tweeling) → offset 30°")
    func testSignOffsetAscAt60() {
        #expect(signOffsetAsc(60.0) == 30.0)
    }

    @Test("signOffsetAsc: ascendant op 359° (359 % 30 = 29) → offset 1°")
    func testSignOffsetAscAt359() {
        #expect(signOffsetAsc(359.0) == 1.0)
    }

    @Test("signOffsetAsc: ascendant op 45° (halverwege Stier) → offset 15°")
    func testSignOffsetAscAt45() {
        // 45 % 30 = 15 → 30 - 15 = 15
        #expect(signOffsetAsc(45.0) == 15.0)
    }
}
