//
//  SwissEph.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//

import Foundation
import SwissEphC

// MARK: - Planet Constants
public enum Planet: Int32 {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case mars = 4
    case jupiter = 5
    case saturn = 6
    case uranus = 7
    case neptune = 8
    case pluto = 9
    case earth = 14
    case chiron = 15
}

// MARK: - Calculation Flags
public struct CalculationFlags: OptionSet {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let swissEph = CalculationFlags(rawValue: 2)
    public static let speed = CalculationFlags(rawValue: 256)
    public static let heliocentric = CalculationFlags(rawValue: 8)
    public static let truePosition = CalculationFlags(rawValue: 16)
    public static let j2000 = CalculationFlags(rawValue: 32)
    public static let noNutation = CalculationFlags(rawValue: 64)
    public static let noGravitationalDeflection = CalculationFlags(rawValue: 512)
    public static let noAberration = CalculationFlags(rawValue: 1024)
    public static let equatorial = CalculationFlags(rawValue: 2048)
    public static let cartesian = CalculationFlags(rawValue: 4096)
    public static let radians = CalculationFlags(rawValue: 8192)
    public static let barycentric = CalculationFlags(rawValue: 16384)
    public static let topocentric = CalculationFlags(rawValue: 32768)
    public static let sidereal = CalculationFlags(rawValue: 65536)
    public static let icrs = CalculationFlags(rawValue: 131072)
}

// MARK: - House System
public enum HouseSystem: Int32 {
    case placidus = 80      // 'P'
    case koch = 75          // 'K'
    case porphyrius = 79    // 'O'
    case regiomontanus = 82 // 'R'
    case campanus = 67      // 'C'
    case equal = 69         // 'E'
    case vehlowEqual = 86   // 'V'
    case wholeSign = 87     // 'W'
    case meridian = 88      // 'X'
    case morinus = 77       // 'M'
    case krusinski = 85     // 'U'
    case topcentrum = 84    // 'T'
    case apc = 65           // 'A'
    case solarFire = 68     // 'D'
    case galcentLeo = 70    // 'F'
    case galcentCancer = 71 // 'G'
    case azimuthal = 72     // 'H'
    case polichPage = 73    // 'I'
    case alcabitus = 76     // 'L'
    case zariquel = 90      // 'Z'
    case emporia = 89       // 'Y'
    case arabicBinder = 74  // 'J'
    case savard = 83        // 'S'
    case gaudensius = 78    // 'N'
}

// MARK: - Position Result
public struct Position {
    public let longitude: Double
    public let latitude: Double
    public let distance: Double
    public let longitudeSpeed: Double
    public let latitudeSpeed: Double
    public let distanceSpeed: Double
    
    public init(longitude: Double, latitude: Double, distance: Double,
                longitudeSpeed: Double = 0, latitudeSpeed: Double = 0, distanceSpeed: Double = 0) {
        self.longitude = longitude
        self.latitude = latitude
        self.distance = distance
        self.longitudeSpeed = longitudeSpeed
        self.latitudeSpeed = latitudeSpeed
        self.distanceSpeed = distanceSpeed
    }
}

// MARK: - House Result
public struct HouseResult {
    public let cusps: [Double]
    public let ascendant: Double
    public let midheaven: Double
    
    public init(cusps: [Double], ascendant: Double, midheaven: Double) {
        self.cusps = cusps
        self.ascendant = ascendant
        self.midheaven = midheaven
    }
}

// MARK: - Swiss Ephemeris Wrapper
public class SwissEph {
    
    // MARK: - Properties
    private var isInitialized = false
    
    // MARK: - Initialization
    public init() {
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
        } else {
            print("Setting Swiss Ephemeris path to: \(sePath)")
            // Use withCString to ensure the C string is valid for the duration of the call
            sePath.withCString { cString in
                swe_set_ephe_path(cString)
            }
        }
        
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
        swe_close()
        isInitialized = false
    }
    
    // MARK: - Planet Position Calculation
    public func calculatePlanetPosition(julianDay: Double, planet: Planet, flags: CalculationFlags = [.swissEph]) -> Position? {
        guard isInitialized else {
            print("ERROR: Swiss Ephemeris not initialized")
            return nil
        }
        
        var result = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        
        // Note: Arrays are stack-allocated, automatically cleaned up when function returns
        // The error buffer is zero-initialized and used by the C function
        let returnCode = swe_calc_ut(julianDay, planet.rawValue, flags.rawValue, &result, &error)
        
        guard returnCode >= 0 else {
            let errorMessage = String(cString: error)
            print("Error calculating planet position: \(errorMessage)")
            return nil
        }
        
        return Position(
            longitude: result[0],
            latitude: result[1],
            distance: result[2],
            longitudeSpeed: result[3],
            latitudeSpeed: result[4],
            distanceSpeed: result[5]
        )
    }
    
    // MARK: - House Calculation
    public func calculateHouses(julianDay: Double, latitude: Double, longitude: Double, houseSystem: HouseSystem) -> HouseResult? {
        guard isInitialized else { return nil }
        
        var cusps = [Double](repeating: 0.0, count: 13) // 12 houses + 1 extra
        var ascmc = [Double](repeating: 0.0, count: 10)
        
        // Note: Arrays are stack-allocated, automatically cleaned up when function returns
        let returnCode = swe_houses(julianDay, latitude, longitude, Int32(houseSystem.rawValue), &cusps, &ascmc)
        
        guard returnCode >= 0 else {
            print("Error calculating houses (return code: \(returnCode))")
            return nil
        }
        
        // Extract house cusps (indices 1-12 contain the cusps)
        let houseCusps = Array(cusps[1...12])
        
        return HouseResult(
            cusps: houseCusps,
            ascendant: ascmc[0],
            midheaven: ascmc[1]
        )
    }
    
    // MARK: - Julian Day Conversion
    public func julianDay(year: Int, month: Int, day: Int, hour: Double, gregorian: Bool = true) -> Double {
        let gregflag = gregorian ? 1 : 0
        return swe_julday(Int32(year), Int32(month), Int32(day), hour, Int32(gregflag))
    }
    
    public func dateFromJulianDay(_ julianDay: Double, gregorian: Bool = true) -> (year: Int, month: Int, day: Int, hour: Double) {
        let gregflag = gregorian ? 1 : 0
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hour: Double = 0
        
        swe_revjul(julianDay, Int32(gregflag), &year, &month, &day, &hour)
        
        return (Int(year), Int(month), Int(day), hour)
    }
    
    // MARK: - Sidereal Time
    public func siderealTime(julianDay: Double) -> Double {
        return swe_sidtime(julianDay)
    }
    
    // MARK: - Ayanamsa (Sidereal Zodiac)
    public func ayanamsa(julianDay: Double) -> Double {
        return swe_get_ayanamsa_ut(julianDay)
    }
    
    // MARK: - Version Information
    public func version() -> String {
        print("Calling swe_version...")
        var versionString = [CChar](repeating: 0, count: 256)
        
        // Note: Buffer is stack-allocated, automatically cleaned up
        // swe_version returns a pointer to static memory (no cleanup needed)
        let versionPtr = swe_version(&versionString)
        if let ptr = versionPtr {
            // swe_version returns a pointer to static memory (no need to free)
            // Copy to Swift String immediately to ensure we have the value
            let version = String(cString: ptr)
            print("Version returned: \(version)")
            return version
        } else {
            // Fallback: use the buffer we provided
            let version = versionString.withUnsafeBufferPointer { buffer in
                String(cString: buffer.baseAddress!)
            }
            print("Version returned: \(version)")
            return version
        }
    }
    
    // MARK: - Planet Names
    public func planetName(_ planet: Planet) -> String {
        var name = [CChar](repeating: 0, count: 256)
        
        // Note: Buffer is stack-allocated, automatically cleaned up
        // swe_get_planet_name returns a pointer to static memory (no cleanup needed)
        let namePtr = swe_get_planet_name(planet.rawValue, &name)
        if let ptr = namePtr {
            // swe_get_planet_name returns a pointer to static memory (no need to free)
            // Copy to Swift String immediately to ensure we have the value
            return String(cString: ptr)
        } else {
            // Fallback: use the buffer we provided
            return name.withUnsafeBufferPointer { buffer in
                String(cString: buffer.baseAddress!)
            }
        }
    }
}
