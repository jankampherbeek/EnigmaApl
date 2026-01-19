//
//  ObliqueLongitudeCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/01/2026.
//

import Foundation

// MARK: - Oblique Longitude Calculator

/// Calculate oblique longitudes for celestial points
/// Oblique longitude is a correction for the mundane position, also called 'true location',
/// as used by the School of Ram
public struct ObliqueLongitudeCalc {
    
    /// Calculate oblique longitudes for factors
    /// - Parameters:
    ///   - armc: Right Ascension of the Midheaven (ARMC) in degrees
    ///   - obliquity: Obliquity of the ecliptic in degrees
    ///   - geoLat: Geographic latitude in degrees
    ///   - celPointCoordinates: List of named ecliptic coordinates to calculate oblique longitudes for
    ///   - ayanamshaOffset: Ayanamsha offset in degrees
    /// - Returns: Array of named ecliptic longitudes with their oblique longitude values
    public func ObliqueLongitudeForFactor(
        armc: Double,
        obliquity: Double,
        geoLat: Double,
        factorCoordinates: [NamedEclipticCoordinates],
        ayanamshaOffset: Double) -> [NamedEclipticLongitude] {
        var results: [NamedEclipticLongitude] = []
        
        // Calculate the south point
        let southPoint = CalculateSouthPoint(armc: armc, obliquity: obliquity, geoLat: geoLat)

        for coord in factorCoordinates {
            let eclLong = coord.longitude
            let eclLat = coord.latitude
            
            let obliqueLongitude = OblLongForCelPoint(eclLong: eclLong, eclLat: eclLat, southPointLong: southPoint.0, southPointLat: southPoint.1, ayanamshaOffset: ayanamshaOffset)
            
            // Apply ayanamsha offset and normalize to 0-360
            let adjustedLongitude = RangeUtil.valueToRange(
                obliqueLongitude + ayanamshaOffset,
                lowerLimit: 0.0,
                upperLimit: 360.0
            )
            
            results.append(NamedEclipticLongitude(
                factor: coord.factor,
                obliqueLongitude: adjustedLongitude
            ))
        }
        
        return results
    }
    
    // MARK: - Private Helper Methods
    
    /// Calculate the south point (also known as the anti-culminating point)
    /// - Parameters:
    ///   - armc: Right Ascension of the Midheaven in degrees
    ///   - obliquity: Obliquity of the ecliptic in degrees
    ///   - geoLat: Geographic latitude in degrees
    /// - Returns: The south point longitude in degrees
    private func CalculateSouthPoint(armc: Double, obliquity: Double, geoLat: Double) -> (Double, Double) {

        var declSp = -(90.0 - geoLat);
        var arsp = armc;
        if (geoLat < 0.0)
        {
            arsp = RangeUtil.valueToRange(armc + 180.0, lowerLimit: 0.0, upperLimit: 360.0)
            declSp = -90.0 - geoLat;
        }
        
        let sinSp = sin(MathExtra.degToRad(arsp))
        let cosEps = cos(MathExtra.degToRad(obliquity))
        let tanDecl = tan(MathExtra.degToRad(declSp))
        let sinEps = sin(MathExtra.degToRad(obliquity))
        let cosArsp = cos(MathExtra.degToRad(arsp))
        let sinDecl = sin(MathExtra.degToRad(declSp))
        let cosDecl = cos(MathExtra.degToRad(declSp))
        let longSp = RangeUtil.valueToRange(MathExtra.radToDeg(atan2((sinSp * cosEps) + (tanDecl * sinEps), cosArsp)), lowerLimit: 0.0, upperLimit: 360.0);
        let latSp = MathExtra.radToDeg(asin((sinDecl * cosEps) - (cosDecl * sinEps * sinSp)))
        return (longSp, latSp);
    }
    
    private func OblLongForCelPoint(eclLong: Double, eclLat: Double, southPointLong: Double, southPointLat: Double, ayanamshaOffset: Double) -> Double
    {
        let absLatSp = abs(southPointLat)
        let longSp = southPointLong
        let longPl = eclLong + ayanamshaOffset
        let latPl = eclLat
        let longSouthPMinusPlanet = abs(longSp - longPl)
        let longPlanetMinusSouthP = abs(longPl - longSp)
        let latSouthPMinusPlanet = absLatSp - latPl
        let latSouthPPlusPlanet = absLatSp + latPl
        let s = min(longSouthPMinusPlanet, longPlanetMinusSouthP) / 2.0
        let tanSRad = tan(MathExtra.degToRad(s))
        let qRad = sin(MathExtra.degToRad(latSouthPMinusPlanet)) / sin(MathExtra.degToRad(latSouthPPlusPlanet))
        let v = MathExtra.radToDeg(atan(tanSRad * qRad)) - s
        var absoluteV = RangeUtil.valueToRange(abs(v), lowerLimit: -90.0, upperLimit: 90.0)
        absoluteV = abs(absoluteV)
        var correctedV: Double
        if (IsRising(longSp: longSp, longPl: longPl))
        {
            correctedV = latPl < 0.0 ? absoluteV : -absoluteV;
        }
        else
        {
            correctedV = latPl > 0.0 ? absoluteV : -absoluteV;
        }
        return RangeUtil.valueToRange(longPl + correctedV, lowerLimit: 0.0, upperLimit: 360.0);
    }


    private func IsRising(longSp: Double, longPl: Double) -> Bool
    {
        var diff = longPl - longSp
        if (diff < 0.0) { diff += 360.0 }
        if (diff >= 360.0) { diff -= 360.0 }
        return diff < 180.0
    }
    
}
