// SEWrapper.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

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
    
    // MARK: - Define topocentric
    /// Prepare for topocentric calculations
    /// Uses geographic longitude and latitude and height above sea-level (in meters)
    public func setTopocentric(geoLon: Double, geoLat: Double, height: Double) {
        swe_set_topo(geoLon, geoLat, height)
    }
    
    
    
    // MARK: - Define and get ayanamsha
    /// Define Ayanamsha for calculation of sidereal positions.
    /// - Parameters:
    ///     - idAyanamsha is seId for the ayanamsa
    /// Run this method if sidereal calculations will be used. If this method has not run during the current session, Fagan/Bradley is used as default ayanamsha.
    /// The method from the CommonSE dll is called using parameters t0 and t1 with the value 0, these will be ignored for all prdefined ayanamsha's.
    /// From docu SE:
    ///     void swe_set_sid_mode(int32 sid_mode, double t0, double ayan_t0);
    ///     This function can be used to specify the mode for sidereal computations.
    ///     swe_calc() or swe_fixstar() has then to be called with the bit SEFLG_SIDEREAL.
    ///     If swe_set_sid_mode() is not called, the default ayanamsha (Fagan/Bradley) is used.
    ///     If a predefined mode is wanted, the variable sid_mode has to be set, while t0 and ayan_t0 are not considered, i.e. can be 0.
    public func setAyanamsha(idAyanamsha: Int)
    {
        if (idAyanamsha >= -1 && idAyanamsha <= 39)
        {
            swe_set_sid_mode(Int32(idAyanamsha), 0, 0);
        }
    }

    /// Get offset for ayanamsha without using nutation
    /// - Parameters
    ///     - jdUt: Julian day in UT
    /// - Returns
    ///     - offset for ayanamsha
    /// From docu SE:
    ///     double swe_get_ayanamsa_ut(
    ///     double tjd_ut);     /* input: Julian day number in UT */
    public func getAyanamshaOffset(jdUt: Double) -> Double
    {
        let result = swe_get_ayanamsa_ut(jdUt)
        return result
    }
    
    // MARK: - Julian Day Conversion
    /// Convert date and time (using UT) to a Julian Day Number.
    /// - Parameters
    ///     - date : AstronomicalDate (Date and calendar, based on astreonomical dates)
    ///     - time :  AstronomicalTime (Time, both sexagesimal and decimal
    /// - Returns
    ///     - Julian day for UT
    /// From docu SE:
    ///     double swe_julday(
    ///         int year,
    ///         int month,
    ///         int day,
    ///         double hour,
    ///         int gregflag);
    public func julianDay(date: AstronomicalDate, time: AstronomicalTime) -> Double {
        let gregflag = date.Gregorian ? 1 : 0
        let ut = time.HourDecimal
        return swe_julday(Int32(date.Year), Int32(date.Month), Int32(date.Day), ut, Int32(gregflag))
    }
    
    /// Convert Julian Day to an AstronomicalDateTime
    /// - Parameters
    ///     - julianDay: julianDay for UT
    ///     - gregorian: true for Gregorian calendar, false for Julian calendar
    /// - Returns
    ///     - Populated struct AstronomicalDateTime
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
    
    
    
    // MARK: - Delta T Calculation
    /// Calculate Delta T (difference between Terrestrial Time and Universal Time).
    /// - Parameters
    ///     - jdUt: Julian day number in UT
    ///     - flag: ephemeris flag; always pass 2 (SEFLG_SWIEPH)
    /// - Returns
    ///     - Delta T in seconds
    /// From docu SE:
    ///     double swe_deltat_ex(
    ///         double tjd,     /* Julian day number */
    ///         int32 iflag,    /* ephemeris flag */
    ///         char *serr);    /* error string */
    ///     The function returns DeltaT in days; multiply by 86400 to get seconds.
    public func calculateDeltaT(jdUt: Double, flag: Int = 2) -> Double {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return 0.0
        }

        var error = [CChar](repeating: 0, count: 256)
        var deltaT: Double = 0.0

        error.withUnsafeMutableBufferPointer { errorBuffer in
            guard let errorPtr = errorBuffer.baseAddress else {
                Logger.log.error("Failed to get valid pointer for Delta T calculation")
                return
            }
            deltaT = swe_deltat_ex(jdUt, Int32(flag), errorPtr)
            if errorBuffer[0] != 0 {
                let errorMessage = String(cString: errorPtr)
                Logger.log.error("Error calculating Delta T: \(errorMessage)")
            }
        }

        return deltaT * 86400.0   // SE returns days; convert to seconds
    }

    // MARK: - Obliquity and Nutation Calculation
    /// Calculate mean obliquity, true obliquity and nutation in longitude.
    /// - Parameters
    ///     - jdUt: Julian day number in UT
    /// - Returns
    ///     - Tuple (meanObliquity, trueObliquity, nutation) in degrees, or nil on error
    /// From docu SE:
    ///     Call swe_calc_ut() with ipl = SE_ECL_NUT (-1).
    ///     xx[0] = true obliquity of the ecliptic (epsilon true)
    ///     xx[1] = mean obliquity of the ecliptic (epsilon mean)
    ///     xx[2] = nutation in longitude (delta psi)
    ///     xx[3] = nutation in obliquity (delta epsilon)
    public func calculateObliquity(jdUt: Double) -> (meanObliquity: Double, trueObliquity: Double, nutation: Double)? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }

        var result = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        var returnCode: Int32 = 0
        var errorMessage: String = ""

        result.withUnsafeMutableBufferPointer { resultBuffer in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                guard let resultPtr = resultBuffer.baseAddress,
                      let errorPtr = errorBuffer.baseAddress else {
                    Logger.log.error("Failed to get valid pointers for obliquity calculation")
                    return
                }
                returnCode = swe_calc_ut(jdUt, SE_ECL_NUT, SEFLG_SWIEPH, resultPtr, errorPtr)
                if returnCode < 0 {
                    errorMessage = String(cString: errorPtr)
                }
            }
        }

        guard returnCode >= 0 else {
            Logger.log.error("Error calculating obliquity: \(errorMessage)")
            return nil
        }

        return (meanObliquity: result[1], trueObliquity: result[0], nutation: result[2])
    }

    // MARK: - Factor Position Calculation
    /// Calculate the position of a factor.
    /// - Parameters
    ///     - julianDay: Julian day for UT
    ///     - factor: id for Swiss ephemeris for a factor
    ///     - flags: combined value of flags for the SE
    /// - Returns
    ///     - Populated struct MainAstronomicalPosition
    /// Docu from SE
    ///     int32 swe_calc_ut(
    ///         double tjd_ut,
    ///         int32 ipl,
    ///         int32 iflag,
    ///         double* xx,
    ///         char* serr);
    ///     where
    ///     tjd_ut   = Julian day, Universal Time
    ///     ipl      = body number
    ///     iflag    = a 32 bit integer containing bit flags that indicate what kind of computation is wanted
    ///     xx       = array of 6 doubles for longitude, latitude, distance, speed in long., speed in lat., and speed in dist.
    ///     serr[256] = character string to return error messages in case of error.
    public func calculateFactorPosition(julianDay: Double, factor: Int, flags: Int) -> MainAstronomicalPosition? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }
        
        var result = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)

        let preciseJD = julianDay
        
        // Use withUnsafeMutableBufferPointer to ensure proper memory handling when passing arrays to C function
        // This prevents EXC_BAD_ACCESS errors from invalid pointer access
        var returnCode: Int32 = 0
        var errorMessage: String = ""
        
        result.withUnsafeMutableBufferPointer { resultBuffer in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                // Ensure all base addresses are non-nil before calling C function
                guard let resultPtr = resultBuffer.baseAddress,
                      let errorPtr = errorBuffer.baseAddress else {
                    Logger.log.error("Failed to get valid pointers for factor position calculation")
                    return
                }
                
                returnCode = swe_calc_ut(preciseJD, Int32(factor), Int32(flags), resultPtr, errorPtr)
                
                if returnCode < 0 {
                    errorMessage = String(cString: errorPtr)
                }
            }
        }
        
        guard returnCode >= 0 else {
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
    
    // MARK: - Fixed Star Position Calculation
    /// Calculate the position of a fixed star.
    /// - Parameters
    ///     - jdUt: Julian day in Universal Time
    ///     - starName: name of the fixed star to be searched
    ///     - flags: combined value of flags for the SE
    /// - Returns
    ///     - Populated struct MainAstronomicalPosition, or nil on error
    /// Docu from SE:
    ///     int32 swe_fixstar2_ut(
    ///         char* star,       /* name of fixed star to search; returns matched name */
    ///         double tjd_ut,    /* Julian day, Universal Time */
    ///         int32 iflag,      /* flags */
    ///         double* xx,       /* array of 6 doubles: longitude, latitude, distance, speeds */
    ///         char* serr);      /* error string, 256 chars */
    public func calculateFixStar(jdUt: Double, starName: String, flags: Int) -> MainAstronomicalPosition? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }

        var result = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        // SE_MAX_STNAME is 256; star is both input (search name) and output (matched name)
        var starBuffer = [CChar](repeating: 0, count: 256)
        let starNameBytes = Array(starName.utf8CString)
        let copyCount = min(starNameBytes.count, 255)
        for i in 0..<copyCount {
            starBuffer[i] = starNameBytes[i]
        }

        var returnCode: Int32 = 0
        var errorMessage: String = ""

        starBuffer.withUnsafeMutableBufferPointer { starBuf in
            result.withUnsafeMutableBufferPointer { resultBuffer in
                error.withUnsafeMutableBufferPointer { errorBuffer in
                    guard let starPtr = starBuf.baseAddress,
                          let resultPtr = resultBuffer.baseAddress,
                          let errorPtr = errorBuffer.baseAddress else {
                        Logger.log.error("Failed to get valid pointers for fixed star calculation")
                        return
                    }
                    returnCode = swe_fixstar2_ut(starPtr, jdUt, Int32(flags), resultPtr, errorPtr)
                    if returnCode < 0 {
                        errorMessage = String(cString: errorPtr)
                    }
                }
            }
        }

        guard returnCode >= 0 else {
            Logger.log.error("Error calculating fixed star position: \(errorMessage)")
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

    // MARK: - Fixed Star Magnitude
    /// Return the magnitude of a fixed star.
    /// - Parameters
    ///     - starName: name of the fixed star to be searched
    /// - Returns
    ///     - Magnitude as Double, or nil on error
    /// Docu from SE:
    ///     int32 swe_fixstar2_mag(
    ///         char* star,   /* name of fixed star to search; returns matched name */
    ///         double* mag,  /* returned magnitude */
    ///         char* serr);  /* error string, 256 chars */
    public func calculateFixStarMagnitude(starName: String) -> Double? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }

        var starBuffer = [CChar](repeating: 0, count: 256)
        let starNameBytes = Array(starName.utf8CString)
        let copyCount = min(starNameBytes.count, 255)
        for i in 0..<copyCount {
            starBuffer[i] = starNameBytes[i]
        }

        var magnitude: Double = 0.0
        var error = [CChar](repeating: 0, count: 256)
        var returnCode: Int32 = 0
        var errorMessage: String = ""

        starBuffer.withUnsafeMutableBufferPointer { starBuf in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                guard let starPtr = starBuf.baseAddress,
                      let errorPtr = errorBuffer.baseAddress else {
                    Logger.log.error("Failed to get valid pointers for fixed star magnitude calculation")
                    return
                }
                returnCode = swe_fixstar2_mag(starPtr, &magnitude, errorPtr)
                if returnCode < 0 {
                    errorMessage = String(cString: errorPtr)
                }
            }
        }

        guard returnCode >= 0 else {
            Logger.log.error("Error calculating fixed star magnitude: \(errorMessage)")
            return nil
        }

        return magnitude
    }

    // MARK: - House Calculation
    /// Calculate the position of house cusps
    /// - Parameters
    ///     - julianDay: Julian day in UT
    ///     - latitude: geographic latitude
    ///     - longitude; geographic longitude
    ///     - houseSystem; ascii code for abbrevation of the house system
    /// - Returns
    ///     - Tuple with arrays with cusps (using index 1 .. 13) and array with Ascendant, MC, ARMC etc (see below)
    /// Docu Se;/
    ///     int swe_houses(
    ///         double tjd_ut,      /* Julian day number, UT */
    ///         double geolat,      /* geographic latitude, in degrees */
    ///         double geolon,      /* geographic longitude, in degrees
    ///                       * eastern longitude is positive,
    ///                       * western longitude is negative,
    ///                       * northern latitude is positive,
    ///                       * southern latitude is negative */
    ///         int hsys,                /* house method, ascii code of one of the letters documented below */
    ///         double *cusps,      /* array for 13 (or 37 for hsys G) doubles, explained further below */
    ///         double *ascmc);     /* array for 10 doubles, explained further below */
    ///     Content of second array:
    ///         ascmc[0] = Ascendant
    ///         ascmc[1] = MC
    ///         ascmc[2] = ARMC
    ///         ascmc[3] = Vertex
    ///         ascmc[4] = "equatorial ascendant"
    ///         ascmc[5] = "co-ascendant" (Walter Koch)
    ///         ascmc[6] = "co-ascendant" (Michael Munkasey)
    ///         ascmc[7] = "polar ascendant" (M. Munkasey)
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
        
        // Use withUnsafeMutableBufferPointer to ensure proper memory handling when passing arrays to C function
        // This prevents EXC_BAD_ACCESS errors from invalid pointer access
        var returnCode: Int32 = 0
        
        cusps.withUnsafeMutableBufferPointer { cuspsBuffer in
            ascmc.withUnsafeMutableBufferPointer { ascmcBuffer in
                // Ensure all base addresses are non-nil before calling C function
                guard let cuspsPtr = cuspsBuffer.baseAddress,
                      let ascmcPtr = ascmcBuffer.baseAddress else {
                    Logger.log.error("Failed to get valid pointers for house calculation")
                    return
                }
                
                returnCode = swe_houses(preciseJulianDay, preciseLatitude, preciseLongitude, Int32(houseSystem), cuspsPtr, ascmcPtr)
            }
        }
            
        guard returnCode >= 0 else {
            Logger.log.error("Error calculating houses (return code: \(returnCode))")
            throw SEError.houseCalculationFailed(returnCode)
        }
        return (cusps, ascmc)
    }
    
       
    // MARK: - Azimuth and altitude
    /// Calculate azimuth and altitude. Ignore atmospheric pressure and termperature.
    /// - Parameters
    ///     - julianDay: Julian day for UT
    ///     - rightAscension: right ascension in degrees
    ///     - declination: Declination
    ///     - observerlatitude: geographic latitude of observer
    ///     - height for location observer aboe sea level, in meters
    /// - Returns
    ///     - Tuple with azimuth and altitude
    /// Docu from SE
    ///     void swe_azalt(
    ///         double tjd_ut,      // UT
    ///         int32 calc_flag,    // SE_ECL2HOR or SE_EQU2HOR
    ///         double *geopos,     // array of 3 doubles: geograph. long., lat., height
    ///         double atpress,     // atmospheric pressure in mbar (hPa)
    ///         double attemp,      // atmospheric temperature in degrees Celsius
    ///         double *xin,        // array of 3 doubles: position of body in either ecliptical or equatorial coordinates, depending on calc_flag
    ///         double *xaz);       // return array of 3 doubles, containing azimuth, true altitude, apparent altitude
    ///     If calc_flag = SE_ECL2HOR, set xin[0] = ecl. long., xin[1] = ecl. lat., (xin[2] = distance (not required));
    ///     else
    ///     if calc_flag = SE_EQU2HOR, set xin[0] = right ascension, xin[1] = declination, (xin[2] = distance (not required));
    ///     #define SE_ECL2HOR  0
    ///     #define SE_EQU2HOR  1
    ///     The return values are:
    ///     ·     xaz[0] = azimuth, i.e. position degree, measured from the south point to west;
    ///     ·     xaz[1] = true altitude above horizon in degrees;
    ///     ·     xaz[2] = apparent (refracted) altitude above horizon in degrees.
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
        
        // Use withUnsafeMutableBufferPointer to ensure proper memory handling when passing arrays to C function
        // This prevents EXC_BAD_ACCESS errors from invalid pointer access
        var azimuth: Double = 0.0
        var altitude: Double = 0.0
        
        geoPos.withUnsafeMutableBufferPointer { geoPosBuffer in
            equCoordinates.withUnsafeMutableBufferPointer { equCoordinatesBuffer in
                azimuthAltitude.withUnsafeMutableBufferPointer { azimuthAltitudeBuffer in
                    // Ensure all base addresses are non-nil before calling C function
                    guard let geoPosPtr = geoPosBuffer.baseAddress,
                          let equCoordinatesPtr = equCoordinatesBuffer.baseAddress,
                          let azimuthAltitudePtr = azimuthAltitudeBuffer.baseAddress else {
                        Logger.log.error("Failed to get valid pointers for azimuth and altitude calculation")
                        return
                    }
                    
                    swe_azalt(
                        preciseJulianDay,
                        Int32(flag),
                        geoPosPtr,
                        atPress,
                        atTemp,
                        equCoordinatesPtr,
                        azimuthAltitudePtr
                    )
                    
                    // Extract results from the buffer - C function modifies the memory directly
                    if azimuthAltitudeBuffer.count >= 2 {
                        azimuth = azimuthAltitudeBuffer[0]
                        altitude = azimuthAltitudeBuffer[1]
                    }
                }
            }
        }
        
        return (azimuth, altitude)
    }
    
    // MARK: - Coordinate transfer from ecliptic to equatorial
    /// Calclate right ascension and declination
    /// - Parameters
    ///     - eclipticCoordinates : longitude and latitude, in that order
    ///     - obliquity : Obliquity of the earth'w axis
    /// - Returns
    ///     - tuple with right ascension and declination, in that order
    /// Docu from SE:
    ///     /* equator -> ecliptic    : eps must be positive
    ///     * ecliptic -> equator    : eps must be negative
    ///     * eps, longitude and latitude are in positive degrees! */
    ///     void swe_cotrans(
    ///         double *xpo,        /* 3 doubles: long., lat., dist. to be converted; distance remains unchanged, can be set to 1.00 */
    ///         double *xpn,        /* 3 doubles: long., lat., dist. Result of the conversion */
    ///         double eps);        /* obliquity of ecliptic, in degrees. */
    ///
    public func eclipticToEquatorial(eclipticCoordinates: [Double], obliquity: Double) -> (rightAscension: Double, declination: Double) {
        guard eclipticCoordinates.count >= 2 else {
            Logger.log.error("eclipticToEquatorial requires at least 2 coordinates (longitude, latitude)")
            return (0.0, 0.0)
        }
        
        let negativeObliquity = -obliquity     // negative obliquity required for transferring ecliptic to equatorial coordinates
        let distance = 1.0    // ignore distance as it won't change
        var allEclipticCoordinates: [Double] = [eclipticCoordinates[0], eclipticCoordinates[1], distance]
        var equCoordinates: [Double] = [Double](repeating: 0.0, count: 3)
        
        // Use withUnsafeMutableBufferPointer to ensure proper memory handling when passing arrays to C function
        // This prevents EXC_BAD_ACCESS errors from invalid pointer access
        var ra: Double = 0.0
        var dec: Double = 0.0
        
        allEclipticCoordinates.withUnsafeMutableBufferPointer { eclipticBuffer in
            equCoordinates.withUnsafeMutableBufferPointer { equBuffer in
                // Ensure all base addresses are non-nil before calling C function
                guard let eclipticPtr = eclipticBuffer.baseAddress,
                      let equPtr = equBuffer.baseAddress else {
                    Logger.log.error("Failed to get valid pointers for coordinate transformation")
                    return
                }
                
                swe_cotrans(eclipticPtr, equPtr, negativeObliquity)
                
                // Extract results from the buffer - C function modifies the memory directly
                if equBuffer.count >= 2 {
                    ra = equBuffer[0]
                    dec = equBuffer[1]
                }
            }
        }
        
        return (ra, dec)
    }
    
    // MARK: - Orbital Elements Calculation
    /// Calculate orbital elements for a planet
    /// - Parameters:
    ///   - julianDay: Julian day for UT (Universal Time). This will be converted to ET internally.
    ///   - planet: Swiss Ephemeris planet ID
    ///   - flags: Calculation flags (e.g., SEFLG_SWIEPH)
    /// - Returns
    ///     - OrbitalElements if calculation succeeds, nil otherwise
    ///   Docu from SE:
    ///     int32 swe_get_orbital_elements(
    ///         double tjd_et,
    ///         int32 ipl,
    ///         int32 iflag,
    ///         double *dret,
    ///         char *serr);
    ///     /* Function calculates osculating orbital elements (Kepler elements) of a planet or asteroid or the EMB. The function returns error if called for the Sun, the lunar nodes, or the apsides.
    ///     * Input parameters:
    ///     * tjd_et Julian day number, in TT (ET)
    ///     * ipl object number
    ///     * iflag can contain
    ///     * - ephemeris flag: SEFLG_JPLEPH, SEFLG_SWIEPH, SEFLG_MOSEPH
    ///     * - center:
    ///     * Sun: SEFLG_HELCTR (assumed as default) or
    ///     * SS Barycentre: SEFLG_BARYCTR (rel. to solar system barycentre)
    ///     * (only possible for planets beyond Jupiter)
    ///     * For elements of the Moon, the calculation is geocentric.
    ///     * - sum all masses inside the orbit to be computed (method of Astronomical Almanac):
    ///     * SEFLG_ORBEL_AA
    ///     * - reference ecliptic: SEFLG_J2000;
    ///     * if missing, mean ecliptic of date is chosen (still not implemented)
    ///     * output parameters:
    ///     * dret[] array of return values, declare as dret[50]
    ///     * dret[0] semimajor axis (a)
    ///     * dret[1] eccentricity (e)
    ///     * dret[2] inclination (in)
    ///     * dret[3] longitude of ascending node (upper case omega OM)
    ///     * dret[4] argument of periapsis (lower case omega om)
    ///     * dret[5] longitude of periapsis (peri)
    ///     * dret[6] mean anomaly at epoch (M0)
    ///     * dret[7] true anomaly at epoch (N0)
    ///     * dret[8] eccentric anomaly at epoch (E0)
    ///     * dret[9] mean longitude at epoch (LM)
    ///     * dret[10] sidereal orbital period in tropical years
    ///     * dret[11] mean daily motion
    ///     * dret[12] tropical period in years
    ///     * dret[13] synodic period in days,
    ///     * negative, if inner planet (Venus, Mercury, Aten asteroids) or Moon
    ///     * dret[14] time of perihelion passage
    ///     * dret[15] perihelion distance
    ///     * dret[16] aphelion distance
     
    public func calcOrbitalElements(julianDay: Double, planet: Int, flags: Int) -> OrbitalElements? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }
        Logger.log.info("Starting calculation of orbital elements")
        var result = [Double](repeating: 0.0, count: 17)
        var error = [CChar](repeating: 0, count: 256)
        
        let preciseJD = julianDay
        
        // swe_get_orbital_elements may not support all flags - remove SPEED flag and use only SWIEPH
        // SPEED flag (256) might cause issues with orbital elements calculation
        let orbitalElementsFlags = flags
        
        // Use withUnsafeMutableBufferPointer to ensure proper memory handling when passing arrays to C function
        // This prevents EXC_BAD_ACCESS errors from invalid pointer access
        var returnCode: Int32 = 0
        var errorMessage: String = ""

        Logger.log.info("Handling memory for orbital elements")
        result.withUnsafeMutableBufferPointer { resultBuffer in
            error.withUnsafeMutableBufferPointer { errorBuffer in
                // Ensure all base addresses are non-nil before calling C function
                guard let resultPtr = resultBuffer.baseAddress,
                      let errorPtr = errorBuffer.baseAddress else {
                    Logger.log.error("Failed to get valid pointers for orbital elements calculation")
                    return
                }
                Logger.log.info("About to call SE for orbital elements")
                returnCode = swe_get_orbital_elements(preciseJD, Int32(planet), Int32(orbitalElementsFlags), resultPtr, errorPtr)
                Logger.log.info("Just called SE for orbital elements")
                if returnCode < 0 {
                    errorMessage = String(cString: errorPtr)
                }
            }
        }
        
        guard returnCode >= 0 else {
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
    
    // MARK: - Eclipse Finding

    /// Find the next solar eclipse (global maximum) after the given Julian Day.
    /// - Parameter afterJD: Start search after this JD (UT)
    /// - Returns: JD of the next solar eclipse maximum, or nil on error
    public func nextSolarEclipse(afterJD: Double) -> Double? {
        guard isInitialized else { return nil }
        var tret = [Double](repeating: 0.0, count: 10)
        var error = [CChar](repeating: 0, count: 256)
        var returnCode: Int32 = 0

        tret.withUnsafeMutableBufferPointer { tretBuf in
            error.withUnsafeMutableBufferPointer { errBuf in
                guard let tretPtr = tretBuf.baseAddress,
                      let errPtr  = errBuf.baseAddress else { return }
                returnCode = swe_sol_eclipse_when_glob(afterJD, 2, 0, tretPtr, 0, errPtr)
            }
        }

        guard returnCode >= 0 else { return nil }
        return tret[0]
    }

    /// Find the next lunar eclipse maximum after the given Julian Day.
    /// - Parameter afterJD: Start search after this JD (UT)
    /// - Returns: JD of the next lunar eclipse maximum, or nil on error
    public func nextLunarEclipse(afterJD: Double) -> Double? {
        guard isInitialized else { return nil }
        var tret = [Double](repeating: 0.0, count: 10)
        var error = [CChar](repeating: 0, count: 256)
        var returnCode: Int32 = 0

        tret.withUnsafeMutableBufferPointer { tretBuf in
            error.withUnsafeMutableBufferPointer { errBuf in
                guard let tretPtr = tretBuf.baseAddress,
                      let errPtr  = errBuf.baseAddress else { return }
                returnCode = swe_lun_eclipse_when(afterJD, 2, 0, tretPtr, 0, errPtr)
            }
        }

        guard returnCode >= 0 else { return nil }
        return tret[0]
    }

    // MARK: - Apsides Calculation
    /// Calculate nodes and apsides (perihelion/aphelion for planets, perigee/apogee for Moon)
    /// - Parameters:
    ///   - julianDay: Julian day for UT
    ///   - planet: Swiss Ephemeris planet ID
    ///   - flags: Calculation flags (e.g., SEFLG_SWIEPH)
    ///   - method: Method flag (SE_NODBIT_MEAN = 1 for mean, SE_NODBIT_OSCU = 2 for osculating)
    /// - Returns: ApsidesResult containing nodes and apsides positions, or nil if calculation fails
    /// Docu from SE;
    ///     int32 swe_nod_aps_ut(
    ///         double tjd_ut, // Julian day number in UT
    ///         int32 ipl,     // planet number
    ///         int32 iflag,   // flag bits
    ///         int32 method,  // method, see explanations below
    ///         double *xnasc, // array of 6 double for ascending node
    ///         double *xndsc, // array of 6 double for descending node
    ///         double *xperi, // array of 6 double for perihelion
    ///         double *xaphe, // array of 6 double for aphelion
    ///         char *serr);   // character string to contain error messages, 256 chars
    ///     The parameter method tells the function what kind of nodes or apsides are required:
    ///     #define SE_NODBIT_MEAN        1
    ///     Mean nodes and apsides are calculated for the bodies that have them, i.e. for the Moon and the planets Mercury through Neptune, osculating ones for Pluto and the asteroids. This is the default method, also used if method=0.
    ///     #define SE_NODBIT_OSCU        2
    ///     Osculating nodes and apsides are calculated for all bodies.
    ///     #define SE_NODBIT_OSCU_BAR     4
    ///     Osculating nodes and apsides are calculated for all bodies. With planets beyond Jupiter, the nodes and apsides are calculated from barycentric positions and speed. Cf. the explanations in swisseph.doc.
    ///     If this bit is combined with SE_NODBIT_MEAN, mean values are given for the planets Mercury - Neptune.
    ///     #define SE_NODBIT_FOPOINT 256
    ///     The second focal point of the orbital ellipse is computed and returned in the array of the aphelion. This bit can be combined with any other bit.


    public func calculateApsides(julianDay: Double, planet: Int, flags: Int, method: Int = 1) -> ApsidesResult? {
        guard isInitialized else {
            Logger.log.error("Swiss Ephemeris not initialized")
            return nil
        }
        var xnasc = [Double](repeating: 0.0, count: 6)  // ascending node
        var xndsc = [Double](repeating: 0.0, count: 6)  // descending node
        var xperi = [Double](repeating: 0.0, count: 6)  // perihelion/perigee
        var xaphe = [Double](repeating: 0.0, count: 6)  // aphelion/apogee
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
                            // Ensure all base addresses are non-nil before calling C function
                            guard let xnascPtr = xnascBuffer.baseAddress,
                                  let xndscPtr = xndscBuffer.baseAddress,
                                  let xperiPtr = xperiBuffer.baseAddress,
                                  let xaphePtr = xapheBuffer.baseAddress,
                                  let errorPtr = errorBuffer.baseAddress else {
                                Logger.log.error("Failed to get valid pointers for apsides calculation")
                                return
                            }
                            returnCode = swe_nod_aps_ut(
                                preciseJD,
                                Int32(planet),
                                Int32(flags),
                                Int32(method),
                                xnascPtr,
                                xndscPtr,
                                xperiPtr,
                                xaphePtr,
                                errorPtr
                            )
                            if returnCode < 0 {
                                errorMessage = String(cString: errorPtr)
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
