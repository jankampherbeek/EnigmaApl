//
//  HorizontalCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 03/01/2026.
//

public struct HorizontalCalc {

    
    public func calculateHorizontal(seWrapper: SEWrapper
        julianDay: Double,
        equatorialArray: inout [MainAstronomicalPosition],
        horizontalArray: inout [HorizontalPosition],
        pos: MainAstronomicalPosition,
        request: LocationRequest
    ) {
        if !pos.mainPos.isNaN {
            
        }
    }
    // Calculate horizontal position using equatorial coordinates
let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
    julianDay: julianDay,
    rightAscension: pos.mainPos,
    declination: pos.deviation,
    observerLatitude: request.Latitude,
    observerLongitude: request.Longitude,
    height: 0.0  // Using sea level
)
horizontalArray = [HorizontalPosition(azimuth: azimuth, altitude: altitude)]
} else {
// If calculation failed, use zero values
equatorialArray = [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)]
horizontalArray = [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
}
}


/*
 let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
     julianDay: julianDay,
     rightAscension: pos.mainPos,
     declination: pos.deviation,
     observerLatitude: request.Latitude,
     observerLongitude: request.Longitude,
     height: 0.0  // Using sea level
 )
 horizontalArray = [HorizontalPosition(azimuth: azimuth, altitude: altitude)]
} else {

 */
