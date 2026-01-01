//
//  SEWrapperTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Testing
import Foundation

@testable import EnigmaApl

struct SEWrapperTests {
    
    @Test("julianDay: convert date and time to Julian Day")
    func testJulianDay() async throws {
        // Test data
        let year = 2025
        let month = 12
        let day = 24
        let hourDecimal = 16.0
        let expectedJulianDay = 2461034.1666666665
        
        // Create AstronomicalDate
        let date = AstronomicalDate(Year: year, Month: month, Day: day, Gregorian: true)
        
        // Create AstronomicalTime from decimal hour
        let time = AstronomicalTime(HourDecimal: hourDecimal)
        
        // Create SEWrapper instance
        let seWrapper = SEWrapper()
        
        // Calculate Julian Day
        let result = seWrapper.julianDay(date: date, time: time)
        
        // Verify the result matches expected value (with tolerance for floating point precision)
        let difference = abs(result - expectedJulianDay)
        #expect(difference < 1e-10, 
               "Expected Julian Day \(expectedJulianDay), got \(result), difference: \(difference)")
    }
    
    
    @Test("dateFromJulianDay: convert Julian Day to AstronomicalDateTime")
    func testDateFromJulianDay() async throws {
        // Test data
        let julianDay = 2461034.1666666665
        let expectedYear = 2025
        let expectedMonth = 12
        let expectedDay = 24
        let expectedHourDecimal = 16.0
        
        // Create SEWrapper instance
        let seWrapper = SEWrapper()
        
        // Convert Julian Day to AstronomicalDateTime
        let result = seWrapper.dateFromJulianDay(julianDay, gregorian: true)
        
        // Verify the result matches expected values
        #expect(result.Date.Year == expectedYear,
               "Expected year \(expectedYear), got \(result.Date.Year)")
        #expect(result.Date.Month == expectedMonth,
               "Expected month \(expectedMonth), got \(result.Date.Month)")
        #expect(result.Date.Day == expectedDay,
               "Expected day \(expectedDay), got \(result.Date.Day)")
        
        // Verify time with tolerance for floating point precision
        let timeDifference = abs(result.Time.HourDecimal - expectedHourDecimal)
        #expect(timeDifference < 1e-8,
               "Expected hour decimal \(expectedHourDecimal), got \(result.Time.HourDecimal), difference: \(timeDifference)")
        
        // Verify it's Gregorian calendar
        #expect(result.Date.Gregorian == true,
               "Expected Gregorian calendar, got \(result.Date.Gregorian)")
    }
}

