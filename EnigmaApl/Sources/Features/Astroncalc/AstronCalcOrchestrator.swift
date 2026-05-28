// AstronCalcOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public struct AstronCalcOrchestrator {
    
    /// Performs a full chart calculation based on the provided request
    /// - Parameters:
    ///   - request: The CalcRequest containing calculation parameters
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with Swiss Ephemeris.
    ///                For production, use the app-level instance. For tests, use SEWrapperTestCoordinator.shared.getSEWrapper()
    /// - Returns: A FullChart with all calculated positions and house data
    public static func PerformCalculation(_ request: CalcRequest, seWrapper: SEWrapper) -> FullChart {
        
        let julianDay = request.JulianDay
        let seFlagsEcliptical = SEFlags.defineFlags(calculationConfig: request.calculationConfig, coordSystem: CoordinateSystems.ecliptical)
        let seFlagsEquatorial = SEFlags.defineFlags(calculationConfig: request.calculationConfig, coordSystem: CoordinateSystems.equatorial)
        
        // check for topocentric
        if (request.calculationConfig.observerPosition == ObserverPositions.topoCentric) {
            seWrapper.setTopocentric(geoLon: request.Longitude, geoLat: request.Latitude, height: request.Height)
        }
        
        // Calculate obliquity using id -1
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            factor: -1,
            flags: 2          // Use SE, no need for speed
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        var ayanamshaOffset = 0.0;
        if (request.calculationConfig.ayanamsha != Ayanamshas.tropical) {
            seWrapper.setAyanamsha(idAyanamsha: request.calculationConfig.ayanamsha.seId)
            ayanamshaOffset = seWrapper.getAyanamshaOffset(jdUt: julianDay)
        }

        let housePositions = SECalculation.CalculateHouses(request, obliquity: obliquity, seWrapper: seWrapper)
        let siderealTime = housePositions.midheaven.rightAscension / 15.0
        
        // Group factors by calculation type
        let factorsByType = Dictionary(grouping: request.FactorsToUse) { $0.calculationType }
        
        // Calculate factors for each calculation type
        var allCoordinates: [Factors: FullFactorPosition] = [:]
        var longitudeSun = -1.0
        var longitudeMoon = -1.0
        
        // Handle CommonSe factors
        if let commonSeFactors = factorsByType[.CommonSe], !commonSeFactors.isEmpty {
            let isHelio = request.calculationConfig.observerPosition == .helioCentric
            let geoOnlyRequested = isHelio ? commonSeFactors.filter { Self.geocentricOnlyFactors.contains($0) } : []
            let helioOnlyRequested = !isHelio ? commonSeFactors.filter { Self.heliocentricOnlyFactors.contains($0) } : []
            let helioCompatible = isHelio
                ? commonSeFactors.filter { !Self.geocentricOnlyFactors.contains($0) }
                : commonSeFactors.filter { !Self.heliocentricOnlyFactors.contains($0) }

            if !geoOnlyRequested.isEmpty {
                Logger.log.warning("AstronCalcOrchestrator: heliocentric position requested for \(geoOnlyRequested) — not applicable, skipping")
            }
            if !helioOnlyRequested.isEmpty {
                Logger.log.warning("AstronCalcOrchestrator: geocentric/topocentric position requested for \(helioOnlyRequested) — not applicable, skipping")
            }

            if !helioCompatible.isEmpty {
                let commonRequest = CalcRequest(
                    JulianDay: request.JulianDay,
                    FactorsToUse: helioCompatible,
                    HouseSystem: request.HouseSystem,
                    Latitude: request.Latitude,
                    Longitude: request.Longitude,
                    Height: request.Height,
                    calculationConfig: request.calculationConfig
                )
                let commonSeCoordinates = SECalculation.CalculateFactors(commonRequest, flagsEcliptical: seFlagsEcliptical, flagsEquatorial: seFlagsEquatorial, seWrapper: seWrapper)
                allCoordinates.merge(commonSeCoordinates) { (_, new) in new }
                longitudeSun = commonSeCoordinates[Factors.sun]?.ecliptical.first?.mainPos ?? -1.0
                longitudeMoon = commonSeCoordinates[Factors.moon]?.ecliptical.first?.mainPos ?? -1.0
            }
        }
        if let commonElementsFactors = factorsByType[.CommonElements], !commonElementsFactors.isEmpty {
            let commonElementsRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonElementsFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                calculationConfig: request.calculationConfig
            )
    
            let commonElementsCoordinates = ElementsCalc.calculateElementsFactors(request: commonElementsRequest, seWrapper: seWrapper, ayanamshaOffset: ayanamshaOffset)
            allCoordinates.merge(commonElementsCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaLongitudeFactors = factorsByType[.CommonFormulaLongitude], !commonFormulaLongitudeFactors.isEmpty {
            let fCalc = FormulaCalc()
            let commonFormulaLongitudeRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonFormulaLongitudeFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                calculationConfig: request.calculationConfig
            )
            let commonFormulaLongitudeCoordinates = fCalc.calculateFormulaFactors(seWrapper: seWrapper, calcRequest: commonFormulaLongitudeRequest, ayanamshaOffset: ayanamshaOffset)
            allCoordinates.merge(commonFormulaLongitudeCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaFullFactors = factorsByType[.CommonFormulaFull], !commonFormulaFullFactors.isEmpty {
            let fFullCalc = FormulaFullCalc()
            let formulaFullCalcRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonFormulaFullFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                calculationConfig: request.calculationConfig
            )
            let commonFormulaFullCoordinates = fFullCalc.CalculateFormulaFullFactors(seWrapper: seWrapper, calcRequest: formulaFullCalcRequest, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset)
            allCoordinates.merge(commonFormulaFullCoordinates) { (_, new) in new }
        }
        
        if let lotsFactors = factorsByType[.Lots], !lotsFactors.isEmpty {
            // Extract required longitudes for lots calculation
            let ascendantLongitude = housePositions.ascendant.longitude
            let sunLongitude = allCoordinates[.sun]?.ecliptical.first?.mainPos ?? -1.0
            let moonLongitude = allCoordinates[.moon]?.ecliptical.first?.mainPos ?? -1.0
            let isDayChart = (allCoordinates[.sun]?.horizontal.first?.altitude ?? 0.0) >= 0.0
            if (sunLongitude > 0.0 && moonLongitude > 0.0) {
                
                let lotsCalc = LotsCalc()
                let lotsRequest = CalcRequest(
                    JulianDay: request.JulianDay,
                    FactorsToUse: lotsFactors,
                    HouseSystem: request.HouseSystem,
                    Latitude: request.Latitude,
                    Longitude: request.Longitude,
                    Height: request.Height,
                    calculationConfig: request.calculationConfig
                )
                let lotsCoordinates = lotsCalc.calculateLotsFactors(
                    seWrapper: seWrapper,
                    calcRequest: lotsRequest,
                    obliquity: obliquity,
                    ascendantLongitude: ascendantLongitude,
                    sunLongitude: sunLongitude,
                    moonLongitude: moonLongitude,
                    isDayChart: isDayChart,
                    ayanamshaOffset: ayanamshaOffset
                )
                allCoordinates.merge(lotsCoordinates) { (_, new) in new }
            }
        }
        
        if let mundaneFactors = factorsByType[.Mundane], !mundaneFactors.isEmpty {
            for factor in mundaneFactors {
                let cuspPos: FullCuspPosition
                switch factor {
                case .ascendant: cuspPos = housePositions.ascendant
                case .mc:        cuspPos = housePositions.midheaven
                case .eastPoint: cuspPos = housePositions.eastpoint
                case .vertex:    cuspPos = housePositions.vertex
                default:         continue
                }
                let ecliptical = MainAstronomicalPosition(mainPos: cuspPos.longitude, deviation: 0.0, distance: 0.0)
                let equatorial = MainAstronomicalPosition(mainPos: cuspPos.rightAscension, deviation: cuspPos.declination, distance: 0.0)
                let horizontal = HorizontalPosition(azimuth: cuspPos.horizontal.azimuth, altitude: cuspPos.horizontal.altitude)
                allCoordinates[factor] = FullFactorPosition(
                    ecliptical: [ecliptical],
                    equatorial: [equatorial],
                    horizontal: [horizontal]
                )
            }
        }

        if let zodiacFixedFactors = factorsByType[.ZodiacFixed], !zodiacFixedFactors.isEmpty {
            let zodiacFixedCalc = ZodiacFixedCalc()
            let zodiacFixedCoordinates = zodiacFixedCalc.zodiacFixedFactors(calcRequest: request, obliquity: obliquity, seWrapper: seWrapper)
            allCoordinates.merge(zodiacFixedCoordinates) { (_, new) in new }
        }
        
        if let apsidesFactors = factorsByType[.Apsides], !apsidesFactors.isEmpty {
            let apsidesCalc = ApsidesCalc()
            let apsidesRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: apsidesFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                calculationConfig: request.calculationConfig
            )
            let apsidesCoordinates = apsidesCalc.calculateApsidesFactors(calcRequest: apsidesRequest, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset, flags: seFlagsEcliptical, seWrapper: seWrapper)
            allCoordinates.merge(apsidesCoordinates) { (_, new) in new }
        }
        
        if (request.calculationConfig.projectionType == ProjectionTypes.obliqueLongitude) {
            // exchange all longitudes with their oblique longitude equivalents
            
            let armc = housePositions.midheaven.rightAscension
            
            // Build array of NamedEclipticCoordinates from allCoordinates
            var factorCoordinates: [NamedEclipticCoordinates] = []
            for (factor, position) in allCoordinates {
                if let ecliptical = position.ecliptical.first {
                    factorCoordinates.append(NamedEclipticCoordinates(
                        factor: factor,
                        longitude: ecliptical.mainPos,
                        latitude: ecliptical.deviation
                    ))
                }
            }
            
            // Calculate oblique longitudes
            let obliqueLongitudeCalc = ObliqueLongitudeCalc()
            let obliqueLongitudes = obliqueLongitudeCalc.ObliqueLongitudeForFactor(
                armc: armc,
                obliquity: obliquity,
                geoLat: request.Latitude,
                factorCoordinates: factorCoordinates,
                ayanamshaOffset: ayanamshaOffset
            )
            
            // Create a dictionary mapping factors to their oblique longitudes
            let obliqueLongitudeMap = Dictionary(uniqueKeysWithValues: obliqueLongitudes.map { ($0.factor, $0.obliqueLongitude) })
            
            // Create a copy of allCoordinates with oblique longitudes replacing ecliptical longitudes
            var updatedCoordinates: [Factors: FullFactorPosition] = [:]
            for (factor, position) in allCoordinates {
                if let obliqueLongitude = obliqueLongitudeMap[factor],
                   let originalEcliptical = position.ecliptical.first {
                    // Create new ecliptical positions array, updating the first position with oblique longitude
                    var updatedEclipticalPositions: [MainAstronomicalPosition] = []
                    for (index, eclipticalPos) in position.ecliptical.enumerated() {
                        if index == 0 {
                            // Replace longitude with oblique longitude for the first position
                            updatedEclipticalPositions.append(MainAstronomicalPosition(
                                mainPos: obliqueLongitude,
                                deviation: eclipticalPos.deviation,
                                distance: eclipticalPos.distance,
                                mainPosSpeed: eclipticalPos.mainPosSpeed,
                                deviationSpeed: eclipticalPos.deviationSpeed,
                                distanceSpeed: eclipticalPos.distanceSpeed
                            ))
                        } else {
                            // Keep other ecliptical positions unchanged
                            updatedEclipticalPositions.append(eclipticalPos)
                        }
                    }
                    // Create new FullFactorPosition with updated ecliptical positions
                    let updatedPosition = FullFactorPosition(
                        ecliptical: updatedEclipticalPositions,
                        equatorial: position.equatorial,
                        horizontal: position.horizontal
                    )
                    updatedCoordinates[factor] = updatedPosition
                } else {
                    // Keep original position if no oblique longitude was calculated
                    updatedCoordinates[factor] = position
                }
            }
            
            // Replace allCoordinates with the updated version
            allCoordinates = updatedCoordinates
        }
        
        
        return FullChart(
            Coordinates: allCoordinates,
            HousePositions: housePositions,
            SiderealTime: siderealTime,
            JulianDay: julianDay,
            Obliquity: obliquity
        )
    }
    

    /// Performs a single-coordinate calculation for the first factor in the request.
    /// Supports all calculation types (CommonSe, CommonElements, CommonFormulaLongitude,
    /// CommonFormulaFull, ZodiacFixed, Apsides). Only the coordinate system required for
    /// the requested coordinate is used, making this significantly cheaper than
    /// PerformCalculation for bulk/research use.
    /// Horizontal coordinates (azimuth / altitude) are not supported.
    /// Lots and Mundane factors are not supported (they require derived values such as
    /// house positions and Sun/Moon longitudes that presuppose a full chart calculation).
    /// - Parameters:
    ///   - request: The CalcRequest containing calculation parameters. Only the first
    ///              entry in FactorsToUse is evaluated.
    ///   - coordinate: The specific coordinate whose value should be returned.
    ///                 Longitude and Latitude use ecliptical coordinates;
    ///                 RightAscension and Declination use equatorial coordinates;
    ///                 Distance uses ecliptical coordinates.
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with
    ///                Swiss Ephemeris. For production use the app-level instance; for tests
    ///                use SEWrapperTestCoordinator.shared.getSEWrapper().
    /// - Returns: A tuple of (julianDay, position) where position is the value for the
    ///            requested coordinate in degrees (or AU for Distance). Returns (julianDay, 0.0)
    ///            when FactorsToUse is empty, the calculation type is unsupported, or the
    ///            underlying calculation fails.
    public static func PerformSingleCoordinateCalculation(
        _ request: CalcRequest,
        coordinate: Coordinates,
        seWrapper: SEWrapper
    ) -> (julianDay: Double, position: Double) {

        let julianDay = request.JulianDay

        guard let factor = request.FactorsToUse.first else {
            return (julianDay, 0.0)
        }

        // Apply topocentric correction when needed
        if request.calculationConfig.observerPosition == .topoCentric {
            seWrapper.setTopocentric(geoLon: request.Longitude, geoLat: request.Latitude, height: request.Height)
        }

        // Apply sidereal zodiac and compute offset (offset is needed by non-SE calcs)
        var ayanamshaOffset = 0.0
        if request.calculationConfig.ayanamsha != .tropical {
            seWrapper.setAyanamsha(idAyanamsha: request.calculationConfig.ayanamsha.seId)
            ayanamshaOffset = seWrapper.getAyanamshaOffset(jdUt: julianDay)
        }

        switch factor.calculationType {

        case .CommonSe:
            if request.calculationConfig.observerPosition == .helioCentric && Self.geocentricOnlyFactors.contains(factor) {
                Logger.log.warning("AstronCalcOrchestrator: heliocentric position requested for \(factor) — not applicable, returning 0.0")
                return (julianDay, 0.0)
            }
            if request.calculationConfig.observerPosition != .helioCentric && Self.heliocentricOnlyFactors.contains(factor) {
                Logger.log.warning("AstronCalcOrchestrator: geocentric/topocentric position requested for \(factor) — not applicable, returning 0.0")
                return (julianDay, 0.0)
            }
            let coordSystem: CoordinateSystems = (coordinate == .rightAscension || coordinate == .declination)
                ? .equatorial : .ecliptical
            let flags = SEFlags.defineFlags(calculationConfig: request.calculationConfig, coordSystem: coordSystem)
            guard let pos = seWrapper.calculateFactorPosition(julianDay: julianDay, factor: factor.seId, flags: flags) else {
                return (julianDay, 0.0)
            }
            return (julianDay, extractCoordinate(coordinate, from: pos))

        case .CommonElements:
            let results = ElementsCalc.calculateElementsFactors(
                request: request, seWrapper: seWrapper, ayanamshaOffset: ayanamshaOffset)
            return (julianDay, extractCoordinateFromFullPosition(coordinate, results[factor]))

        case .CommonFormulaLongitude:
            let fCalc = FormulaCalc()
            let results = fCalc.calculateFormulaFactors(
                seWrapper: seWrapper, calcRequest: request, ayanamshaOffset: ayanamshaOffset)
            return (julianDay, extractCoordinateFromFullPosition(coordinate, results[factor]))

        case .CommonFormulaFull:
            let obliquity = calculateObliquity(julianDay: julianDay, seWrapper: seWrapper)
            let fFullCalc = FormulaFullCalc()
            let results = fFullCalc.CalculateFormulaFullFactors(
                seWrapper: seWrapper, calcRequest: request, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset)
            return (julianDay, extractCoordinateFromFullPosition(coordinate, results[factor]))

        case .ZodiacFixed:
            let obliquity = calculateObliquity(julianDay: julianDay, seWrapper: seWrapper)
            let zodiacFixedCalc = ZodiacFixedCalc()
            let results = zodiacFixedCalc.zodiacFixedFactors(
                calcRequest: request, obliquity: obliquity, seWrapper: seWrapper)
            return (julianDay, extractCoordinateFromFullPosition(coordinate, results[factor]))

        case .Apsides:
            let obliquity = calculateObliquity(julianDay: julianDay, seWrapper: seWrapper)
            let seFlagsEcliptical = SEFlags.defineFlags(
                calculationConfig: request.calculationConfig, coordSystem: .ecliptical)
            let apsidesCalc = ApsidesCalc()
            let results = apsidesCalc.calculateApsidesFactors(
                calcRequest: request, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset,
                flags: seFlagsEcliptical, seWrapper: seWrapper)
            return (julianDay, extractCoordinateFromFullPosition(coordinate, results[factor]))

        case .Lots:
            Logger.log.warning("PerformSingleCoordinateCalculation: Lots factors require a full chart calculation (Sun/Moon/Ascendant). Factor \(factor) ignored.")
            return (julianDay, 0.0)

        case .Mundane:
            Logger.log.warning("PerformSingleCoordinateCalculation: Mundane factors require house positions from a full chart calculation. Factor \(factor) ignored.")
            return (julianDay, 0.0)

        case .Unknown:
            Logger.log.warning("PerformSingleCoordinateCalculation: Unknown calculation type for factor \(factor).")
            return (julianDay, 0.0)
        }
    }

    // MARK: - Private helpers

    /// Factors that have no meaningful heliocentric position. When observer position is heliocentric,
    /// calculations for these factors are skipped and zero positions are returned instead.
    private static let geocentricOnlyFactors: Set<Factors> = [
        .sun, .moon, .northNode, .apogeeMean, .apogeeCorrected,
        .apogeeInterpolated, .perigeeInterpolated
    ]

    /// Factors that only have a meaningful heliocentric position. When observer position is geocentric
    /// or topocentric, calculations for these factors are skipped and zero positions are returned instead.
    private static let heliocentricOnlyFactors: Set<Factors> = [.earth]

    /// Calculates the obliquity of the ecliptic using Swiss Ephemeris (SE id -1).
    private static func calculateObliquity(julianDay: Double, seWrapper: SEWrapper) -> Double {
        seWrapper.calculateFactorPosition(julianDay: julianDay, factor: -1, flags: 2)?.mainPos ?? 0.0
    }

    /// Extracts a single coordinate value from a raw `MainAstronomicalPosition` (CommonSe path).
    private static func extractCoordinate(_ coordinate: Coordinates, from pos: MainAstronomicalPosition) -> Double {
        switch coordinate {
        case .longitude:      return pos.mainPos
        case .latitude:       return pos.deviation
        case .rightAscension: return pos.mainPos
        case .declination:    return pos.deviation
        case .distance:       return pos.distance
        }
    }

    /// Extracts a single coordinate value from a `FullFactorPosition` (all non-SE paths).
    private static func extractCoordinateFromFullPosition(_ coordinate: Coordinates, _ position: FullFactorPosition?) -> Double {
        guard let position else { return 0.0 }
        switch coordinate {
        case .longitude:      return position.ecliptical.first?.mainPos ?? 0.0
        case .latitude:       return position.ecliptical.first?.deviation ?? 0.0
        case .rightAscension: return position.equatorial.first?.mainPos ?? 0.0
        case .declination:    return position.equatorial.first?.deviation ?? 0.0
        case .distance:       return position.ecliptical.first?.distance ?? 0.0
        }
    }

}
