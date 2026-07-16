// CompositeOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Builds a composite chart: every factor sits on the mean of its natal positions across
/// two or more charts. Two conventions for the houses are supported (see `HouseMethod`).
struct CompositeOrchestrator {

    private init() {}

    enum HouseMethod {
        /// Every cusp/angle is also the (circular) mean of the natal cusps/angles.
        case midpointsOnly
        /// The composite MC is the circular mean of the natal MCs; ARMC is derived from it
        /// and the houses are (re)computed at the given geographic latitude/longitude.
        case referenceLocation(latitude: Double, longitude: Double)
    }

    static func calculate(
        charts: [FullChart],
        houseSystem: Int,
        method: HouseMethod,
        seWrapper: SEWrapper
    ) -> FullChart {
        precondition(charts.count >= 2, "Composite chart needs at least two charts")
        let count = Double(charts.count)
        let obliquity = charts.map { $0.Obliquity }.reduce(0, +) / count
        let julianDay = charts.map { $0.JulianDay }.reduce(0, +) / count

        let (coordinates, omittedFactors) = compositeCoordinates(charts: charts, obliquity: obliquity, seWrapper: seWrapper)
        let housePositions = compositeHousePositions(charts: charts, obliquity: obliquity, julianDay: julianDay, houseSystem: houseSystem, method: method, seWrapper: seWrapper)

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
        charts: [FullChart],
        obliquity: Double,
        seWrapper: SEWrapper
    ) -> (coordinates: [Factors: FullFactorPosition], omittedFactors: [Factors]) {
        var coordinates: [Factors: FullFactorPosition] = [:]
        var omitted: [Factors] = []
        let count = Double(charts.count)

        let commonFactors = charts.dropFirst().reduce(Set(charts[0].Coordinates.keys)) { $0.intersection($1.Coordinates.keys) }
        for factor in commonFactors {
            guard factor.calculationType != .Mundane else { continue }
            guard !charts.contains(where: { $0.omittedFactors.contains(factor) }) else {
                omitted.append(factor)
                continue
            }
            let positions = charts.compactMap { $0.Coordinates[factor]?.ecliptical.first }
            guard positions.count == charts.count else { continue }

            let longitude = MidpointsCalculator.circularMean(positions.map { $0.mainPos })
            let latitude  = positions.map { $0.deviation }.reduce(0, +) / count
            let distance  = positions.map { $0.distance }.reduce(0, +) / count
            let mainSpeed = positions.map { $0.mainPosSpeed }.reduce(0, +) / count
            let devSpeed  = positions.map { $0.deviationSpeed }.reduce(0, +) / count
            let distSpeed = positions.map { $0.distanceSpeed }.reduce(0, +) / count

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
        charts: [FullChart],
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

        func meanCusp(_ longitudes: [Double]) -> FullCuspPosition {
            cuspPosition(longitude: MidpointsCalculator.circularMean(longitudes), geo: nil)
        }

        func midpointsOnlyHousePositions() -> HousePositions {
            let cuspCount = charts[0].HousePositions.cusps.count
            let cusps = (0..<cuspCount).map { index in
                meanCusp(charts.map { $0.HousePositions.cusps[index].longitude })
            }
            return HousePositions(
                cusps: cusps,
                ascendant: meanCusp(charts.map { $0.HousePositions.ascendant.longitude }),
                midheaven: meanCusp(charts.map { $0.HousePositions.midheaven.longitude }),
                eastpoint: meanCusp(charts.map { $0.HousePositions.eastpoint.longitude }),
                vertex: meanCusp(charts.map { $0.HousePositions.vertex.longitude })
            )
        }

        switch method {
        case .midpointsOnly:
            return midpointsOnlyHousePositions()

        case .referenceLocation(let latitude, let longitude):
            let mcLongitude = MidpointsCalculator.circularMean(charts.map { $0.HousePositions.midheaven.longitude })
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
