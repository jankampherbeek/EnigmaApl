//
//  PositionInDegreesTests.swift
//  EnigmaAplTests
//
//  Created on 18/12/2025.
//

import Testing
@testable import EnigmaApl

struct PositionInDegreesTests {
    
    // MARK: - DoubleToDms Tests
    
    @Test("DoubleToDms: positive value with all components")
    func testDoubleToDmsPositive() {
        let result = PositionInDegreesConversion.DoubleToDms(45.5125)
        #expect(result == "45°30'45\"")
    }
    
    @Test("DoubleToDms: negative value")
    func testDoubleToDmsNegative() {
        let result = PositionInDegreesConversion.DoubleToDms(-45.5125)
        #expect(result == "-45°30'45\"")
    }
    
    @Test("DoubleToDms: zero value")
    func testDoubleToDmsZero() {
        let result = PositionInDegreesConversion.DoubleToDms(0.0)
        #expect(result == "0°00'00\"")
    }
    
    @Test("DoubleToDms: minutes and seconds less than 10 (zero padding)")
    func testDoubleToDmsZeroPadding() {
        let result = PositionInDegreesConversion.DoubleToDms(12.0505)
        // 12.0505 * 3600 = 43381.8 → truncated to 43381 seconds = 12°03'01"
        #expect(result == "12°03'01\"")
    }
    
    @Test("DoubleToDms: exact degrees (no minutes or seconds)")
    func testDoubleToDmsExactDegrees() {
        let result = PositionInDegreesConversion.DoubleToDms(90.0)
        #expect(result == "90°00'00\"")
    }
    
    @Test("DoubleToDms: only minutes, no seconds")
    func testDoubleToDmsOnlyMinutes() {
        let result = PositionInDegreesConversion.DoubleToDms(30.5)
        #expect(result == "30°30'00\"")
    }
    
    @Test("DoubleToDms: large value")
    func testDoubleToDmsLargeValue() {
        let result = PositionInDegreesConversion.DoubleToDms(359.999722)
        // 359.999722 * 3600 = 1295998.9992 → truncated to 1295998 seconds = 359°59'58"
        #expect(result == "359°59'58\"")
    }
    
    // MARK: - DoubleToDmsSign Tests
    
    @Test("DoubleToDmsSign: Aries (0-30)")
    func testDoubleToDmsSignAries() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(15.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Aries)
    }
    
    @Test("DoubleToDmsSign: Taurus (30-60)")
    func testDoubleToDmsSignTaurus() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(45.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Taurus)
    }
    
    @Test("DoubleToDmsSign: Gemini (60-90)")
    func testDoubleToDmsSignGemini() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(75.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Gemini)
    }
    
    @Test("DoubleToDmsSign: Cancer (90-120)")
    func testDoubleToDmsSignCancer() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(105.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Cancer)
    }
    
    @Test("DoubleToDmsSign: Leo (120-150)")
    func testDoubleToDmsSignLeo() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(135.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Leo)
    }
    
    @Test("DoubleToDmsSign: Virgo (150-180)")
    func testDoubleToDmsSignVirgo() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(165.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Virgo)
    }
    
    @Test("DoubleToDmsSign: Libra (180-210)")
    func testDoubleToDmsSignLibra() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(195.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Libra)
    }
    
    @Test("DoubleToDmsSign: Scorpio (210-240)")
    func testDoubleToDmsSignScorpio() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(225.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Scorpio)
    }
    
    @Test("DoubleToDmsSign: Sagittarius (240-270)")
    func testDoubleToDmsSignSagittarius() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(255.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Sagittarius)
    }
    
    @Test("DoubleToDmsSign: Capricorn (270-300)")
    func testDoubleToDmsSignCapricorn() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(285.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Capricorn)
    }
    
    @Test("DoubleToDmsSign: Aquarius (300-330)")
    func testDoubleToDmsSignAquarius() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(315.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Aquarius)
    }
    
    @Test("DoubleToDmsSign: Pisces (330-360)")
    func testDoubleToDmsSignPisces() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(345.51251)
        #expect(success == true)
        #expect(dms == "15°30'45\"")
        #expect(sign == .Pisces)
    }
    
    @Test("DoubleToDmsSign: boundary at 0 (Aries)")
    func testDoubleToDmsSignBoundaryZero() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(0.0)
        #expect(success == true)
        #expect(dms == "0°00'00\"")
        #expect(sign == .Aries)
    }
    
    @Test("DoubleToDmsSign: boundary at 30 (Taurus)")
    func testDoubleToDmsSignBoundaryThirty() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(30.0)
        #expect(success == true)
        #expect(dms == "0°00'00\"")
        #expect(sign == .Taurus)
    }
    
    @Test("DoubleToDmsSign: boundary just before 30 (Aries)")
    func testDoubleToDmsSignJustBeforeThirty() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(29.9999)
        #expect(success == true)
        #expect(sign == .Aries)
    }
    
    @Test("DoubleToDmsSign: boundary at 359.999 (Pisces)")
    func testDoubleToDmsSignBoundary359() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(359.999)
        #expect(success == true)
        // 359.999 % 30 = 29.999, 29.999 * 3600 = 107996.4 → truncated to 107996 seconds = 29°59'56"
        #expect(dms == "29°59'56\"")
        #expect(sign == .Pisces)
    }
    
    @Test("DoubleToDmsSign: error case - value >= 360.0")
    func testDoubleToDmsSignError360() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(360.0)
        #expect(success == false)
        #expect(dms == "")
        #expect(sign == nil)
    }
    
    @Test("DoubleToDmsSign: error case - value > 360.0")
    func testDoubleToDmsSignErrorGreaterThan360() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(450.0)
        #expect(success == false)
        #expect(dms == "")
        #expect(sign == nil)
    }
    
    @Test("DoubleToDmsSign: error case - negative value")
    func testDoubleToDmsSignErrorNegative() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(-15.0)
        #expect(success == false)
        #expect(dms == "")
        #expect(sign == nil)
    }
    
    @Test("DoubleToDmsSign: error case - small negative value")
    func testDoubleToDmsSignErrorSmallNegative() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(-0.1)
        #expect(success == false)
        #expect(dms == "")
        #expect(sign == nil)
    }
    
    @Test("DoubleToDmsSign: error case - large negative value")
    func testDoubleToDmsSignErrorLargeNegative() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(-100.0)
        #expect(success == false)
        #expect(dms == "")
        #expect(sign == nil)
    }
    
    @Test("DoubleToDmsSign: minutes and seconds zero padding")
    func testDoubleToDmsSignZeroPadding() {
        let (dms, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(12.0505)
        #expect(success == true)
        // 12.0505 % 30 = 12.0505, 12.0505 * 3600 = 43381.8 → truncated to 43381 seconds = 12°03'01"
        #expect(dms == "12°03'01\"")
        #expect(sign == .Aries)
    }
    
    // MARK: - DoubleToDegrees Tests
    
    @Test("DoubleToDegrees: positive value with default precision")
    func testDoubleToDegreesPositiveDefault() {
        let result = PositionInDegreesConversion.DoubleToDegrees(45.5125)
        #expect(result == "45.51°")
    }
    
    @Test("DoubleToDegrees: negative value with default precision")
    func testDoubleToDegreesNegativeDefault() {
        let result = PositionInDegreesConversion.DoubleToDegrees(-45.5125)
        #expect(result == "-45.51°")
    }
    
    @Test("DoubleToDegrees: zero value")
    func testDoubleToDegreesZero() {
        let result = PositionInDegreesConversion.DoubleToDegrees(0.0)
        #expect(result == "0.00°")
    }
    
    @Test("DoubleToDegrees: custom precision - 0 decimal places")
    func testDoubleToDegreesZeroDecimals() {
        let result = PositionInDegreesConversion.DoubleToDegrees(45.5125, decimalPlaces: 0)
        #expect(result == "46°")
    }
    
    @Test("DoubleToDegrees: custom precision - 1 decimal place")
    func testDoubleToDegreesOneDecimal() {
        let result = PositionInDegreesConversion.DoubleToDegrees(45.5125, decimalPlaces: 1)
        #expect(result == "45.5°")
    }
    
    @Test("DoubleToDegrees: custom precision - 3 decimal places")
    func testDoubleToDegreesThreeDecimals() {
        let result = PositionInDegreesConversion.DoubleToDegrees(45.5125, decimalPlaces: 3)
        #expect(result == "45.513°")
    }
    
    @Test("DoubleToDegrees: custom precision - 5 decimal places")
    func testDoubleToDegreesFiveDecimals() {
        let result = PositionInDegreesConversion.DoubleToDegrees(45.5125, decimalPlaces: 5)
        #expect(result == "45.51250°")
    }
    
    @Test("DoubleToDegrees: rounding behavior")
    func testDoubleToDegreesRounding() {
        let result = PositionInDegreesConversion.DoubleToDegrees(45.9999, decimalPlaces: 2)
        #expect(result == "46.00°")
    }
    
    @Test("DoubleToDegrees: large value")
    func testDoubleToDegreesLargeValue() {
        let result = PositionInDegreesConversion.DoubleToDegrees(359.999, decimalPlaces: 2)
        #expect(result == "360.00°")
    }
}

