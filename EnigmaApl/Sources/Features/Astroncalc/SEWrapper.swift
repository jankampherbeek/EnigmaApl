//
//  SEWrapper.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//

/// Wrapper for the functions of the Swiss Ephemeris

import Foundation
import SwissEphC

// MARK: - Errors
public enum SEError: Error {
    case initializationFailed(String)
    case calculationFailed(String)
    case houseCalculationFailed(Int32) // return code
}

public class SEWrapper {
    
    private var isInitialized = false
    
    // Static reference counter to track active instances
    // This ensures swe_close() is only called when the last instance is deallocated
    private static var instanceCount = 0
    private static let instanceCountLock = NSLock()
    
    // Static flag to ensure path is only set once globally
    private static var pathSet = false
    private static let pathSetLock = NSLock()
    
    // MARK: - Initialization
    public init() {
        SEWrapper.instanceCountLock.lock()
        SEWrapper.instanceCount += 1
        SEWrapper.instanceCountLock.unlock()
        
        initialize()
    }
    
    deinit {
        close()
    }
    
    // MARK: - Setup Methods
    private func initialize() {
        guard !isInitialized else { return }
        
        // Set the ephemeris path to the se directory
        // Try multiple possible locations for the se folder
        var sePath = ""
        
        // First, try to find it in the bundle's resources
        if let resourcePath = Bundle.main.resourcePath {
            let resourceSePath = (resourcePath as NSString).appendingPathComponent("se")
            if FileManager.default.fileExists(atPath: resourceSePath) {
                sePath = resourceSePath
            }
        }
        
        // Try CSwissEphemeris/se in bundle resources
        if sePath.isEmpty {
            if let resourcePath = Bundle.main.resourcePath {
                let csEphSePath = (resourcePath as NSString).appendingPathComponent("CSwissEphemeris/se")
                if FileManager.default.fileExists(atPath: csEphSePath) {
                    sePath = csEphSePath
                }
            }
        }
        
        // Try in the bundle path itself (for macOS apps)
        if sePath.isEmpty {
            let possiblePaths = [
                Bundle.main.bundlePath + "/Contents/Resources/se",
                Bundle.main.bundlePath + "/Contents/Resources/CSwissEphemeris/se",
                Bundle.main.bundlePath + "/se",
                Bundle.main.bundlePath + "/CSwissEphemeris/se",
                Bundle.main.bundlePath + "/EnigmaApl/CSwissEphemeris/se"
            ]
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    sePath = path
                    break
                }
            }
        }
        
        if sePath.isEmpty {
            print("ERROR: Could not find se directory. Tried paths:")
            if let resourcePath = Bundle.main.resourcePath {
                print("  - \(resourcePath)/se")
                print("  - \(resourcePath)/CSwissEphemeris/se")
            }
            print("  - \(Bundle.main.bundlePath)/Contents/Resources/se")
            print("  - \(Bundle.main.bundlePath)/Contents/Resources/CSwissEphemeris/se")
            print("  - \(Bundle.main.bundlePath)/se")
            print("  - \(Bundle.main.bundlePath)/CSwissEphemeris/se")
            print("Current working directory: \(FileManager.default.currentDirectoryPath)")
            print("Bundle path: \(Bundle.main.bundlePath)")
            print("Resource path: \(Bundle.main.resourcePath ?? "nil")")
            // Don't initialize if path is not found - this will cause errors later
            return
        }
        
        // Verify the path is actually accessible and is a directory
        var isDirectory: ObjCBool = false
        let pathExists = FileManager.default.fileExists(atPath: sePath, isDirectory: &isDirectory)
        
        guard pathExists && isDirectory.boolValue else {
            print("ERROR: Path exists but is not a directory or is not accessible: \(sePath)")
            return
        }
        
        // Only set the path once globally to avoid memory management issues
        SEWrapper.pathSetLock.lock()
        if !SEWrapper.pathSet {
            print("Setting Swiss Ephemeris path to: \(sePath)")
            
            // Ensure the path ends with a trailing slash as Swiss Ephemeris expects
            let normalizedPath: String
            if sePath.hasSuffix("/") {
                normalizedPath = sePath
            } else {
                normalizedPath = sePath + "/"
            }
            
            // Store the path in a static variable to keep it alive
            // Use withCString to ensure the C string is valid for the duration of the call
            normalizedPath.withCString { cString in
                swe_set_ephe_path(cString)
            }
            
            SEWrapper.pathSet = true
        }
        SEWrapper.pathSetLock.unlock()
        
        // Initialize Swiss Ephemeris with default settings
        print("Initializing Swiss Ephemeris settings...")
        
        // Set default sidereal mode (Lahiri)
        swe_set_sid_mode(1, 0, 0) // Lahiri ayanamsa
        print("Sidereal mode set to Lahiri")
        
        // Set default topocentric position (can be overridden later)
        swe_set_topo(0, 0, 0) // Default to geocentric
        print("Topocentric position set to geocentric")
        
        isInitialized = true
        print("Swiss Ephemeris initialization completed successfully")
    }
    
    private func close() {
        guard isInitialized else { return }
        
        // Only call swe_close() when the last instance is being deallocated
        SEWrapper.instanceCountLock.lock()
        let currentCount = SEWrapper.instanceCount
        SEWrapper.instanceCount -= 1
        SEWrapper.instanceCountLock.unlock()
        
        // Only close if this is the last instance
        if currentCount == 1 {
            swe_close()
            // Reset path flag so it can be set again if needed
            SEWrapper.pathSetLock.lock()
            SEWrapper.pathSet = false
            SEWrapper.pathSetLock.unlock()
        }
        
        isInitialized = false
    }
    
    
    // MARK: - Julian Day Conversion
    /// Convert date and time (using UT) to a Julian Day Number.
    public func julianDay(date: AstronomicalDate, time: AstronomicalTime) -> Double {
        let gregflag = date.Gregorian ? 1 : 0
        let ut = time.HourDecimal
        return swe_julday(Int32(date.Year), Int32(date.Month), Int32(date.Day), ut, Int32(gregflag))
    }
    
    /// Convert Julian Day to an AstronomicalDateTime
    public func dateFromJulianDay(_ julianDay: Double, gregorian: Bool = true) -> AstronomicalDateTime {
        let gregflag = gregorian ? 1 : 0
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hour: Double = 0
        
        swe_revjul(julianDay, Int32(gregflag), &year, &month, &day, &hour)
        
        let date = AstronomicalDate(Year: Int(year), Month: Int(month), Day: Int(day), Gregorian: gregorian)
        let time = AstronomicalTime(HourDecimal: hour)
        let dateTime = AstronomicalDateTime(Date: date, Time: time)
        return dateTime
    }
    
    
    
    // MARK: - Planet Position Calculation
    public func calculatePlanetPosition(julianDay: Double, planet: Int, flags: Int) -> MainAstronomicalPosition? {
        guard isInitialized else {
            print("ERROR: Swiss Ephemeris not initialized")
            return nil
        }
        
        var result = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        
        // Note: Arrays are stack-allocated, automatically cleaned up when function returns
        // The error buffer is zero-initialized and used by the C function
        let returnCode = swe_calc_ut(julianDay, Int32(planet), Int32(flags), &result, &error)
        
        guard returnCode >= 0 else {
            let errorMessage = String(cString: error)
            print("Error calculating planet position: \(errorMessage)")
            return nil
        }
        
        return MainAstronomicalPosition(
            mainPos: result[0],
            deviation: result[1],
            distance: result[2],
            mainPosSpeed: result[3],
            deviationSpeed: result[4],
            distanceSpeed: result[5]
        )
    }
    
    // MARK: - House Calculation
    public func calculateHouses(julianDay: Double, latitude: Double, longitude: Double, houseSystem: Int) throws -> ([Double], [Double]) {

        let gauquelinIndex = 71
        let nrOfHouses = houseSystem == gauquelinIndex ? 36 : 12
        var cusps = [Double](repeating: 0.0, count: nrOfHouses + 1) // 12 or 36 houses + 1 extra
        var ascmc = [Double](repeating: 0.0, count: 10)
        
        guard isInitialized else { return (cusps, ascmc) }
        
        let returnCode = swe_houses(julianDay, latitude, longitude, Int32(houseSystem), &cusps, &ascmc)
            
        guard returnCode >= 0 else {
            print("Error calculating houses (return code: \(returnCode))")
            throw SEError.houseCalculationFailed(returnCode)
        }
        return (cusps, ascmc)
    }
    
    // MARK: - Sidereal Time
    public func siderealTime(julianDay: Double) -> Double {
        return swe_sidtime(julianDay)
    }
    
    // MARK: - Azimuth and altitude
    /// Calculate azimuth and altitude. Ignore atmospheric pressure and termperature.
    /// Returns azimuth and true altitude
    public func azimuthAndAltitude(julianDay: Double, rightAscension: Double, declination: Double, observerLatitude: Double, observerLongitude: Double, height: Double
    ) -> (azimuth: Double, altitude: Double) {
    
        let flag = 1        // Corresponds to SE_EQU2HOR in SE, handles equatorial coordinates
        var geoPos: [Double] = [observerLongitude, observerLatitude, height]
        var equCoordinates: [Double] = [rightAscension, declination, 0.0]
        let atPress = 0.0       // ignore atmospheric pressure
        let atTemp = 0.0        // ignore atmospheric temperature
        var azimuthAltitude = [Double](repeating: 0.0, count: 3)
        swe_azalt(julianDay, Int32(flag), &geoPos, atPress, atTemp, &equCoordinates, &azimuthAltitude)
        let azimuth = azimuthAltitude[0]
        let altitude = azimuthAltitude[1]
        return (azimuth, altitude)
    }
    
    // MARK: - Coordinate transfer from ecliptic to equatorial
    public func eclipticToEquatorial(eclipticCoordinates: [Double], obliquity: Double) -> (rightAscension: Double, declination: Double) {
        let negativeObliquity = -obliquity     // negative obliquity required for transferring ecliptic to equatorial coordinates
        let distance = 1.0    // ignore distance as it won't change
        var allEclipticCoordinates: [Double] = [eclipticCoordinates[0], eclipticCoordinates[1], distance]
        var equCoordinates: [Double] = [Double](repeating: 0.0, count: 3)
        swe_cotrans(&allEclipticCoordinates, &equCoordinates, negativeObliquity)
        let ra = equCoordinates[0]
        let dec = equCoordinates[1]
        return (ra, dec)
    }
    
}
