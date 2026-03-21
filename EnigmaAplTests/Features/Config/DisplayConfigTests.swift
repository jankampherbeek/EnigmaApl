//
//  DisplayConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct DisplayConfigTests {

    // MARK: - Initialization

    @Test("DisplayConfig: default initialization")
    func testDefaultInitialization() {
        let config = DisplayConfig()
        #expect(config.drawingType == .signBased)
        #expect(config.factorColors.isEmpty)
        #expect(config.signColors.isEmpty)
    }

    @Test("DisplayConfig: initialization with all parameters")
    func testInitializationWithAllParameters() {
        let factorColors = [FactorColorOverride(factor: .moon, color: ColorConfig(red: 1.0, green: 0.9, blue: 0.0))]
        let signColors = [SignColorOverride(sign: .Taurus, color: ColorConfig(red: 0.0, green: 0.8, blue: 0.2))]
        let config = DisplayConfig(drawingType: .houseBased, factorColors: factorColors, signColors: signColors)
        #expect(config.drawingType == .houseBased)
        #expect(config.factorColors.count == 1)
        #expect(config.signColors.count == 1)
    }

    // MARK: - DrawingType

    @Test("DisplayConfig: all drawing types are accepted")
    func testAllDrawingTypes() {
        for drawingType in DrawingType.allCases {
            let config = DisplayConfig(drawingType: drawingType)
            #expect(config.drawingType == drawingType)
        }
    }

    @Test("DrawingType: raw values are correct")
    func testDrawingTypeRawValues() {
        #expect(DrawingType.signBased.rawValue == 0)
        #expect(DrawingType.houseBased.rawValue == 1)
        #expect(DrawingType.french.rawValue == 2)
    }

    // MARK: - Color overrides

    @Test("FactorColorOverride: stores factor and color correctly")
    func testFactorColorOverride() {
        let color = ColorConfig(red: 1.0, green: 0.5, blue: 0.0)
        let override = FactorColorOverride(factor: .venus, color: color)
        #expect(override.factor == .venus)
        #expect(override.color == color)
    }

    @Test("SignColorOverride: stores sign and color correctly")
    func testSignColorOverride() {
        let color = ColorConfig(red: 0.2, green: 0.4, blue: 0.8)
        let override = SignColorOverride(sign: .Scorpio, color: color)
        #expect(override.sign == .Scorpio)
        #expect(override.color == color)
    }

    // MARK: - ColorConfig

    @Test("ColorConfig: stores rgba values correctly")
    func testColorConfigValues() {
        let color = ColorConfig(red: 0.1, green: 0.2, blue: 0.3, opacity: 0.8)
        #expect(color.red == 0.1)
        #expect(color.green == 0.2)
        #expect(color.blue == 0.3)
        #expect(color.opacity == 0.8)
    }

    @Test("ColorConfig: default opacity is 1.0")
    func testColorConfigDefaultOpacity() {
        let color = ColorConfig(red: 0.5, green: 0.5, blue: 0.5)
        #expect(color.opacity == 1.0)
    }

    // MARK: - Codable

    @Test("DisplayConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = DisplayConfig(
            drawingType: .french,
            factorColors: [FactorColorOverride(factor: .moon, color: ColorConfig(red: 1.0, green: 1.0, blue: 0.0))],
            signColors: [SignColorOverride(sign: .Gemini, color: ColorConfig(red: 0.0, green: 0.5, blue: 1.0))]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DisplayConfig.self, from: data)
        #expect(decoded.drawingType == original.drawingType)
        #expect(decoded.factorColors == original.factorColors)
        #expect(decoded.signColors == original.signColors)
    }

    @Test("ColorConfig: encodes and decodes correctly")
    func testColorConfigCodableRoundtrip() throws {
        let original = ColorConfig(red: 0.3, green: 0.6, blue: 0.9, opacity: 0.75)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ColorConfig.self, from: data)
        #expect(decoded.red == original.red)
        #expect(decoded.green == original.green)
        #expect(decoded.blue == original.blue)
        #expect(decoded.opacity == original.opacity)
    }
}
