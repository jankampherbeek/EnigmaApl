// VspCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

// MARK: - Year fraction (Meeus p. 249)

struct VspYearFractionTests {

    // JD for 2022-01-01 00:00 UT
    private let jd2022Jan1: Double = 2_459_580.5

    @Test("yearFraction: start of year returns exact year as Double")
    func testYearFraction_startOfYear() {
        let result = VspCalculator.yearFraction(year: 2022, jd: jd2022Jan1, jdNewYear: jd2022Jan1)
        #expect(result == 2022.0)
    }

    @Test("yearFraction: exactly half a year after Jan 1 returns year + 0.5")
    func testYearFraction_halfYear() {
        let halfYearLater = jd2022Jan1 + 365.25 / 2.0
        let result = VspCalculator.yearFraction(year: 2022, jd: halfYearLater, jdNewYear: jd2022Jan1)
        #expect(abs(result - 2022.5) < 1e-10)
    }

    @Test("yearFraction: quarter year later returns year + 0.25")
    func testYearFraction_quarterYear() {
        let quarterYearLater = jd2022Jan1 + 365.25 / 4.0
        let result = VspCalculator.yearFraction(year: 2022, jd: quarterYearLater, jdNewYear: jd2022Jan1)
        #expect(abs(result - 2022.25) < 1e-10)
    }

    @Test("yearFraction: result is always >= year")
    func testYearFraction_alwaysGEYear() {
        let result = VspCalculator.yearFraction(year: 2022, jd: jd2022Jan1, jdNewYear: jd2022Jan1)
        #expect(result >= 2022.0)
    }
}

// MARK: - Estimated conjunction date (Meeus p. 250–251)

struct VspEstimatedConjunctionDateTests {

    // yearFraction ≈ 2022.0 — the inferior conjunction is Venus–Sun on ~Jan 8–9, 2022
    // JD for that event is ≈ 2 459 588 (18° Capricorn); Meeus formula gives jde0 ≈ 2 459 587.68
    private let yearFrac2022: Double = 2022.0

    @Test("estimated inferior conjunction for yearFrac 2022 lands near Jan 2022")
    func testEstimatedInferior_2022_nearJan() {
        let result = VspCalculator.estimatedConjunctionDate(yearFrac: yearFrac2022,
                                                             type: .inferiorConjunction)
        // Allow ±5 days around jde0 ≈ 2 459 587.68
        #expect(result > 2_459_582.0)
        #expect(result < 2_459_593.0)
    }

    @Test("estimated superior conjunction for yearFrac 2022 lands near Mar 2021")
    func testEstimatedSuperior_2022_nearMar2021() {
        let result = VspCalculator.estimatedConjunctionDate(yearFrac: yearFrac2022,
                                                             type: .superiorConjunction)
        // Allow ±10 days around jde0 ≈ 2 459 295.72 (Mar 26, 2021)
        #expect(result > 2_459_282.0)
        #expect(result < 2_459_308.0)
    }

    @Test("inferior and superior conjunctions for same yearFrac produce different dates")
    func testInferiorVsSuperior_produceDifferentDates() {
        let inferior = VspCalculator.estimatedConjunctionDate(yearFrac: yearFrac2022,
                                                               type: .inferiorConjunction)
        let superior = VspCalculator.estimatedConjunctionDate(yearFrac: yearFrac2022,
                                                               type: .superiorConjunction)
        #expect(abs(inferior - superior) > 10.0)
    }

    @Test("estimated conjunction JD is always positive")
    func testEstimatedConjunction_resultIsPositiveJD() {
        let result = VspCalculator.estimatedConjunctionDate(yearFrac: yearFrac2022,
                                                             type: .inferiorConjunction)
        #expect(result > 0.0)
    }

    @Test("historical date (1968) produces a valid estimated JD")
    func testEstimatedConjunction_historicalDate() {
        let result = VspCalculator.estimatedConjunctionDate(yearFrac: 1968.0,
                                                             type: .inferiorConjunction)
        // yearFrac 1968.0 → k = -21 → jde0 ≈ 2 439 734 (late 1967 inferior conjunction)
        #expect(result > 2_438_000.0)
        #expect(result < 2_441_000.0)
    }

    @Test("future date (2050) produces a valid estimated JD")
    func testEstimatedConjunction_futureDate() {
        let result = VspCalculator.estimatedConjunctionDate(yearFrac: 2050.0,
                                                             type: .inferiorConjunction)
        #expect(result > 2_470_000.0)
        #expect(result < 2_490_000.0)
    }
}
