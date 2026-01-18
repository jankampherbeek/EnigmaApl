//
//  FormulaFullCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/01/2026.
//

import Foundation

// MARK: - Formula Full Calculator

/// Calculate full positions for factors that require full coordinate system calculations
/// (South Node, Priapus, Dragon, Beast)
public struct FormulaFullCalc {

    
    /// Calculate full positions for factors that require full coordinate system calculations
    /// - Parameters:
    ///   - seRequest: The SERequest containing calculation parameters
    ///   - configData: The ConfigData containing preferences (node type, apogee type, etc.)
    ///   - obliquity: The obliquity value needed for coordinate conversions
    /// - Returns: A dictionary of factor positions
    public func CalculateFormulaFullFactors(seWrapper: SEWrapper, seRequest: SERequest, obliquity: Double) -> [Factors: FullFactorPosition] {
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = seRequest.JulianDay
        let julianDayPrevious = julianDay - 0.5
        let julianDayNext = julianDay + 0.5
        let flagsEcliptical = 258  // SEFLG_SWIEPH (2) + SEFLG_SPEED (256)
        let flagsEquatorial = 258 + 2048  // Add equatorial flag (2048)
        let configData = seRequest.ConfigData
        
        for factor in seRequest.FactorsToUse {
            switch factor {
            case .southNode:
                // Calculate South Node from North Node or True Node
                // Use seId 10 for mean node, 11 for true node
                let nodeSeId = configData.lunarNodeType == .trueNode ? 11 : 10
                
                guard let nodePos = calculateFullPositionForSePointWithId(
                    seWrapper: seWrapper,
                    seId: nodeSeId,
                    julianDay: julianDay,
                    latitude: seRequest.Latitude,
                    longitude: seRequest.Longitude,
                    flagsEcliptical: flagsEcliptical,
                    flagsEquatorial: flagsEquatorial
                ) else {
                    continue
                }
                
                // Calculate South Node positions (opposite of North Node)
                let nodeDistancePos = nodePos.ecliptical.first?.distance ?? 0.0
                let nodeDistanceSpeed = nodePos.ecliptical.first?.distanceSpeed ?? 0.0
                
                var nodeLongPos = (nodePos.ecliptical.first?.mainPos ?? 0.0) + 180.0
                if nodeLongPos >= 360.0 { nodeLongPos -= 360.0 }
                let nodeLongSpeed = nodePos.ecliptical.first?.mainPosSpeed ?? 0.0
                
                let eclLongPosSpeed = MainAstronomicalPosition(
                    mainPos: nodeLongPos,
                    deviation: 0.0,
                    distance: nodeDistancePos,
                    mainPosSpeed: nodeLongSpeed,
                    deviationSpeed: 0.0,
                    distanceSpeed: nodeDistanceSpeed
                )
                
                var nodeRaPos = (nodePos.equatorial.first?.mainPos ?? 0.0) + 180.0
                if nodeRaPos >= 360.0 { nodeRaPos -= 360.0 }
                let nodeRaSpeed = nodePos.equatorial.first?.mainPosSpeed ?? 0.0
                let nodeDeclPos = -(nodePos.equatorial.first?.deviation ?? 0.0)
                let nodeDeclSpeed = nodePos.equatorial.first?.deviationSpeed ?? 0.0
                
                let raPosSpeed = MainAstronomicalPosition(
                    mainPos: nodeRaPos,
                    deviation: nodeDeclPos,
                    distance: nodeDistancePos,
                    mainPosSpeed: nodeRaSpeed,
                    deviationSpeed: nodeDeclSpeed,
                    distanceSpeed: nodeDistanceSpeed
                )
                
                var nodeAzimuth = (nodePos.horizontal.first?.azimuth ?? 0.0) + 180.0
                if nodeAzimuth >= 360.0 { nodeAzimuth -= 360.0 }
                let nodeAltitude = -(nodePos.horizontal.first?.altitude ?? 0.0)
                
                let azimPosSpeed = HorizontalPosition(azimuth: nodeAzimuth, altitude: nodeAltitude)
                
                let southNodeFpPos = FullFactorPosition(
                    ecliptical: [eclLongPosSpeed],
                    equatorial: [raPosSpeed],
                    horizontal: [azimPosSpeed]
                )
                coordinates[factor] = southNodeFpPos
                
            case .priapus, .priapusCorrected:
                // Calculate Priapus from apogee (opposite of apogee)
                let apogeeFactor: Factors
                if factor == .priapus {
                    apogeeFactor = .apogeeMean
                } else {
                    // Use apogee type from config
                    switch configData.blackMoonCorrectionType {
                    case .duval, .swisseph:
                        apogeeFactor = .apogeeCorrected
                    case .interpolated:
                        apogeeFactor = .apogeeInterpolated
                    }
                }
                
                var fullPointPosApogee: FullFactorPosition?
                
                // If using Duval correction, calculate via formula
                if apogeeFactor == .apogeeCorrected && configData.blackMoonCorrectionType == .duval {
                    let apogeeCalc = ApogeeDuvalCalc(seWrapper: seWrapper)
                    let longitude = apogeeCalc.calcApogeeDuval(julianDay: julianDay)
                    let longitudePrevious = apogeeCalc.calcApogeeDuval(julianDay: julianDayPrevious)
                    let longitudeNext = apogeeCalc.calcApogeeDuval(julianDay: julianDayNext)
                    let longitudeSpeed = longitudeNext - longitudePrevious
                    let zeroPos = MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)
                    let zeroHor = HorizontalPosition(azimuth: 0.0, altitude: 0.0)
                    fullPointPosApogee = FullFactorPosition(
                        ecliptical: [MainAstronomicalPosition(mainPos: longitude, deviation: 0.0, distance: 0.0, mainPosSpeed: longitudeSpeed, deviationSpeed: 0.0, distanceSpeed: 0.0)],
                        equatorial: [zeroPos],
                        horizontal: [zeroHor]
                    )
                } else {
                    fullPointPosApogee = calculateFullPositionForSePoint(
                        seWrapper: SEWrapper(),
                        factor: apogeeFactor,
                        julianDay: julianDay,
                        latitude: seRequest.Latitude,
                        longitude: seRequest.Longitude,
                        flagsEcliptical: flagsEcliptical,
                        flagsEquatorial: flagsEquatorial
                    )
                }
                
                guard let apogeePos = fullPointPosApogee else {
                    continue
                }
                
                // Calculate Priapus positions (opposite of apogee)
                var eclLong = (apogeePos.ecliptical.first?.mainPos ?? 0.0) + 180.0
                if eclLong >= 360.0 { eclLong -= 360.0 }
                
                let eclipticPositions = MainAstronomicalPosition(
                    mainPos: eclLong,
                    deviation: -(apogeePos.ecliptical.first?.deviation ?? 0.0),
                    distance: 0.0,
                    mainPosSpeed: apogeePos.ecliptical.first?.mainPosSpeed ?? 0.0,
                    deviationSpeed: apogeePos.ecliptical.first?.deviationSpeed ?? 0.0,
                    distanceSpeed: 0.0
                )
                
                var ra = (apogeePos.equatorial.first?.mainPos ?? 0.0) + 180.0
                if ra >= 360.0 { ra -= 360.0 }
                
                let equatorialPositions = MainAstronomicalPosition(
                    mainPos: ra,
                    deviation: -(apogeePos.equatorial.first?.deviation ?? 0.0),
                    distance: 0.0,
                    mainPosSpeed: apogeePos.equatorial.first?.mainPosSpeed ?? 0.0,
                    deviationSpeed: apogeePos.equatorial.first?.deviationSpeed ?? 0.0,
                    distanceSpeed: 0.0
                )
                
                var azimuth = (apogeePos.horizontal.first?.azimuth ?? 0.0) + 180.0
                if azimuth >= 360.0 { azimuth -= 360.0 }
                
                let horizontalPositions = HorizontalPosition(
                    azimuth: azimuth,
                    altitude: -(apogeePos.horizontal.first?.altitude ?? 0.0)
                )
                
                let priapusFullPos = FullFactorPosition(
                    ecliptical: [eclipticPositions],
                    equatorial: [equatorialPositions],
                    horizontal: [horizontalPositions]
                )
                coordinates[factor] = priapusFullPos
                
            case .dragon, .beast:
                // Calculate Dragon/Beast from node with 90/-90 degree offset and inclination for ra etc.
                // Use seId 10 for mean node, 11 for true node
                let nodeSeId = configData.lunarNodeType == .trueNode ? 11 : 10
                
                guard let fullPointPosNode = calculateFullPositionForSePointWithId(
                    seWrapper: SEWrapper(),
                    seId: nodeSeId,
                    julianDay: julianDay,
                    latitude: seRequest.Latitude,
                    longitude: seRequest.Longitude,
                    flagsEcliptical: flagsEcliptical,
                    flagsEquatorial: flagsEquatorial
                ) else {
                    continue
                }
                let lunarOrbDistance = fullPointPosNode.ecliptical.first?.distance ?? 0.0
                let eclLongNode = fullPointPosNode.ecliptical.first?.mainPos ?? 0.0
                let longSpeedNode = fullPointPosNode.ecliptical.first?.mainPosSpeed ?? 0.0
                
                
                let seIdMoon = Factors.moon.seId
                guard let orbitalElements = seWrapper.calcOrbitalElements(julianDay: julianDay, planet: seIdMoon, flags: flagsEcliptical) else {
                    continue
                }
                guard let orbitalElementsPrevious = seWrapper.calcOrbitalElements(julianDay: julianDayPrevious, planet: seIdMoon, flags: flagsEcliptical) else {
                    continue
                }
                guard let orbitalElementsNext = seWrapper.calcOrbitalElements(julianDay: julianDayNext, planet: seIdMoon, flags: flagsEcliptical) else {
                    continue
                }

                let inclination = orbitalElements.inclination
                let inclinationPrevious = orbitalElementsPrevious.inclination
                let inclinationNext = orbitalElementsNext.inclination
                let latitudeSpeed = inclinationNext - inclinationPrevious
                
                let deltaNode = factor == .dragon ? 90.0 : -90.0
                let latitude = factor == .dragon ? inclination : -inclination
                var longitude = eclLongNode + deltaNode
                if longitude >= 360.0 { longitude -= 360.0 }
                if longitude < 0.0 { longitude += 360.0 }
  
                let previousLong = eclLongNode - (longSpeedNode / 2.0)
                let nextLong = eclLongNode + (longSpeedNode / 2.0)
                let previousLat = latitude - (latitudeSpeed / 2.0)
                let nextLat = latitude + (latitudeSpeed / 2.0)
                
                
                let (rightAscension, declination) = seWrapper.eclipticToEquatorial(
                    eclipticCoordinates: [eclLongNode, latitude],
                    obliquity: obliquity)
                let (previousRightAscension, previousDeclination) = seWrapper.eclipticToEquatorial(
                    eclipticCoordinates: [previousLong, previousLat],
                    obliquity: obliquity)
                let (nextRightAscension, nextDeclination) = seWrapper.eclipticToEquatorial(
                    eclipticCoordinates: [nextLong, nextLat],
                    obliquity: obliquity)
                let raSpeed = nextRightAscension - previousRightAscension
                let declinationSpeed = nextDeclination - previousDeclination
                
                
                let distanceSpeed = fullPointPosNode.ecliptical.first!.distanceSpeed
                
                let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
                           julianDay: julianDay,
                           rightAscension: rightAscension,
                           declination: declination,
                           observerLatitude: seRequest.Latitude,
                           observerLongitude: seRequest.Longitude,
                           height: 0.0
                       )

                let eclipticalPos = MainAstronomicalPosition(mainPos: longitude, deviation: latitude, distance: lunarOrbDistance, mainPosSpeed: longSpeedNode, deviationSpeed: latitudeSpeed, distanceSpeed: distanceSpeed )
                let equatorialPos = MainAstronomicalPosition(mainPos: rightAscension, deviation: declination, distance: lunarOrbDistance, mainPosSpeed: raSpeed, deviationSpeed: declinationSpeed, distanceSpeed: distanceSpeed)
                let horizontalPos = HorizontalPosition(azimuth: azimuth, altitude: altitude)
                let fullPointPos = FullFactorPosition(ecliptical: [eclipticalPos], equatorial: [equatorialPos], horizontal: [horizontalPos])
                
                coordinates[factor] = fullPointPos
                
            default:
                Logger.log.error("Unsupported factor \(factor) in CalculateFormulaFullFactors")
                break
            }
        }
        
        return coordinates
    }
    
    // MARK: - Private Helper Methods
    
    /// Calculate full position for a Swiss Ephemeris point
    /// - Parameters:
    ///   - factor: The factor to calculate
    ///   - julianDay: Julian day for UT
    ///   - latitude: Observer latitude
    ///   - longitude: Observer longitude
    ///   - flagsEcliptical: Flags for ecliptical calculation
    ///   - flagsEquatorial: Flags for equatorial calculation
    /// - Returns: FullFactorPosition if calculation succeeds, nil otherwise
    private func calculateFullPositionForSePoint(
        seWrapper: SEWrapper,
        factor: Factors,
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        flagsEcliptical: Int,
        flagsEquatorial: Int
    ) -> FullFactorPosition? {
        let factorId = factor.seId
        return calculateFullPositionForSePointWithId(
            seWrapper: seWrapper,
            seId: factorId,
            julianDay: julianDay,
            latitude: latitude,
            longitude: longitude,
            flagsEcliptical: flagsEcliptical,
            flagsEquatorial: flagsEquatorial
        )
    }
    
    /// Calculate full position for a Swiss Ephemeris point by seId
    /// - Parameters:
    ///   - seId: The Swiss Ephemeris planet ID
    ///   - julianDay: Julian day for UT
    ///   - latitude: Observer latitude
    ///   - longitude: Observer longitude
    ///   - flagsEcliptical: Flags for ecliptical calculation
    ///   - flagsEquatorial: Flags for equatorial calculation
    /// - Returns: FullFactorPosition if calculation succeeds, nil otherwise
    private func calculateFullPositionForSePointWithId(
        seWrapper: SEWrapper,
        seId: Int,
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        flagsEcliptical: Int,
        flagsEquatorial: Int
    ) -> FullFactorPosition? {
        // Calculate ecliptical position
        guard let eclipticalPos = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: seId,
            flags: flagsEcliptical
        ) else {
            return nil
        }
        
        // Calculate equatorial position
        guard let equatorialPos = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: seId,
            flags: flagsEquatorial
        ) else {
            return nil
        }
        
        // Calculate horizontal position using equatorial coordinates
        let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
            julianDay: julianDay,
            rightAscension: equatorialPos.mainPos,
            declination: equatorialPos.deviation,
            observerLatitude: latitude,
            observerLongitude: longitude,
            height: 0.0
        )
        
        let horizontalPos = HorizontalPosition(azimuth: azimuth, altitude: altitude)
        
        return FullFactorPosition(
            ecliptical: [eclipticalPos],
            equatorial: [equatorialPos],
            horizontal: [horizontalPos]
        )
    }
    

}
