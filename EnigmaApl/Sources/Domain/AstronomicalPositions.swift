//
//  AstronomicalPositions.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/12/2025.
//

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
