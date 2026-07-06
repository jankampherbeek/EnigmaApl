// AstronCalcDomain.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

// MARK: - Position Result
/// A fully defined astronomical position for a specific coordinate. Includes poisitions and speeds.
/// mainPos is the main position: longitude or right ascension
/// deviation is the deviation from the main plane: lartitude or declination
/// distance is the distance in Astronomical Units (AU)
/// the postfix 'Speed' gives the speed for the item with the same name
public struct MainAstronomicalPosition {
    public let mainPos: Double
    public let deviation: Double
    public let distance: Double
    public let mainPosSpeed: Double
    public let deviationSpeed: Double
    public let distanceSpeed: Double
    
    public init(mainPos: Double, deviation: Double, distance: Double,
                mainPosSpeed: Double = 0, deviationSpeed: Double = 0, distanceSpeed: Double = 0) {
        self.mainPos = mainPos
        self.deviation = deviation
        self.distance = distance
        self.mainPosSpeed = mainPosSpeed
        self.deviationSpeed = deviationSpeed
        self.distanceSpeed = distanceSpeed
    }
}

// MARK: Horizontal position
/// The position at the horizontal plane
/// Azimuth: the position at the horizon, it  starts at the South and runs through west, north and east, in that sequence
/// Altitude: the height above or under the horizon
public struct HorizontalPosition {
    public let azimuth: Double
    public let altitude: Double
    
    public init(azimuth: Double, altitude: Double) {
        self.azimuth = azimuth
        self.altitude = altitude
    }
}

// MARK: Full cusp position
/// The position of a cusp
public struct FullCuspPosition {
    public let longitude: Double
    public let rightAscension: Double
    public let declination: Double
    public let horizontal: HorizontalPosition
}

// MARK: - Position result for all coordinates
/// Combined positions for all coordinates
public struct FullFactorPosition {
    public let ecliptical: [MainAstronomicalPosition]
    public let equatorial: [MainAstronomicalPosition]
    public let horizontal: [HorizontalPosition]
    
    public init(ecliptical: [MainAstronomicalPosition], equatorial: [MainAstronomicalPosition], horizontal: [HorizontalPosition]) {
        self.ecliptical = ecliptical
        self.equatorial = equatorial
        self.horizontal = horizontal
    }
}



// MARK: - House positions
/// Combined positions for all mundane points
public struct HousePositions {
    public let cusps: [FullCuspPosition]
    public let ascendant: FullCuspPosition
    public let midheaven: FullCuspPosition
    public let eastpoint: FullCuspPosition
    public let vertex: FullCuspPosition
    
    public init(cusps: [FullCuspPosition], ascendant: FullCuspPosition, midheaven: FullCuspPosition, eastpoint: FullCuspPosition, vertex: FullCuspPosition) {
        self.cusps = cusps
        self.ascendant = ascendant
        self.midheaven = midheaven
        self.eastpoint = eastpoint
        self.vertex = vertex
    }
}

// MARK: - Orbital Elements
/// Orbital elements of a celestial body
/// All angles are in degrees, distances in AU
public struct OrbitalElements {
    /// Semi-major axis (a) in AU
    public let semiMajorAxis: Double
    /// Eccentricity (e)
    public let eccentricity: Double
    /// Inclination (i) in degrees
    public let inclination: Double
    /// Argument of perihelion (ω) in degrees
    public let argumentOfPerihelion: Double
    /// Ascending node (Ω) in degrees
    public let ascendingNode: Double
    /// Mean anomaly (M) in degrees
    public let meanAnomaly: Double
    /// True anomaly (v) in degrees
    public let trueAnomaly: Double
    /// Eccentric anomaly (E) in degrees
    public let eccentricAnomaly: Double
    /// Mean longitude (L) in degrees
    public let meanLongitude: Double
    /// True longitude (L') in degrees
    public let trueLongitude: Double
    /// Distance (r) in AU
    public let distance: Double
    /// Speed (v) in AU/day
    public let speed: Double
    
    public init(
        semiMajorAxis: Double,
        eccentricity: Double,
        inclination: Double,
        argumentOfPerihelion: Double,
        ascendingNode: Double,
        meanAnomaly: Double,
        trueAnomaly: Double,
        eccentricAnomaly: Double,
        meanLongitude: Double,
        trueLongitude: Double,
        distance: Double,
        speed: Double
    ) {
        self.semiMajorAxis = semiMajorAxis
        self.eccentricity = eccentricity
        self.inclination = inclination
        self.argumentOfPerihelion = argumentOfPerihelion
        self.ascendingNode = ascendingNode
        self.meanAnomaly = meanAnomaly
        self.trueAnomaly = trueAnomaly
        self.eccentricAnomaly = eccentricAnomaly
        self.meanLongitude = meanLongitude
        self.trueLongitude = trueLongitude
        self.distance = distance
        self.speed = speed
    }
}

// MARK: - Apsides Result
/// Result of apsides calculation containing nodes and apsides positions
/// Each position contains [longitude, latitude, distance]
public struct ApsidesResult {
    /// Ascending node position [longitude, latitude, distance]
    public let ascendingNode: [Double]
    /// Descending node position [longitude, latitude, distance]
    public let descendingNode: [Double]
    /// Perihelion (for planets) or Perigee (for Moon) position [longitude, latitude, distance]
    public let perihelion: [Double]
    /// Aphelion (for planets) or Apogee (for Moon) position [longitude, latitude, distance]
    public let aphelion: [Double]
    
    public init(ascendingNode: [Double], descendingNode: [Double], perihelion: [Double], aphelion: [Double]) {
        self.ascendingNode = ascendingNode
        self.descendingNode = descendingNode
        self.perihelion = perihelion
        self.aphelion = aphelion
    }
}




// MARK: - Solar Eclipse Local Result
/// Result of a local solar eclipse search via swe_sol_eclipse_when_loc
public struct SolarEclipseLocalResult {
    /// True if the eclipse type is total (SE_ECL_TOTAL)
    public let isTotal: Bool
    /// True if the eclipse type is annular (SE_ECL_ANNULAR)
    public let isAnnular: Bool
    /// True if the eclipse type is partial (SE_ECL_PARTIAL)
    public let isPartial: Bool
    /// True if the eclipse is visible at the given location (SE_ECL_VISIBLE)
    public let isVisible: Bool
    /// Julian Day (UT) of maximum eclipse (tret[0])
    public let maxEclipseJD: Double
    /// Fraction of solar disc covered by the Moon (obscuration, attr[2])
    public let obscuration: Double
    /// Saros series number (attr[9]; -99999999 if not available)
    public let sarosNumber: Double
    /// Saros series member number (attr[10]; -99999999 if not available)
    public let sarosMemberNumber: Double

    public init(isTotal: Bool, isAnnular: Bool, isPartial: Bool, isVisible: Bool,
                maxEclipseJD: Double, obscuration: Double,
                sarosNumber: Double, sarosMemberNumber: Double) {
        self.isTotal = isTotal
        self.isAnnular = isAnnular
        self.isPartial = isPartial
        self.isVisible = isVisible
        self.maxEclipseJD = maxEclipseJD
        self.obscuration = obscuration
        self.sarosNumber = sarosNumber
        self.sarosMemberNumber = sarosMemberNumber
    }
}

// MARK: - Lunar Eclipse Local Result
/// Result of a local lunar eclipse search via swe_lun_eclipse_when_loc
public struct LunarEclipseLocalResult {
    /// True if the eclipse type is total (SE_ECL_TOTAL)
    public let isTotal: Bool
    /// True if the eclipse type is penumbral (SE_ECL_PENUMBRAL)
    public let isPenumbral: Bool
    /// True if the eclipse type is partial (SE_ECL_PARTIAL)
    public let isPartial: Bool
    /// Julian Day (UT) of maximum eclipse (tret[0])
    public let maxEclipseJD: Double
    /// True altitude of the Moon above the horizon at maximum eclipse in degrees (attr[5])
    public let trueAltitude: Double
    /// Saros series number (attr[9]; -99999999 if not available)
    public let sarosNumber: Double
    /// Saros series member number (attr[10]; -99999999 if not available)
    public let sarosMemberNumber: Double

    public init(isTotal: Bool, isPenumbral: Bool, isPartial: Bool,
                maxEclipseJD: Double, trueAltitude: Double,
                sarosNumber: Double, sarosMemberNumber: Double) {
        self.isTotal = isTotal
        self.isPenumbral = isPenumbral
        self.isPartial = isPartial
        self.maxEclipseJD = maxEclipseJD
        self.trueAltitude = trueAltitude
        self.sarosNumber = sarosNumber
        self.sarosMemberNumber = sarosMemberNumber
    }
}

// MARK: - Solar Eclipse Global Result
/// Result of a global solar eclipse search via swe_sol_eclipse_when_glob
public struct SolarEclipseGlobalResult {
    public let isTotal: Bool
    public let isAnnular: Bool
    public let isPartial: Bool
    /// Julian Day (UT) of maximum eclipse (tret[0])
    public let maxJD: Double

    public init(isTotal: Bool, isAnnular: Bool, isPartial: Bool, maxJD: Double) {
        self.isTotal = isTotal
        self.isAnnular = isAnnular
        self.isPartial = isPartial
        self.maxJD = maxJD
    }
}

// MARK: - Lunar Eclipse Global Result
/// Result of a global lunar eclipse search via swe_lun_eclipse_when
public struct LunarEclipseGlobalResult {
    public let isTotal: Bool
    public let isPenumbral: Bool
    public let isPartial: Bool
    /// Julian Day (UT) of maximum eclipse (tret[0])
    public let maxJD: Double

    public init(isTotal: Bool, isPenumbral: Bool, isPartial: Bool, maxJD: Double) {
        self.isTotal = isTotal
        self.isPenumbral = isPenumbral
        self.isPartial = isPartial
        self.maxJD = maxJD
    }
}

// MARK: - Next Solar / Lunar Eclipse Result (global + longitude)
/// Combines a global eclipse search result with the ecliptic longitude of the Sun/Moon at maximum.

public struct NextSolarEclipseResult {
    public let isTotal: Bool
    public let isAnnular: Bool
    public let isPartial: Bool
    public let maxJD: Double
    public let longitude: Double

    public init(isTotal: Bool, isAnnular: Bool, isPartial: Bool, maxJD: Double, longitude: Double) {
        self.isTotal = isTotal; self.isAnnular = isAnnular; self.isPartial = isPartial
        self.maxJD = maxJD; self.longitude = longitude
    }
}

public struct NextLunarEclipseResult {
    public let isTotal: Bool
    public let isPenumbral: Bool
    public let isPartial: Bool
    public let maxJD: Double
    public let longitude: Double

    public init(isTotal: Bool, isPenumbral: Bool, isPartial: Bool, maxJD: Double, longitude: Double) {
        self.isTotal = isTotal; self.isPenumbral = isPenumbral; self.isPartial = isPartial
        self.maxJD = maxJD; self.longitude = longitude
    }
}

// MARK: - Named Ecliptic Coordinates

/// Represents a named celestial point with its ecliptic coordinates
public struct NamedEclipticCoordinates {
    public let factor: Factors
    public let longitude: Double
    public let latitude: Double
    
    public init(factor: Factors, longitude: Double, latitude: Double) {
        self.factor = factor
        self.longitude = longitude
        self.latitude = latitude
    }
}


// MARK: - Named Ecliptic Longitude

/// Represents a named celestial point with its oblique longitude
public struct NamedEclipticLongitude {
    public let factor: Factors
    public let obliqueLongitude: Double
    
    public init(factor: Factors, obliqueLongitude: Double) {
        self.factor = factor
        self.obliqueLongitude = obliqueLongitude
    }
}

