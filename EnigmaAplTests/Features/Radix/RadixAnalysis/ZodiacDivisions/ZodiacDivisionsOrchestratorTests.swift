// ZodiacDivisionsOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct ZodiacDivisionsOrchestratorTests {

    // MARK: - Signs

    @Test("Signs: Aries at 0°, 15°, 29.999°")
    func testSignsAries() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .signs) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 15.0, method: .signs) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 29.999, method: .signs) == 0)
    }

    @Test("Signs: Taurus at 30°, 45°")
    func testSignsTaurus() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 30.0, method: .signs) == 1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 45.0, method: .signs) == 1)
    }

    @Test("Signs: Pisces at 330°, 359.999°")
    func testSignsPisces() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 330.0, method: .signs) == 11)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 359.999, method: .signs) == 11)
    }

    @Test("Signs: Libra at 180°")
    func testSignsLibra() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .signs) == 6)
    }

    // MARK: - DecansPlanet

    @Test("DecansPlanet: decans 1–7 return correct planet indices")
    func testDecansPlanet() {
        // Decan 1 (0–9.999°): Mars (4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .decansPlanet) == 4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 5.0, method: .decansPlanet) == 4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 9.999, method: .decansPlanet) == 4)
        // Decan 2 (10–19.999°): Sun (0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 10.0, method: .decansPlanet) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 15.0, method: .decansPlanet) == 0)
        // Decan 3 (20–29.999°): Venus (3)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 20.0, method: .decansPlanet) == 3)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 25.0, method: .decansPlanet) == 3)
        // Decan 4 (30–39.999°): Mercury (2)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 30.0, method: .decansPlanet) == 2)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 35.0, method: .decansPlanet) == 2)
        // Decan 5 (40–49.999°): Moon (1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 40.0, method: .decansPlanet) == 1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 45.0, method: .decansPlanet) == 1)
        // Decan 6 (50–59.999°): Saturn (6)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 50.0, method: .decansPlanet) == 6)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 55.0, method: .decansPlanet) == 6)
        // Decan 7 (60–69.999°): Jupiter (5)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 60.0, method: .decansPlanet) == 5)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 65.0, method: .decansPlanet) == 5)
    }

    @Test("DecansPlanet: Moon (1) at 180°")
    func testDecansPlanetMidZodiac() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .decansPlanet) == 1)
    }

    // MARK: - DecansSign

    @Test("DecansSign: Aries decans map to Aries, Leo, Sagittarius")
    func testDecansSign() {
        // 1st decan of Aries (0–9.999°): Aries (0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .decansSign) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 5.0, method: .decansSign) == 0)
        // 2nd decan (10–19.999°): Leo (4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 10.0, method: .decansSign) == 4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 15.0, method: .decansSign) == 4)
        // 3rd decan (20–29.999°): Sagittarius (8)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 20.0, method: .decansSign) == 8)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 25.0, method: .decansSign) == 8)
    }

    @Test("DecansSign: Libra (6) at 180°")
    func testDecansSignMidZodiac() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .decansSign) == 6)
    }

    // MARK: - DodecatsOriginal

    @Test("DodecatsOriginal: Aries sub-portions 1, 2, 3")
    func testDodecatsOriginal() {
        // 0–2.499°: Aries (0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .dodecatsOriginal) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 1.0, method: .dodecatsOriginal) == 0)
        // 2.5–4.999°: Taurus (1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 2.5, method: .dodecatsOriginal) == 1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 4.0, method: .dodecatsOriginal) == 1)
        // 5.0–7.499°: Gemini (2)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 5.0, method: .dodecatsOriginal) == 2)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 7.0, method: .dodecatsOriginal) == 2)
    }

    @Test("DodecatsOriginal: Libra (6) at 180°")
    func testDodecatsOriginalMidZodiac() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .dodecatsOriginal) == 6)
    }

    // MARK: - DodecatsPaulus

    @Test("DodecatsPaulus: 0°→Aries, 30°→Taurus, 45°→Libra")
    func testDodecatsPaulus() {
        // 0° × 13 = 0 → Aries (0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .dodecatsPaulus) == 0)
        // 30° × 13 = 390 → 390 - 360 = 30 → Taurus (1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 30.0, method: .dodecatsPaulus) == 1)
        // 45° × 13 = 585 → 585 - 360 = 225 → Libra (7)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 45.0, method: .dodecatsPaulus) == 7)
    }

    @Test("DodecatsPaulus: Libra (6) at 180°")
    func testDodecatsPaulusMidZodiac() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .dodecatsPaulus) == 6)
    }

    // MARK: - BoundsEgyptian

    @Test("BoundsEgyptian: Aries bounds Jupiter, Venus, Mercury, Mars, Saturn")
    func testBoundsEgyptian() {
        // 0–5.999°: Jupiter (5)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .boundsEgyptian) == 5)
        // 6–11.999°: Venus (3)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 6.0, method: .boundsEgyptian) == 3)
        // 12–19.999°: Mercury (2)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 12.0, method: .boundsEgyptian) == 2)
        // 20–24.999°: Mars (4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 20.0, method: .boundsEgyptian) == 4)
        // 25–29.999°: Saturn (6)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 25.0, method: .boundsEgyptian) == 6)
    }

    @Test("BoundsEgyptian: Saturn (6) at 180°")
    func testBoundsEgyptianMidZodiac() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .boundsEgyptian) == 6)
    }

    // MARK: - BoundsPtolemy

    @Test("BoundsPtolemy: Aries bounds Jupiter, Venus, Mercury, Mars, Saturn")
    func testBoundsPtolemy() {
        // 0–5.999°: Jupiter (5)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .boundsPtolemy) == 5)
        // 6–13.999°: Venus (3)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 6.0, method: .boundsPtolemy) == 3)
        // 14–20.999°: Mercury (2)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 14.0, method: .boundsPtolemy) == 2)
        // 21–25.999°: Mars (4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 21.0, method: .boundsPtolemy) == 4)
        // 26–29.999°: Saturn (6)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 26.0, method: .boundsPtolemy) == 6)
    }

    @Test("BoundsPtolemy: Saturn (6) at 180°")
    func testBoundsPtolemyMidZodiac() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 180.0, method: .boundsPtolemy) == 6)
    }

    // MARK: - Invalid longitudes

    @Test("All methods: out-of-bounds longitudes return -1")
    func testInvalidLongitudes() {
        for method in [ZodiacDivisionMethod.signs, .decansPlanet, .decansSign,
                       .dodecatsOriginal, .dodecatsPaulus, .boundsEgyptian, .boundsPtolemy] {
            #expect(ZodiacDivisionsOrchestrator.calculate(longitude: -0.1, method: method) == -1)
            #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 360.0, method: method) == -1)
            #expect(ZodiacDivisionsOrchestrator.calculate(longitude: -1.0, method: method) == -1)
            #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 720.0, method: method) == -1)
        }
    }

    // MARK: - Boundary values

    @Test("Signs: boundary longitudes 0°, 30°, 359.999°")
    func testSignsBoundaryValues() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .signs) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 30.0, method: .signs) == 1)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 359.999, method: .signs) == 11)
    }

    @Test("DecansPlanet: exact boundaries 0°, 10°, 20°")
    func testDecansPlanetBoundaryValues() {
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 0.0, method: .decansPlanet) == 4)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 10.0, method: .decansPlanet) == 0)
        #expect(ZodiacDivisionsOrchestrator.calculate(longitude: 20.0, method: .decansPlanet) == 3)
    }
}
