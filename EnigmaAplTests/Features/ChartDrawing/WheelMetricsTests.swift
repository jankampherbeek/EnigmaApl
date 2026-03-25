// WheelMetricsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import CoreGraphics
@testable import EnigmaApl

struct WheelMetricsTests {

    private let accuracy: Double = 1e-10

    // MARK: - radius()

    @Test("radius: fractie 0.5 van 200 geeft 100")
    func testRadiusHalf() {
        let result = WheelMetrics.radius(0.5, outerRadius: 200)
        #expect(abs(result - 100.0) < accuracy)
    }

    @Test("radius: fractie 1.0 geeft de volledige outerRadius terug")
    func testRadiusFull() {
        let result = WheelMetrics.radius(1.0, outerRadius: 350)
        #expect(abs(result - 350.0) < accuracy)
    }

    @Test("radius: fractie 0.0 geeft altijd 0")
    func testRadiusZeroFraction() {
        let result = WheelMetrics.radius(0.0, outerRadius: 350)
        #expect(result == 0.0)
    }

    @Test("radius: outerRadius 0 geeft altijd 0")
    func testRadiusZeroOuter() {
        let result = WheelMetrics.radius(0.98, outerRadius: 0)
        #expect(result == 0.0)
    }

    @Test("radius: outerCircle-fractie op 350px geeft verwachte waarde")
    func testRadiusOuterCircle() {
        // outerCircle = 0.98, bij 350px → 343
        let result = WheelMetrics.radius(WheelMetrics.outerCircle, outerRadius: 350)
        #expect(abs(result - 343.0) < accuracy)
    }

    // MARK: - fontSize()

    @Test("fontSize: signGlyphFontFraction op 350px geeft ~28pt")
    func testFontSizeSignGlyph() {
        // 0.080 * 350 = 28.0
        let result = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: 350)
        #expect(abs(Double(result) - 28.0) < accuracy)
    }

    @Test("fontSize: fractie 0 geeft 0")
    func testFontSizeZero() {
        let result = WheelMetrics.fontSize(0.0, outerRadius: 350)
        #expect(result == 0.0)
    }

    @Test("fontSize: fractie 0.5 van 200 geeft 100")
    func testFontSizeHalf() {
        let result = WheelMetrics.fontSize(0.5, outerRadius: 200)
        #expect(abs(Double(result) - 100.0) < accuracy)
    }

    // MARK: - strokeWidth()

    @Test("strokeWidth: strokeFraction op 350px geeft ~2px")
    func testStrokeWidthStrokeFraction() {
        // 0.0057 * 350 = 1.995
        let result = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: 350)
        #expect(abs(Double(result) - 1.995) < accuracy)
    }

    @Test("strokeWidth: fractie 0 geeft 0")
    func testStrokeWidthZero() {
        let result = WheelMetrics.strokeWidth(0.0, outerRadius: 350)
        #expect(result == 0.0)
    }

    @Test("strokeWidth: fractie 1.0 geeft de volledige outerRadius als breedte")
    func testStrokeWidthFull() {
        let result = WheelMetrics.strokeWidth(1.0, outerRadius: 100)
        #expect(abs(Double(result) - 100.0) < accuracy)
    }
}
