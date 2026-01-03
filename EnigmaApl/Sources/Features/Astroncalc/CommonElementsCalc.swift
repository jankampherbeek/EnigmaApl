//
//  CommonElementsCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 03/01/2026.
//

import Foundation

// MARK: - Data Structures

/// Representation of rectangular coordinates
struct RectAngCoordinates {
    let xCoord: Double
    let yCoord: Double
    let zCoord: Double
}

/// Representation of polar coordinates
struct PolarCoordinates {
    let phiCoord: Double
    let thetaCoord: Double
    let rCoord: Double
}

/// Data for an orbit-definition.
struct OrbitDefinition {
    let meanAnomaly: [Double]
    let eccentricity: [Double]
    let semiMajorAxis: Double
    let argumentPerihelion: [Double]
    let ascendingNode: [Double]
    let inclination: [Double]
}


// MARK: - Heliocentric Position Calculator

/// Calculate heliocentric rectangular positions for celestial points
struct CalcHelioPos {
    private var meanAnomaly2: Double = 0
    private var semiAxis: Double = 0
    private var inclination: Double = 0
    private var eccentricity: Double = 0
    private var eccAnomaly: Double = 0
    private var factorT: Double = 0
    
    /// Calculate ecliptic position using orbital elements
    mutating func calcEclipticPosition(factorT: Double, orbitDefinition: OrbitDefinition) -> RectAngCoordinates {
        self.factorT = factorT
        
        var meanAnomaly1 = MathExtra.degToRad(processTermsForFractionT(factorT, orbitDefinition.meanAnomaly))
        if meanAnomaly1 < 0.0 { meanAnomaly1 += 2 * .pi }
        
        eccentricity = processTermsForFractionT(factorT, orbitDefinition.eccentricity)
        eccAnomaly = eccAnomalyFromKeplerEquation(meanAnomaly1, eccentricity)
        
        let trueAnomalyPol = calcPolarTrueAnomaly(orbitDefinition)
        reduceToEcliptic(trueAnomalyPol, orbitDefinition)
        
        return calcRectAngHelioCoordinates(
            semiAxis: semiAxis,
            inclination: inclination,
            eccAnomaly: eccAnomaly,
            eccentricity: eccentricity,
            meanAnomaly: meanAnomaly2,
            orbitDefinition: orbitDefinition
        )
    }
    
    private func eccAnomalyFromKeplerEquation(_ meanAnomaly: Double, _ eccentricity: Double) -> Double {
        var eccAnomaly = meanAnomaly
        for _ in 1..<6 {
            eccAnomaly = meanAnomaly + (eccentricity * sin(eccAnomaly))
        }
        return eccAnomaly
    }
    
    private func calcPolarTrueAnomaly(_ orbitDefinition: OrbitDefinition) -> PolarCoordinates {
        let xCoord = orbitDefinition.semiMajorAxis * (cos(eccAnomaly) - eccentricity)
        let yCoord = orbitDefinition.semiMajorAxis * sin(eccAnomaly) * Foundation.sqrt(1 - (eccentricity * eccentricity))
        let zCoord = 0.0
        let anomalyVec = RectAngCoordinates(xCoord: xCoord, yCoord: yCoord, zCoord: zCoord)
        return MathExtra.rectangular2Polar(anomalyVec)
    }
    
    private mutating func reduceToEcliptic(_ trueAnomalyPol: PolarCoordinates, _ orbitDefinition: OrbitDefinition) {
        semiAxis = MathExtra.radToDeg(trueAnomalyPol.phiCoord) + processTermsForFractionT(factorT, orbitDefinition.argumentPerihelion)
        meanAnomaly2 = MathExtra.degToRad(processTermsForFractionT(factorT, orbitDefinition.ascendingNode))
        
        var factorVDeg = semiAxis + MathExtra.radToDeg(meanAnomaly2)
        if factorVDeg < 0.0 { factorVDeg += 360.0 }
        let factorVRad = MathExtra.degToRad(factorVDeg)
        
        inclination = MathExtra.degToRad(processTermsForFractionT(factorT, orbitDefinition.inclination))
        semiAxis = atan(cos(inclination) * tan(factorVRad - meanAnomaly2))
        if semiAxis < .pi { semiAxis += .pi }
        semiAxis = MathExtra.radToDeg(semiAxis + meanAnomaly2)
        if abs(factorVDeg - semiAxis) > 10.0 { semiAxis -= 180.0 }
    }
    
    private func calcRectAngHelioCoordinates(
        semiAxis: Double,
        inclination: Double,
        eccAnomaly: Double,
        eccentricity: Double,
        meanAnomaly: Double,
        orbitDefinition: OrbitDefinition
    ) -> RectAngCoordinates {
        var phiCoord = MathExtra.degToRad(semiAxis)
        if phiCoord < 0.0 { phiCoord += 2 * .pi }
        let thetaCoord = atan(sin(phiCoord - meanAnomaly) * tan(inclination))
        let rCoord = MathExtra.degToRad(orbitDefinition.semiMajorAxis) * (1 - (eccentricity * cos(eccAnomaly)))
        let helioPol = PolarCoordinates(phiCoord: phiCoord, thetaCoord: thetaCoord, rCoord: rCoord)
        return MathExtra.polar2Rectangular(helioPol)
    }
    
    private func processTermsForFractionT(_ fractionT: Double, _ elements: [Double]) -> Double {
        return elements[0] + (elements[1] * fractionT) + (elements[2] * fractionT * fractionT)
    }
}

// MARK: - Common Elements Calculator

public struct CommonElementsCalc {
    
    public static func calculateCommonElementsFactors(
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        let seWrapper = SEWrapper()
        let julianDay = request.JulianDay
        
        // Calculate obliquity (needed for coordinate conversion)
        let eclipticalFlags = 258  // SEFLG_SWIEPH (2) + SEFLG_SPEED (256)
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: -1,
            flags: eclipticalFlags
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        // Determine observer position from flags
        let observerPosition = extractObserverPosition(from: request.SEFlags)
        
        var coordinates: [Factors: FullFactorPosition] = [:]
        var calcHelioPos = CalcHelioPos()
        
        for factor in request.FactorsToUse {
            // Calculate position using orbital elements
            let position = calculatePosition(
                factor: factor,
                julianDay: julianDay,
                observerPosition: observerPosition,
                calcHelioPos: &calcHelioPos
            )
            
            // Convert to all coordinate systems
            let eclipticalPos = MainAstronomicalPosition(
                mainPos: position.longitude,
                deviation: position.latitude,
                distance: position.distance
            )
            
            // Convert to equatorial
            let (rightAscension, declination) = seWrapper.eclipticToEquatorial(
                eclipticCoordinates: [position.longitude, position.latitude],
                obliquity: obliquity
            )
            let equatorialPos = MainAstronomicalPosition(
                mainPos: rightAscension,
                deviation: declination,
                distance: position.distance
            )
            
            // Calculate horizontal position
            let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
                julianDay: julianDay,
                rightAscension: rightAscension,
                declination: declination,
                observerLatitude: request.Latitude,
                observerLongitude: request.Longitude,
                height: 0.0
            )
            let horizontalPos = HorizontalPosition(azimuth: azimuth, altitude: altitude)
            
            let fullPosition = FullFactorPosition(
                ecliptical: [eclipticalPos],
                equatorial: [equatorialPos],
                horizontal: [horizontalPos]
            )
            
            coordinates[factor] = fullPosition
        }
        
        return coordinates
    }
    
    // MARK: - Helper Methods
    
    private static func calculatePosition(
        factor: Factors,
        julianDay: Double,
        observerPosition: ObserverPositions,
        calcHelioPos: inout CalcHelioPos
    ) -> (longitude: Double, latitude: Double, distance: Double) {
        let factorT = factorT(julianDay: julianDay)
        
        if observerPosition == .geoCentric || observerPosition == .topoCentric {
            // Calculate geocentric position
            let earthOrbit = defineOrbitDefinition(for: .earth)
            let rectAngEarthHelio = calcHelioPos.calcEclipticPosition(factorT: factorT, orbitDefinition: earthOrbit)
            
            let planetOrbit = defineOrbitDefinition(for: factor)
            let rectAngPlanetHelio = calcHelioPos.calcEclipticPosition(factorT: factorT, orbitDefinition: planetOrbit)
            
            // Calculate geocentric position by subtracting Earth's position
            let rectAngPlanetGeo = RectAngCoordinates(
                xCoord: rectAngPlanetHelio.xCoord - rectAngEarthHelio.xCoord,
                yCoord: rectAngPlanetHelio.yCoord - rectAngEarthHelio.yCoord,
                zCoord: rectAngPlanetHelio.zCoord - rectAngEarthHelio.zCoord
            )
            
            let polarPlanetGeo = MathExtra.rectangular2Polar(rectAngPlanetGeo)
            return definePosition(polarPlanetGeo)
        } else {
            // Calculate heliocentric position
            let planetOrbit = defineOrbitDefinition(for: factor)
            let rectAngPlanetHelio = calcHelioPos.calcEclipticPosition(factorT: factorT, orbitDefinition: planetOrbit)
            let polarPlanetHelio = MathExtra.rectangular2Polar(rectAngPlanetHelio)
            return definePosition(polarPlanetHelio)
        }
    }
    
    private static func definePosition(_ polarPlanet: PolarCoordinates) -> (longitude: Double, latitude: Double, distance: Double) {
        var posLong = MathExtra.radToDeg(polarPlanet.phiCoord)
        if posLong < 0.0 { posLong += 360.0 }
        let posLat = MathExtra.radToDeg(polarPlanet.thetaCoord)
        let posDist = MathExtra.radToDeg(polarPlanet.rCoord)
        return (posLong, posLat, posDist)
    }
    
    private static func factorT(julianDay: Double) -> Double {
        return (julianDay - 2415020.5) / 36525.0
    }
    
    private static func defineOrbitDefinition(for factor: Factors) -> OrbitDefinition {
        let meanAnomaly: [Double]
        var eccentricity: [Double] = [0, 0, 0]
        var argumentPerihelion: [Double] = [0, 0, 0]
        var ascendingNode: [Double] = [0, 0, 0]
        var inclination: [Double] = [0, 0, 0]
        let semiMajorAxis: Double
        
        switch factor {
        case .earth:
            meanAnomaly = [358.47584, 35999.0498, -0.00015]
            eccentricity = [0.016751, -0.41e-4, 0]
            semiMajorAxis = 1.00000013
            argumentPerihelion = [101.22083, 1.71918, 0.00045]
            
        case .persephoneRam:
            meanAnomaly = [295.0, 60, 0]
            semiMajorAxis = 71.137866
            
        case .hermesRam:
            meanAnomaly = [134.7, 50.0, 0]
            semiMajorAxis = 80.331954
            
        case .demeterRam:
            meanAnomaly = [114.6, 40, 0]
            semiMajorAxis = 93.216975
            ascendingNode = [125, 0, 0]
            inclination = [5.5, 0, 0]
            
        default:
            // Fallback for unsupported factors
            meanAnomaly = [0, 0, 0]
            semiMajorAxis = 1.0
        }
        
        return OrbitDefinition(
            meanAnomaly: meanAnomaly,
            eccentricity: eccentricity,
            semiMajorAxis: semiMajorAxis,
            argumentPerihelion: argumentPerihelion,
            ascendingNode: ascendingNode,
            inclination: inclination
        )
    }
    
    private static func extractObserverPosition(from flags: Int) -> ObserverPositions {
        if (flags & 8) != 0 {  // SEFLG_HELIO (8)
            return .helioCentric
        } else if (flags & (32 * 1024)) != 0 {  // SEFLG_TOPOCTR (32768)
            return .topoCentric
        } else {
            return .geoCentric
        }
    }
}
