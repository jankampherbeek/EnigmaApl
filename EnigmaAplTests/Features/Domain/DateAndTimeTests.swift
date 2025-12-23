//
//  DateAndTimeTests.swift
//  EnigmaAplTests
//
//  Created on 20/12/2025.
//

import Testing
@testable import EnigmaApl

struct DateAndTimeTests {
    
    // MARK: - AstronomicalDate Tests
    
    @Test("AstronomicalDate: initialization with all parameters")
    func testAstronomicalDateFullInitialization() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: true)
        #expect(date.Year == 2025)
        #expect(date.Month == 1)
        #expect(date.Day == 15)
        #expect(date.Gregorian == true)
    }
    
    @Test("AstronomicalDate: default Gregorian calendar")
    func testAstronomicalDateDefaultGregorian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15)
        #expect(date.Gregorian == true)
    }
    
    @Test("AstronomicalDate: Julian calendar")
    func testAstronomicalDateJulian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: false)
        #expect(date.Gregorian == false)
    }
    
    @Test("AstronomicalDate: year zero (astronomical calendar)")
    func testAstronomicalDateYearZero() {
        let date = AstronomicalDate(Year: 0, Month: 1, Day: 1, Gregorian: true)
        #expect(date.Year == 0)
        #expect(date.Month == 1)
        #expect(date.Day == 1)
    }
    
    @Test("AstronomicalDate: negative year (BCE in astronomical calendar)")
    func testAstronomicalDateNegativeYear() {
        let date = AstronomicalDate(Year: -1, Month: 1, Day: 1, Gregorian: true)
        #expect(date.Year == -1)
        #expect(date.Month == 1)
        #expect(date.Day == 1)
    }
    
    @Test("AstronomicalDate: leap year date")
    func testAstronomicalDateLeapYear() {
        let date = AstronomicalDate(Year: 2024, Month: 2, Day: 29, Gregorian: true)
        #expect(date.Year == 2024)
        #expect(date.Month == 2)
        #expect(date.Day == 29)
    }
    
    @Test("AstronomicalDate: first day of year")
    func testAstronomicalDateFirstDayOfYear() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 1, Gregorian: true)
        #expect(date.Year == 2025)
        #expect(date.Month == 1)
        #expect(date.Day == 1)
    }
    
    @Test("AstronomicalDate: last day of year")
    func testAstronomicalDateLastDayOfYear() {
        let date = AstronomicalDate(Year: 2025, Month: 12, Day: 31, Gregorian: true)
        #expect(date.Year == 2025)
        #expect(date.Month == 12)
        #expect(date.Day == 31)
    }
    
    // MARK: - AstronomicalTime Tests
    
    @Test("AstronomicalTime: initialization with all parameters")
    func testAstronomicalTimeFullInitialization() {
        let time = AstronomicalTime(Hour: 12, Minute: 30, Second: 45)
        #expect(time.Hour == 12)
        #expect(time.Minute == 30)
        #expect(time.Second == 45)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - exact hour")
    func testAstronomicalTimeExactHour() {
        let time = AstronomicalTime(Hour: 5, Minute: 0, Second: 0)
        #expect(time.HourDecimal == 5.0)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - hour with minutes")
    func testAstronomicalTimeHourWithMinutes() {
        let time = AstronomicalTime(Hour: 2, Minute: 30, Second: 0)
        // 2 + 30/60 = 2.5
        #expect(time.HourDecimal == 2.5)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - hour with seconds")
    func testAstronomicalTimeHourWithSeconds() {
        let time = AstronomicalTime(Hour: 1, Minute: 0, Second: 30)
        // 1 + 0/60 + 30/3600 = 1 + 0.008333... = 1.008333...
        #expect(time.HourDecimal == 1.0 + 30.0 / 3600.0)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - full time components")
    func testAstronomicalTimeFullComponents() {
        let time = AstronomicalTime(Hour: 1, Minute: 30, Second: 45)
        // 1 + 30/60 + 45/3600 = 1 + 0.5 + 0.0125 = 1.5125
        #expect(time.HourDecimal == 1.5125)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - midnight")
    func testAstronomicalTimeMidnight() {
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        #expect(time.HourDecimal == 0.0)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - end of day")
    func testAstronomicalTimeEndOfDay() {
        let time = AstronomicalTime(Hour: 23, Minute: 59, Second: 59)
        // 23 + 59/60 + 59/3600 = 23 + 0.983333... + 0.016388... = 23.999722...
        let expected = 23.0 + 59.0 / 60.0 + 59.0 / 3600.0
        #expect(abs(time.HourDecimal - expected) < 0.000001)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - noon")
    func testAstronomicalTimeNoon() {
        let time = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        #expect(time.HourDecimal == 12.0)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - minutes only")
    func testAstronomicalTimeMinutesOnly() {
        let time = AstronomicalTime(Hour: 0, Minute: 15, Second: 0)
        // 0 + 15/60 = 0.25
        #expect(time.HourDecimal == 0.25)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - seconds only")
    func testAstronomicalTimeSecondsOnly() {
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 15)
        // 0 + 0/60 + 15/3600 = 0.0041666...
        let expected = 15.0 / 3600.0
        #expect(abs(time.HourDecimal - expected) < 0.000001)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - precise fractional hour")
    func testAstronomicalTimePreciseFractional() {
        let time = AstronomicalTime(Hour: 10, Minute: 30, Second: 30)
        // 10 + 30/60 + 30/3600 = 10 + 0.5 + 0.008333... = 10.508333...
        let expected = 10.0 + 30.0 / 60.0 + 30.0 / 3600.0
        #expect(abs(time.HourDecimal - expected) < 0.000001)
    }
    
    @Test("AstronomicalTime: HourDecimal calculation - large hour value")
    func testAstronomicalTimeLargeHour() {
        let time = AstronomicalTime(Hour: 23, Minute: 0, Second: 0)
        #expect(time.HourDecimal == 23.0)
    }
    
    // MARK: - AstronomicalTime Decimal Hour Initializer Tests
    
    @Test("AstronomicalTime: initialization from decimal hour - exact hour")
    func testAstronomicalTimeFromDecimalExactHour() {
        let time = AstronomicalTime(HourDecimal: 5.0)
        #expect(time.HourDecimal == 5.0)
        #expect(time.Hour == 5)
        #expect(time.Minute == 0)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - midnight")
    func testAstronomicalTimeFromDecimalMidnight() {
        let time = AstronomicalTime(HourDecimal: 0.0)
        #expect(time.HourDecimal == 0.0)
        #expect(time.Hour == 0)
        #expect(time.Minute == 0)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - noon")
    func testAstronomicalTimeFromDecimalNoon() {
        let time = AstronomicalTime(HourDecimal: 12.0)
        #expect(time.HourDecimal == 12.0)
        #expect(time.Hour == 12)
        #expect(time.Minute == 0)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - half hour")
    func testAstronomicalTimeFromDecimalHalfHour() {
        let time = AstronomicalTime(HourDecimal: 2.5)
        #expect(time.HourDecimal == 2.5)
        #expect(time.Hour == 2)
        #expect(time.Minute == 30)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - quarter hour")
    func testAstronomicalTimeFromDecimalQuarterHour() {
        let time = AstronomicalTime(HourDecimal: 1.25)
        #expect(time.HourDecimal == 1.25)
        #expect(time.Hour == 1)
        #expect(time.Minute == 15)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - with seconds")
    func testAstronomicalTimeFromDecimalWithSeconds() {
        let time = AstronomicalTime(HourDecimal: 1.5125)
        // 1.5125 = 1 hour, 30 minutes, 45 seconds
        #expect(time.HourDecimal == 1.5125)
        #expect(time.Hour == 1)
        #expect(time.Minute == 30)
        #expect(time.Second == 45)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - precise fractional")
    func testAstronomicalTimeFromDecimalPreciseFractional() {
        let time = AstronomicalTime(HourDecimal: 10.508333333333333)
        // 10.508333... = 10 hours, 30 minutes, 30 seconds
        #expect(time.Hour == 10)
        #expect(time.Minute == 30)
        #expect(time.Second == 30)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - small fractional")
    func testAstronomicalTimeFromDecimalSmallFractional() {
        let time = AstronomicalTime(HourDecimal: 0.004166666666666667)
        // 0.004166... = 15 seconds
        #expect(time.Hour == 0)
        #expect(time.Minute == 0)
        #expect(time.Second == 15)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - end of day")
    func testAstronomicalTimeFromDecimalEndOfDay() {
        let time = AstronomicalTime(HourDecimal: 23.999722222222222)
        // 23.999722... = 23 hours, 59 minutes, 59 seconds
        #expect(time.Hour == 23)
        #expect(time.Minute == 59)
        #expect(time.Second == 59)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - round trip conversion")
    func testAstronomicalTimeFromDecimalRoundTrip() {
        // Create from components, then recreate from decimal
        let original = AstronomicalTime(Hour: 12, Minute: 30, Second: 45)
        let reconstructed = AstronomicalTime(HourDecimal: original.HourDecimal)
        // All components should match exactly
        #expect(reconstructed.HourDecimal == original.HourDecimal)
        #expect(reconstructed.Hour == original.Hour)
        #expect(reconstructed.Minute == original.Minute)
        #expect(reconstructed.Second == original.Second)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - reverse round trip")
    func testAstronomicalTimeFromDecimalReverseRoundTrip() {
        // Create from decimal, then recreate from components
        let original = AstronomicalTime(HourDecimal: 8.25361111111)
        // 8.253472... = 8 hours, 15 minutes, 13 seconds
        #expect(original.Hour == 8)
        #expect(original.Minute == 15)
        #expect(original.Second == 13)
        let reconstructed = AstronomicalTime(Hour: original.Hour, Minute: original.Minute, Second: original.Second)
        // The reconstructed decimal should match the original (within floating point precision)
        #expect(abs(reconstructed.HourDecimal - original.HourDecimal) < 0.0001)
        #expect(reconstructed.Hour == original.Hour)
        #expect(reconstructed.Minute == original.Minute)
        #expect(reconstructed.Second == original.Second)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - minutes only")
    func testAstronomicalTimeFromDecimalMinutesOnly() {
        let time = AstronomicalTime(HourDecimal: 0.25)
        // 0.25 = 15 minutes
        #expect(time.Hour == 0)
        #expect(time.Minute == 15)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - seconds only")
    func testAstronomicalTimeFromDecimalSecondsOnly() {
        let time = AstronomicalTime(HourDecimal: 0.004166666666666667)
        // 0.004166... = 15 seconds
        #expect(time.Hour == 0)
        #expect(time.Minute == 0)
        #expect(time.Second == 15)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - large hour")
    func testAstronomicalTimeFromDecimalLargeHour() {
        let time = AstronomicalTime(HourDecimal: 23.0)
        #expect(time.HourDecimal == 23.0)
        #expect(time.Hour == 23)
        #expect(time.Minute == 0)
        #expect(time.Second == 0)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - complex time")
    func testAstronomicalTimeFromDecimalComplexTime() {
        let time = AstronomicalTime(HourDecimal: 14.375)
        // 14.375 = 14 hours, 22 minutes, 30 seconds
        #expect(time.Hour == 14)
        #expect(time.Minute == 22)
        #expect(time.Second == 30)
    }
    
    @Test("AstronomicalTime: initialization from decimal hour - precision test")
    func testAstronomicalTimeFromDecimalPrecision() {
        // Test with a value that has many decimal places
        let time = AstronomicalTime(HourDecimal: 6.123456789)
        // 6.123456789 = 6 hours, 7 minutes, 24.444... seconds (truncated to 24)
        #expect(time.Hour == 6)
        #expect(time.Minute == 7)
        #expect(time.Second == 24)
    }
}

