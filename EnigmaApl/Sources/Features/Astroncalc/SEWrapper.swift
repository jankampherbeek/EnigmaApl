//
//  SEWrapper.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//

/// Wrapper for the functions of the Swiss Ephemeris

@preconcurrency import Foundation
import SwissEphC

// MARK: - Errors
/// TODO: Implement specific error handling and remove this enum.
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
        
        // Helper function to check if a path exists and is a directory
        func checkPath(_ path: String) -> Bool {
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            return exists && isDirectory.boolValue
        }
        
        // First, try to find it in the bundle's resources (main bundle or test bundle)
        // Bundle.main is thread-safe to access from any thread, despite Swift's strict concurrency checking
        // We access it directly - the nonisolated context makes this safe
        let bundlesToCheck: [Bundle] = [Bundle.main, Bundle(for: type(of: self))]
        
        for bundle in bundlesToCheck {
            if let resourcePath = bundle.resourcePath {
                let resourceSePath = (resourcePath as NSString).appendingPathComponent("se")
                if checkPath(resourceSePath) {
                    sePath = resourceSePath
                    break
                }
            }
        }
        
        // Try CSwissEphemeris/se in bundle resources
        if sePath.isEmpty {
            for bundle in bundlesToCheck {
                if let resourcePath = bundle.resourcePath {
                    let csEphSePath = (resourcePath as NSString).appendingPathComponent("CSwissEphemeris/se/")
                    if checkPath(csEphSePath) {
                        sePath = csEphSePath
                        break
                    }
                }
            }
        }
        
        // Try in the bundle path itself (for macOS apps)
        if sePath.isEmpty {
            var possiblePaths: [String] = []
            for bundle in bundlesToCheck {
                possiblePaths.append(contentsOf: [
                    bundle.bundlePath + "/Contents/Resources/se/",
                ])
            }
            
            for path in possiblePaths {
                if checkPath(path) {
                    sePath = path
                    break
                }
            }
        }
        
        // Try relative to the current working directory (for tests and development)
        if sePath.isEmpty {
            let currentDir = FileManager.default.currentDirectoryPath
            sePath = currentDir + "/EnigmaApl/CSwissEphemeris/se"
        }
        
        if sePath.isEmpty {
            Logger.log.error("Could not find se directory")
            return
        }
        
        // Verify the path is actually accessible and is a directory
        var isDirectory: ObjCBool = false
        let pathExists = FileManager.default.fileExists(atPath: sePath, isDirectory: &isDirectory)
        
        guard pathExists && isDirectory.boolValue else {
            Logger.log.error("Path exists but is not a directory or is not accessible: \(sePath)")
            return
        }
        
        // Only set the path once globally to avoid memory management issues
        SEWrapper.pathSetLock.lock()
        if !SEWrapper.pathSet {
            Logger.log.info("Setting Swiss Ephemeris path to: \(sePath)")
            sePath.withCString { cString in
                swe_set_ephe_path(cString)
            }
            SEWrapper.pathSet = true
        }
        SEWrapper.pathSetLock.unlock()
        

        isInitialized = true
        Logger.log.info("Swiss Ephemeris initialization completed successfully")
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
        Logger.log.verbose("AstronomicalDate \(date.Year)-\(date.Month)-\(date.Day) AstronomicalTime \(time.HourDecimal)")
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
    
    
    
    // MARK: - Factor Position Calculation
    /// Calculate the position of a factor.
    public func calculateFactorPosition(julianDay: Double, planet: Int, flags: Int) -> MainAstronomicalPosition? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }
        
        var result = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)

        let preciseJD = julianDay
        
        let returnCode = swe_calc_ut(preciseJD, Int32(planet), Int32(flags), &result, &error)
        guard returnCode >= 0 else {
            let errorMessage = String(cString: error)
            Logger.log.error("Error calculating planet position: \(errorMessage)")
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
    /// Calculate the position of house cusps
    public func calculateHouses(julianDay: Double, latitude: Double, longitude: Double, houseSystem: Int) throws -> ([Double], [Double]) {

        let gauquelinIndex = 71
        let nrOfHouses = houseSystem == gauquelinIndex ? 36 : 12
        var cusps = [Double](repeating: 0.0, count: nrOfHouses + 1) // 12 or 36 houses + 1 extra
        var ascmc = [Double](repeating: 0.0, count: 10)
        
        guard isInitialized else { return (cusps, ascmc) }
        
        // Ensure maximum precision by storing in a local variable with explicit type
        let preciseJulianDay: Double = julianDay
        let preciseLatitude: Double = latitude
        let preciseLongitude: Double = longitude
        
        let returnCode = swe_houses(preciseJulianDay, preciseLatitude, preciseLongitude, Int32(houseSystem), &cusps, &ascmc)
            
        guard returnCode >= 0 else {
            Logger.log.error("Error calculating houses (return code: \(returnCode))")
            throw SEError.houseCalculationFailed(returnCode)
        }
        return (cusps, ascmc)
    }
    
    // MARK: - Sidereal Time
    /// Calculate siderealTime at Greenwich
    public func siderealTime(julianDay: Double) -> Double {
        // Ensure maximum precision by storing in a local variable with explicit type
        let preciseJulianDay: Double = julianDay
        return swe_sidtime(preciseJulianDay)
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
        
        // Ensure maximum precision by storing in a local variable with explicit type
        let preciseJulianDay: Double = julianDay
        swe_azalt(preciseJulianDay, Int32(flag), &geoPos, atPress, atTemp, &equCoordinates, &azimuthAltitude)
        let azimuth = azimuthAltitude[0]
        let altitude = azimuthAltitude[1]
        return (azimuth, altitude)
    }
    
    // MARK: - Coordinate transfer from ecliptic to equatorial
    /// Calclate right ascension and declination using longitude, latitude and obliquity as input
    /// The array eclipticCoordinates contains longitude and latitude in that order
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
    
    // MARK: - Orbital Elements Calculation
    /// Calculate orbital elements for a planet
    /// - Parameters:
    ///   - julianDay: Julian day for ET (Ephemeris Time). Note: This function requires ET, not UT.
    ///     For most purposes, ET ≈ UT, but for high precision, convert UT to ET first.
    ///   - planet: Swiss Ephemeris planet ID
    ///   - flags: Calculation flags (e.g., SEFLG_SWIEPH)
    /// - Returns: OrbitalElements if calculation succeeds, nil otherwise
    public func calcOrbitalElements(julianDay: Double, planet: Int, flags: Int) -> OrbitalElements? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }
        
        var result = [Double](repeating: 0.0, count: 12)
        var error = [CChar](repeating: 0, count: 256)
        
        // Ensure maximum precision by storing in a local variable with explicit type
        let preciseJD = julianDay
        
        let returnCode = swe_get_orbital_elements(preciseJD, Int32(planet), Int32(flags), &result, &error)
        guard returnCode >= 0 else {
            let errorMessage = String(cString: error)
            Logger.log.error("Error calculating orbital elements: \(errorMessage)")
            return nil
        }
        
        // Swiss Ephemeris returns 12 values in the result array:
        // [0] = semi-major axis (a) in AU
        // [1] = eccentricity (e)
        // [2] = inclination (i) in degrees
        // [3] = argument of perihelion (ω) in degrees
        // [4] = ascending node (Ω) in degrees
        // [5] = mean anomaly (M) in degrees
        // [6] = true anomaly (v) in degrees
        // [7] = eccentric anomaly (E) in degrees
        // [8] = mean longitude (L) in degrees
        // [9] = true longitude (L') in degrees
        // [10] = distance (r) in AU
        // [11] = speed (v) in AU/day
        return OrbitalElements(
            semiMajorAxis: result[0],
            eccentricity: result[1],
            inclination: result[2],
            argumentOfPerihelion: result[3],
            ascendingNode: result[4],
            meanAnomaly: result[5],
            trueAnomaly: result[6],
            eccentricAnomaly: result[7],
            meanLongitude: result[8],
            trueLongitude: result[9],
            distance: result[10],
            speed: result[11]
        )
    }
    
    // MARK: - Apsides Calculation
    /// Calculate nodes and apsides (perihelion/aphelion for planets, perigee/apogee for Moon)
    /// - Parameters:
    ///   - julianDay: Julian day for UT
    ///   - planet: Swiss Ephemeris planet ID
    ///   - flags: Calculation flags (e.g., SEFLG_SWIEPH)
    ///   - method: Method flag (SE_NODBIT_MEAN = 1 for mean, SE_NODBIT_OSCU = 2 for osculating)
    /// - Returns: ApsidesResult containing nodes and apsides positions, or nil if calculation fails
    public func calculateApsides(julianDay: Double, planet: Int, flags: Int, method: Int = 1) -> ApsidesResult? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }
        
        var xnasc = [Double](repeating: 0.0, count: 3)  // ascending node [longitude, latitude, distance]
        var xndsc = [Double](repeating: 0.0, count: 3)  // descending node [longitude, latitude, distance]
        var xperi = [Double](repeating: 0.0, count: 3) // perihelion/perigee [longitude, latitude, distance]
        var xaphe = [Double](repeating: 0.0, count: 3) // aphelion/apogee [longitude, latitude, distance]
        var error = [CChar](repeating: 0, count: 256)
        
        // Ensure maximum precision by storing in a local variable with explicit type
        let preciseJD = julianDay
        
        // Use withUnsafeMutableBufferPointer to ensure proper memory handling when passing multiple arrays to C function
        // This ensures all arrays are properly aligned and contiguous in memory
        var returnCode: Int32 = 0
        var errorMessage: String = ""
        
        xnasc.withUnsafeMutableBufferPointer { xnascBuffer in
            xndsc.withUnsafeMutableBufferPointer { xndscBuffer in
                xperi.withUnsafeMutableBufferPointer { xperiBuffer in
                    xaphe.withUnsafeMutableBufferPointer { xapheBuffer in
                        error.withUnsafeMutableBufferPointer { errorBuffer in
                            returnCode = swe_nod_aps_ut(
                                preciseJD,
                                Int32(planet),
                                Int32(flags),
                                Int32(method),
                                xnascBuffer.baseAddress!,
                                xndscBuffer.baseAddress!,
                                xperiBuffer.baseAddress!,
                                xapheBuffer.baseAddress!,
                                errorBuffer.baseAddress!
                            )
                            
                            if returnCode < 0 {
                                errorMessage = String(cString: errorBuffer.baseAddress!)
                            }
                        }
                    }
                }
            }
        }
        
        guard returnCode >= 0 else {
            Logger.log.error("Error calculating apsides: \(errorMessage)")
            return nil
        }
        
        return ApsidesResult(
            ascendingNode: xnasc,
            descendingNode: xndsc,
            perihelion: xperi,
            aphelion: xaphe
        )
    }
    
}
