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
