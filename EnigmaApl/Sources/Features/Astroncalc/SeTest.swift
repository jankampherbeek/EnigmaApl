//
//  SeTest.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//


import Foundation

struct SeTest {
    
    static func PerformTest() {
        
        
        print("POC for accessing the Swiss Ephemeris")
        
        
        // Create Swiss Ephemeris instance
        let swissEph = SwissEph()
        
        // Print version information
        print("Swiss Ephemeris version: \(swissEph.version())")
        
        // Example 1: Calculate Julian Day for a specific date
        let jd = swissEph.julianDay(year: 2025, month: 1, day: 15, hour: 12.0)
        print("Julian Day for 2025-01-15 12:00:00: \(jd)")
        
        // Example 2: Convert Julian Day back to date
        let date = swissEph.dateFromJulianDay(jd)
        print("Date from Julian Day: \(date.year)-\(date.month)-\(date.day) \(date.hour):00")
        
        // Example 3: Calculate planet positions
        print("\nPlanet positions for 2025-01-15 12:00:00:")
        let planets: [Planet] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .chiron]
        
        for planet in planets {
            if let position = swissEph.calculatePlanetPosition(julianDay: jd, planet: planet) {
                let planetName = swissEph.planetName(planet)
                print("\(planetName): Longitude \(String(format: "%.2f", position.longitude))°, Latitude \(String(format: "%.2f", position.latitude))°, Distance \(String(format: "%.2f", position.distance)) AU")
            }
        }
        
        // Example 4: Calculate houses for Amsterdam (52.3676° N, 4.9041° E)
        print("\nHouses for Amsterdam (52.3676° N, 4.9041° E):")
        if let houses = swissEph.calculateHouses(
            julianDay: jd,
            latitude: 52.3676,
            longitude: 4.9041,
            houseSystem: .placidus
        ) {
            print("Ascendant: \(String(format: "%.2f", houses.ascendant))°")
            print("Midheaven: \(String(format: "%.2f", houses.midheaven))°")
            print("House cusps:")
            for (index, cusp) in houses.cusps.enumerated() {
                print("  House \(index + 1): \(String(format: "%.2f", cusp))°")
            }
        }
        
        // Example 5: Calculate sidereal time
        let siderealTime = swissEph.siderealTime(julianDay: jd)
        print("\nSidereal Time: \(String(format: "%.4f", siderealTime)) hours")
        
        // Example 6: Calculate Ayanamsa (sidereal zodiac offset)
        let ayanamsa = swissEph.ayanamsa(julianDay: jd)
        print("Ayanamsa (Lahiri): \(String(format: "%.4f", ayanamsa))°")
        
        // Example 7: Calculate heliocentric positions
        print("\nHeliocentric positions:")
        for planet in [Planet.earth, Planet.mars, Planet.jupiter] {
            if let position = swissEph.calculatePlanetPosition(
                julianDay: jd,
                planet: planet,
                flags: [.swissEph, .heliocentric]
            ) {
                let planetName = swissEph.planetName(planet)
                print("\(planetName) (heliocentric): Longitude \(String(format: "%.2f", position.longitude))°, Latitude \(String(format: "%.2f", position.latitude))°")
            }
        }
        
        // Example 8: Performance test - Calculate Sun position (reduced for testing)
        print("PERFORMANCE TEST")
        print("Calculating Sun position 1,000,000 times...")
        let startJD = 2000000.0
        let numberOfCalculations = 1_000_000  // Reduced from 1,000,000
        let startTime = CFAbsoluteTimeGetCurrent()
        
        print("Starting calculations...")
        for i in 0..<numberOfCalculations {
            let currentJD = startJD + Double(i)
            if let _ = swissEph.calculatePlanetPosition(julianDay: currentJD, planet: .sun) {
                // Success - continue
            } else {
                print("ERROR: Failed to calculate position at iteration \(i)")
                break
            }
            
            //    // Progress indicator every 10,000 calculations
            //    if (i + 1) % 10_000 == 0 {
            //        print("Completed \(i + 1) calculations...")
            //    }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        let calculationsPerSecond = Double(numberOfCalculations) / totalTime
        
        print("Performance Test Results:")
        print("Total time: \(String(format: "%.3f", totalTime)) seconds")
        print("Calculations per second: \(String(format: "%.0f", calculationsPerSecond))")
        print("Average time per calculation: \(String(format: "%.6f", totalTime / Double(numberOfCalculations))) seconds")
        print(String(repeating: "=", count: 60))
        
        print("\nSwiss Ephemeris bridge demonstration completed!")
        
    }
}
