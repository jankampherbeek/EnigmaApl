//
//  DateTimeConversionTests.swift
//  EnigmaAplTests
//
//  Created on 21/12/2025.
//

import Testing
@testable import EnigmaApl

struct DateTimeConversionTests {
    
    // MARK: - DateToText Tests
    
    @Test("DateToText: Gregorian date with single digit month and day")
    func testDateToTextGregorianSingleDigits() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 5, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/01/05 G")
    }
    
    @Test("DateToText: Gregorian date with double digit month and day")
    func testDateToTextGregorianDoubleDigits() {
        let date = AstronomicalDate(Year: 2025, Month: 12, Day: 31, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/12/31 G")
    }
    
    @Test("DateToText: Julian date")
    func testDateToTextJulian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: false)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/01/15 J")
    }
    
    @Test("DateToText: Gregorian date - first day of year")
    func testDateToTextFirstDayOfYear() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 1, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/01/01 G")
    }
    
    @Test("DateToText: Gregorian date - last day of year")
    func testDateToTextLastDayOfYear() {
        let date = AstronomicalDate(Year: 2025, Month: 12, Day: 31, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/12/31 G")
    }
    
    @Test("DateToText: Gregorian date - leap year February 29")
    func testDateToTextLeapYear() {
        let date = AstronomicalDate(Year: 2024, Month: 2, Day: 29, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2024/02/29 G")
    }
    
    @Test("DateToText: Gregorian date - month 10, day 10")
    func testDateToTextMonth10Day10() {
        let date = AstronomicalDate(Year: 2025, Month: 10, Day: 10, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/10/10 G")
    }
    
    @Test("DateToText: Julian date - single digit month and day")
    func testDateToTextJulianSingleDigits() {
        let date = AstronomicalDate(Year: 2025, Month: 3, Day: 7, Gregorian: false)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "2025/03/07 J")
    }
    
    @Test("DateToText: Year zero (astronomical calendar)")
    func testDateToTextYearZero() {
        let date = AstronomicalDate(Year: 0, Month: 1, Day: 1, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "0/01/01 G")
    }
    
    @Test("DateToText: Negative year (BCE)")
    func testDateToTextNegativeYear() {
        let date = AstronomicalDate(Year: -1, Month: 1, Day: 1, Gregorian: true)
        let result = DateTimeConversion.DateToText(date)
        #expect(result == "-1/01/01 G")
    }
    
    // MARK: - TimeToText Tests
    
    @Test("TimeToText: time with single digit minutes and seconds")
    func testTimeToTextSingleDigits() {
        let time = AstronomicalTime(Hour: 14, Minute: 5, Second: 3)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "14:05:03")
    }
    
    @Test("TimeToText: time with double digit minutes and seconds")
    func testTimeToTextDoubleDigits() {
        let time = AstronomicalTime(Hour: 14, Minute: 30, Second: 45)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "14:30:45")
    }
    
    @Test("TimeToText: midnight")
    func testTimeToTextMidnight() {
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "00:00:00")
    }
    
    @Test("TimeToText: noon")
    func testTimeToTextNoon() {
        let time = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "12:00:00")
    }
    
    @Test("TimeToText: end of day")
    func testTimeToTextEndOfDay() {
        let time = AstronomicalTime(Hour: 23, Minute: 59, Second: 59)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "23:59:59")
    }
    
    @Test("TimeToText: single digit hour")
    func testTimeToTextSingleDigitHour() {
        let time = AstronomicalTime(Hour: 5, Minute: 30, Second: 15)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "05:30:15")
    }
    
    @Test("TimeToText: hour 10, minute 10, second 10")
    func testTimeToTextAllTens() {
        let time = AstronomicalTime(Hour: 10, Minute: 10, Second: 10)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "10:10:10")
    }
    
    @Test("TimeToText: time with zero minutes and seconds")
    func testTimeToTextZeroMinutesSeconds() {
        let time = AstronomicalTime(Hour: 8, Minute: 0, Second: 0)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "08:00:00")
    }
    
    @Test("TimeToText: time with zero seconds")
    func testTimeToTextZeroSeconds() {
        let time = AstronomicalTime(Hour: 15, Minute: 45, Second: 0)
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "15:45:00")
    }
    
    @Test("TimeToText: time from decimal hour")
    func testTimeToTextFromDecimalHour() {
        let time = AstronomicalTime(HourDecimal: 14.5125)
        // 14.5125 = 14:30:45
        let result = DateTimeConversion.TimeToText(time)
        #expect(result == "14:30:45")
    }
    
    // MARK: - DateTimeToText Tests
    
    @Test("DateTimeToText: Gregorian date and time")
    func testDateTimeToTextGregorian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: true)
        let time = AstronomicalTime(Hour: 14, Minute: 30, Second: 45)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2025/01/15 G 14:30:45")
    }
    
    @Test("DateTimeToText: Julian date and time")
    func testDateTimeToTextJulian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: false)
        let time = AstronomicalTime(Hour: 14, Minute: 30, Second: 45)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2025/01/15 J 14:30:45")
    }
    
    @Test("DateTimeToText: date and time with single digits")
    func testDateTimeToTextSingleDigits() {
        let date = AstronomicalDate(Year: 2025, Month: 3, Day: 5, Gregorian: true)
        let time = AstronomicalTime(Hour: 5, Minute: 3, Second: 7)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2025/03/05 G 05:03:07")
    }
    
    @Test("DateTimeToText: midnight on first day of year")
    func testDateTimeToTextMidnightFirstDay() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 1, Gregorian: true)
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2025/01/01 G 00:00:00")
    }
    
    @Test("DateTimeToText: end of day on last day of year")
    func testDateTimeToTextEndOfDayLastDay() {
        let date = AstronomicalDate(Year: 2025, Month: 12, Day: 31, Gregorian: true)
        let time = AstronomicalTime(Hour: 23, Minute: 59, Second: 59)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2025/12/31 G 23:59:59")
    }
    
    @Test("DateTimeToText: noon on leap year date")
    func testDateTimeToTextNoonLeapYear() {
        let date = AstronomicalDate(Year: 2024, Month: 2, Day: 29, Gregorian: true)
        let time = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2024/02/29 G 12:00:00")
    }
    
    @Test("DateTimeToText: Julian calendar with time from decimal hour")
    func testDateTimeToTextJulianWithDecimalTime() {
        let date = AstronomicalDate(Year: 2025, Month: 6, Day: 15, Gregorian: false)
        let time = AstronomicalTime(HourDecimal: 10.508333333333333)
        // 10.508333... = 10:30:30
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2025/06/15 J 10:30:30")
    }
    
    @Test("DateTimeToText: all components are 10")
    func testDateTimeToTextAllTens() {
        let date = AstronomicalDate(Year: 2010, Month: 10, Day: 10, Gregorian: true)
        let time = AstronomicalTime(Hour: 10, Minute: 10, Second: 10)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        let result = DateTimeConversion.DateTimeToText(dateTime)
        #expect(result == "2010/10/10 G 10:10:10")
    }
}

