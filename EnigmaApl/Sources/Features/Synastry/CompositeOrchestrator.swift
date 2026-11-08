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

    /// - Parameter ayanamsha: the zodiac of the charts. For a sidereal zodiac the longitudes are
    ///   converted back to tropical before deriving right ascension, declination and ARMC.
    static func calculate(
        charts: [FullChart],
        houseSystem: Int,
        method: HouseMethod,
        ayanamsha: Ayanamshas = .tropical,
        seWrapper: SEWrapper
    ) -> FullChart {
        precondition(charts.count >= 2, "Composite chart needs at least two charts")
        let count = Double(charts.count)
        let obliquity = charts.map { $0.Obliquity }.reduce(0, +) / count
        let julianDay = charts.map { $0.JulianDay }.reduce(0, +) / count

        // tropical longitude = sidereal longitude + ayanamshaOffset. The ayanamsha changes almost linearly
        // with time, so its value at the mean Julian day equals the mean of the values for the charts.
        var ayanamshaOffset = 0.0
        if ayanamsha != .tropical {
            seWrapper.setAyanamsha(idAyanamsha: ayanamsha.seId)
            ayanamshaOffset = seWrapper.getAyanamshaOffset(jdUt: julianDay)
        }

        let (coordinates, omittedFactors) = compositeCoordinates(charts: charts, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset, seWrapper: seWrapper)
        let housePositions = compositeHousePositions(charts: charts, obliquity: obliquity, julianDay: julianDay, houseSystem: houseSystem, method: method, ayanamshaOffset: ayanamshaOffset, seWrapper: seWrapper)
        var skippedFactors: [Factors] = []
        for factor in charts.flatMap(\.skippedFactors) where !skippedFactors.contains(factor) {
            skippedFactors.append(factor)
        }

        return FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: housePositions.midheaven.rightAscension / 15.0,
            JulianDay: julianDay,
            Obliquity: obliquity,
            omittedFactors: omittedFactors,
            skippedFactors: skippedFactors
        )
    }

    // MARK: - Coordinates (planets, nodes, lots, asteroids, …)

    private static func compositeCoordinates(
        charts: [FullChart],
        obliquity: Double,
        ayanamshaOffset: Double,
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
            let tropicalLongitude = tropical(longitude, ayanamshaOffset)
            let (ra, dec) = seWrapper.eclipticToEquatorial(eclipticCoordinates: [tropicalLongitude, latitude], obliquity: obliquity)
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
        ayanamshaOffset: Double,
        seWrapper: SEWrapper
    ) -> HousePositions {

        /// - Parameter longitude: longitude in the zodiac of the charts (tropical or sidereal).
        func cuspPosition(longitude: Double, geo: (latitude: Double, longitude: Double)?) -> FullCuspPosition {
            let (ra, dec) = seWrapper.eclipticToEquatorial(eclipticCoordinates: [tropical(longitude, ayanamshaOffset), 0.0], obliquity: obliquity)
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
                vertex: meanCusp(charts.map { $0.HousePositions.vertex.longitude }),
                porphyryFallback: charts.contains { $0.HousePositions.porphyryFallback }
            )
        }

        switch method {
        case .midpointsOnly:
            return midpointsOnlyHousePositions()

        case .referenceLocation(let latitude, let longitude):
            let mcLongitude = MidpointsCalculator.circularMean(charts.map { $0.HousePositions.midheaven.longitude })
            let armc = seWrapper.eclipticToEquatorial(eclipticCoordinates: [tropical(mcLongitude, ayanamshaOffset), 0.0], obliquity: obliquity).rightAscension
            let geo = (latitude: latitude, longitude: longitude)

            guard let result = try? seWrapper.calculateHouseResultArmc(armc: armc, latitude: latitude, obliquity: obliquity, houseSystem: houseSystem),
                  result.cusps.count >= 13, result.ascmc.count >= 5 else {
                // Fall back to the plain midpoint houses if the SE call fails.
                return midpointsOnlyHousePositions()
            }
            // swe_houses_armc returns tropical longitudes; convert them to the zodiac of the charts.
            func position(_ tropicalLongitude: Double) -> FullCuspPosition {
                cuspPosition(longitude: zodiacal(tropicalLongitude, ayanamshaOffset), geo: geo)
            }

            let cuspCount = result.cusps.count - 1
            return HousePositions(
                cusps: (1...cuspCount).map { position(result.cusps[$0]) },
                ascendant: position(result.ascmc[0]),
                midheaven: position(result.ascmc[1]),
                eastpoint: position(result.ascmc[4]),
                vertex: position(result.ascmc[3]),
                porphyryFallback: result.porphyryFallback
            )
        }
    }

    // MARK: - Zodiac conversion

    private static func tropical(_ longitude: Double, _ ayanamshaOffset: Double) -> Double {
        RangeUtil.valueToRange(longitude + ayanamshaOffset, lowerLimit: 0.0, upperLimit: 360.0)
    }

    private static func zodiacal(_ tropicalLongitude: Double, _ ayanamshaOffset: Double) -> Double {
        RangeUtil.valueToRange(tropicalLongitude - ayanamshaOffset, lowerLimit: 0.0, upperLimit: 360.0)
    }
}
