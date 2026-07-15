// CompositeOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Builds a composite chart: every factor sits on the midpoint between its two natal
/// positions. Two conventions for the houses are supported (see `HouseMethod`).
struct CompositeOrchestrator {

    private init() {}

    enum HouseMethod {
        /// Every cusp/angle is also the midpoint of the two natal cusps/angles.
        case midpointsOnly
        /// The composite MC is the midpoint of the two natal MCs; ARMC is derived from it
        /// and the houses are (re)computed at the given geographic latitude/longitude.
        case referenceLocation(latitude: Double, longitude: Double)
    }

    static func calculate(
        chart1: FullChart,
        chart2: FullChart,
        houseSystem: Int,
        method: HouseMethod,
        seWrapper: SEWrapper
    ) -> FullChart {
        let obliquity = (chart1.Obliquity + chart2.Obliquity) / 2.0
        let julianDay = (chart1.JulianDay + chart2.JulianDay) / 2.0

        let (coordinates, omittedFactors) = compositeCoordinates(chart1: chart1, chart2: chart2, obliquity: obliquity, seWrapper: seWrapper)
        let housePositions = compositeHousePositions(chart1: chart1, chart2: chart2, obliquity: obliquity, julianDay: julianDay, houseSystem: houseSystem, method: method, seWrapper: seWrapper)

        return FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: housePositions.midheaven.rightAscension / 15.0,
            JulianDay: julianDay,
            Obliquity: obliquity,
            omittedFactors: omittedFactors
        )
    }

    // MARK: - Coordinates (planets, nodes, lots, asteroids, …)

    private static func compositeCoordinates(
        chart1: FullChart,
        chart2: FullChart,
        obliquity: Double,
        seWrapper: SEWrapper
    ) -> (coordinates: [Factors: FullFactorPosition], omittedFactors: [Factors]) {
        var coordinates: [Factors: FullFactorPosition] = [:]
        var omitted: [Factors] = []

        let commonFactors = Set(chart1.Coordinates.keys).intersection(chart2.Coordinates.keys)
        for factor in commonFactors {
            guard factor.calculationType != .Mundane else { continue }
            guard !chart1.omittedFactors.contains(factor), !chart2.omittedFactors.contains(factor) else {
                omitted.append(factor)
                continue
            }
            guard let pos1 = chart1.Coordinates[factor]?.ecliptical.first,
                  let pos2 = chart2.Coordinates[factor]?.ecliptical.first else { continue }

            let longitude = MidpointsCalculator.midpointPosition(pos1.mainPos, pos2.mainPos)
            let latitude  = (pos1.deviation + pos2.deviation) / 2.0
            let distance  = (pos1.distance + pos2.distance) / 2.0
            let mainSpeed = (pos1.mainPosSpeed + pos2.mainPosSpeed) / 2.0
            let devSpeed  = (pos1.deviationSpeed + pos2.deviationSpeed) / 2.0
            let distSpeed = (pos1.distanceSpeed + pos2.distanceSpeed) / 2.0

            let ecliptical = MainAstronomicalPosition(
                mainPos: longitude, deviation: latitude, distance: distance,
                mainPosSpeed: mainSpeed, deviationSpeed: devSpeed, distanceSpeed: distSpeed
            )
            let (ra, dec) = seWrapper.eclipticToEquatorial(eclipticCoordinates: [longitude, latitude], obliquity: obliquity)
            let equatorial = MainAstronomicalPosition(mainPos: ra, deviation: dec, distance: distance)

            coordinates[factor] = FullFactorPosition(
                ecliptical: [ecliptical],
                equatorial: [equatorial],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
        }

        return (coordinates, omitted)
    }

    // MARK: - House positions

    private static func compositeHousePositions(
        chart1: FullChart,
        chart2: FullChart,
        obliquity: Double,
        julianDay: Double,
        houseSystem: Int,
        method: HouseMethod,
        seWrapper: SEWrapper
    ) -> HousePositions {

        func cuspPosition(longitude: Double, geo: (latitude: Double, longitude: Double)?) -> FullCuspPosition {
            let (ra, dec) = seWrapper.eclipticToEquatorial(eclipticCoordinates: [longitude, 0.0], obliquity: obliquity)
            guard let geo else {
                return FullCuspPosition(longitude: longitude, rightAscension: ra, declination: dec, horizontal: HorizontalPosition(azimuth: 0.0, altitude: 0.0))
            }
            let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
                julianDay: julianDay, rightAscension: ra, declination: dec,
                observerLatitude: geo.latitude, observerLongitude: geo.longitude, height: 0.0
            )
            return FullCuspPosition(longitude: longitude, rightAscension: ra, declination: dec, horizontal: HorizontalPosition(azimuth: azimuth, altitude: altitude))
        }

        func midpointsOnlyHousePositions() -> HousePositions {
            func midpointCusp(_ c1: FullCuspPosition, _ c2: FullCuspPosition) -> FullCuspPosition {
                cuspPosition(longitude: MidpointsCalculator.midpointPosition(c1.longitude, c2.longitude), geo: nil)
            }
            let cusps = zip(chart1.HousePositions.cusps, chart2.HousePositions.cusps).map(midpointCusp)
            return HousePositions(
                cusps: cusps,
                ascendant: midpointCusp(chart1.HousePositions.ascendant, chart2.HousePositions.ascendant),
                midheaven: midpointCusp(chart1.HousePositions.midheaven, chart2.HousePositions.midheaven),
                eastpoint: midpointCusp(chart1.HousePositions.eastpoint, chart2.HousePositions.eastpoint),
                vertex: midpointCusp(chart1.HousePositions.vertex, chart2.HousePositions.vertex)
            )
        }

        switch method {
        case .midpointsOnly:
            return midpointsOnlyHousePositions()

        case .referenceLocation(let latitude, let longitude):
            let mcLongitude = MidpointsCalculator.midpointPosition(chart1.HousePositions.midheaven.longitude, chart2.HousePositions.midheaven.longitude)
            let armc = seWrapper.eclipticToEquatorial(eclipticCoordinates: [mcLongitude, 0.0], obliquity: obliquity).rightAscension
            let geo = (latitude: latitude, longitude: longitude)

            guard let (rawCusps, ascmc) = try? seWrapper.calculateHousesArmc(armc: armc, latitude: latitude, obliquity: obliquity, houseSystem: houseSystem),
                  rawCusps.count >= 13, ascmc.count >= 5 else {
                // Fall back to the plain midpoint houses if the SE call fails.
                return midpointsOnlyHousePositions()
            }

            let cusps = (1...12).map { cuspPosition(longitude: rawCusps[$0], geo: geo) }
            return HousePositions(
                cusps: cusps,
                ascendant: cuspPosition(longitude: ascmc[0], geo: geo),
                midheaven: cuspPosition(longitude: ascmc[1], geo: geo),
                eastpoint: cuspPosition(longitude: ascmc[4], geo: geo),
                vertex: cuspPosition(longitude: ascmc[3], geo: geo)
            )
        }
    }
}
