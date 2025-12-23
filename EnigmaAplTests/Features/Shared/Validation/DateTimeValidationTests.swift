//
//  DateTimeValidationTests.swift
//  EnigmaAplTests
//
//  Created on 20/12/2025.
//

import Testing
@testable import EnigmaApl

struct DateTimeValidationTests {
    
    // MARK: - validateDate Tests
    
    @Test("validateDate: valid Gregorian date")
    func testValidateDateValidGregorian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: valid Julian date")
    func testValidateDateValidJulian() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 15, Gregorian: false)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: valid leap year date (February 29)")
    func testValidateDateLeapYear() {
        let date = AstronomicalDate(Year: 2024, Month: 2, Day: 29, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: invalid date - February 30")
    func testValidateDateInvalidFebruary30() {
        let date = AstronomicalDate(Year: 2024, Month: 2, Day: 30, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: invalid date - April 31")
    func testValidateDateInvalidApril31() {
        let date = AstronomicalDate(Year: 2025, Month: 4, Day: 31, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: invalid date - month 13")
    func testValidateDateInvalidMonth13() {
        let date = AstronomicalDate(Year: 2025, Month: 13, Day: 1, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: invalid date - month 0")
    func testValidateDateInvalidMonth0() {
        let date = AstronomicalDate(Year: 2025, Month: 0, Day: 1, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: invalid date - day 0")
    func testValidateDateInvalidDay0() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 0, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: invalid date - day 32")
    func testValidateDateInvalidDay32() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 32, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: valid date - first day of year")
    func testValidateDateFirstDayOfYear() {
        let date = AstronomicalDate(Year: 2025, Month: 1, Day: 1, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: valid date - last day of year")
    func testValidateDateLastDayOfYear() {
        let date = AstronomicalDate(Year: 2025, Month: 12, Day: 31, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: valid date - non-leap year February 28")
    func testValidateDateNonLeapYearFebruary28() {
        let date = AstronomicalDate(Year: 2025, Month: 2, Day: 28, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: invalid date - non-leap year February 29")
    func testValidateDateNonLeapYearFebruary29() {
        let date = AstronomicalDate(Year: 2025, Month: 2, Day: 29, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == false)
    }
    
    @Test("validateDate: valid date - year zero (astronomical calendar)")
    func testValidateDateYearZero() {
        let date = AstronomicalDate(Year: 0, Month: 1, Day: 1, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    @Test("validateDate: valid date - negative year (BCE)")
    func testValidateDateNegativeYear() {
        let date = AstronomicalDate(Year: -1, Month: 1, Day: 1, Gregorian: true)
        #expect(AstronomicalDateValidation.validateDate(date) == true)
    }
    
    // MARK: - validateTime Tests
    
    @Test("validateTime: valid time - midnight")
    func testValidateTimeMidnight() {
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - noon")
    func testValidateTimeNoon() {
        let time = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - end of day")
    func testValidateTimeEndOfDay() {
        let time = AstronomicalTime(Hour: 23, Minute: 59, Second: 59)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - arbitrary valid time")
    func testValidateTimeArbitraryValid() {
        let time = AstronomicalTime(Hour: 14, Minute: 30, Second: 45)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: invalid time - hour 24")
    func testValidateTimeInvalidHour24() {
        let time = AstronomicalTime(Hour: 24, Minute: 0, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: invalid time - hour negative")
    func testValidateTimeInvalidHourNegative() {
        let time = AstronomicalTime(Hour: -1, Minute: 0, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: invalid time - minute 60")
    func testValidateTimeInvalidMinute60() {
        let time = AstronomicalTime(Hour: 12, Minute: 60, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: invalid time - minute negative")
    func testValidateTimeInvalidMinuteNegative() {
        let time = AstronomicalTime(Hour: 12, Minute: -1, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: invalid time - second 60")
    func testValidateTimeInvalidSecond60() {
        let time = AstronomicalTime(Hour: 12, Minute: 30, Second: 60)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: invalid time - second negative")
    func testValidateTimeInvalidSecondNegative() {
        let time = AstronomicalTime(Hour: 12, Minute: 30, Second: -1)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: invalid time - multiple invalid components")
    func testValidateTimeMultipleInvalid() {
        let time = AstronomicalTime(Hour: 25, Minute: 70, Second: 100)
        #expect(AstronomicalDateValidation.validateTime(time) == false)
    }
    
    @Test("validateTime: valid time - boundary hour 0")
    func testValidateTimeBoundaryHour0() {
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - boundary hour 23")
    func testValidateTimeBoundaryHour23() {
        let time = AstronomicalTime(Hour: 23, Minute: 59, Second: 59)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - boundary minute 0")
    func testValidateTimeBoundaryMinute0() {
        let time = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - boundary minute 59")
    func testValidateTimeBoundaryMinute59() {
        let time = AstronomicalTime(Hour: 12, Minute: 59, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - boundary second 0")
    func testValidateTimeBoundarySecond0() {
        let time = AstronomicalTime(Hour: 12, Minute: 30, Second: 0)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time - boundary second 59")
    func testValidateTimeBoundarySecond59() {
        let time = AstronomicalTime(Hour: 12, Minute: 30, Second: 59)
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
    
    @Test("validateTime: valid time from decimal hour")
    func testValidateTimeFromDecimalHour() {
        let time = AstronomicalTime(HourDecimal: 14.5125)
        // 14.5125 = 14:30:45
        #expect(AstronomicalDateValidation.validateTime(time) == true)
    }
}

