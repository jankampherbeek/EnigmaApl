// DavisonOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Builds a Davison (Combine) chart: a real chart calculated for the midpoint moment in
/// time (UT) and a midpoint location. Unlike the Composite chart, this is a genuine
/// Swiss Ephemeris calculation for one real date/time/place — not a per-factor blend of
/// two existing charts.
struct DavisonOrchestrator {

    private init() {}

    enum LocationMethod {
        /// Arithmetic mean of the two latitudes and the two longitudes (flat-earth mean).
        case simplified
        /// Same flat-mean location as `.simplified`, but the moment in time is solved so
        /// that the resulting chart's MC equals the midpoint of the two natal MCs — this
        /// shifts both the houses and the planetary positions.
        case original
        /// A user-chosen location; only the time is the midpoint.
        case referenceLocation(latitude: Double, longitude: Double)
        /// True geographic midpoint along the shortest (great-circle) arc between the two
        /// locations.
        case sphericalMidpoint
    }

    static func calculate(
        first: NamedChart,
        second: NamedChart,
        factorsToUse: [Factors],
        calculationConfig: CalculationConfig,
        method: LocationMethod,
        seWrapper: SEWrapper
    ) -> FullChart {
        let jd1 = first.baseRequest.JulianDay
        let jd2 = second.baseRequest.JulianDay
        let midJulianDay = (jd1 + jd2) / 2.0

        let flatLatitude  = (first.baseRequest.Latitude + second.baseRequest.Latitude) / 2.0
        let flatLongitude = (first.baseRequest.Longitude + second.baseRequest.Longitude) / 2.0

        let julianDay: Double
        let latitude: Double
        let longitude: Double

        switch method {
        case .simplified:
            julianDay = midJulianDay
            latitude = flatLatitude
            longitude = flatLongitude

        case .referenceLocation(let lat, let lon):
            julianDay = midJulianDay
            latitude = lat
            longitude = lon

        case .sphericalMidpoint:
            julianDay = midJulianDay
            (latitude, longitude) = sphericalMidpoint(
                lat1: first.baseRequest.Latitude, lon1: first.baseRequest.Longitude,
                lat2: second.baseRequest.Latitude, lon2: second.baseRequest.Longitude
            )

        case .original:
            let obliquity = (first.chart.Obliquity + second.chart.Obliquity) / 2.0
            let targetMcLongitude = MidpointsCalculator.midpointPosition(
                first.chart.HousePositions.midheaven.longitude,
                second.chart.HousePositions.midheaven.longitude
            )
            julianDay = solveJulianDay(
                targetMcLongitude: targetMcLongitude, obliquity: obliquity,
                longitude: flatLongitude, nominalJulianDay: midJulianDay, seWrapper: seWrapper
            )
            latitude = flatLatitude
            longitude = flatLongitude
        }

        let request = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factorsToUse,
            HouseSystem: Int(calculationConfig.houseSystem.seId.asciiValue ?? 80),
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: calculationConfig
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
    }

    // MARK: - Spherical midpoint

    /// True midpoint along the shortest great-circle arc between two geographic locations,
    /// via the standard unit-vector-average method.
    private static func sphericalMidpoint(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> (latitude: Double, longitude: Double) {
        let toRad = Double.pi / 180.0
        let toDeg = 180.0 / Double.pi
        let lat1r = lat1 * toRad, lon1r = lon1 * toRad
        let lat2r = lat2 * toRad, lon2r = lon2 * toRad

        let x1 = cos(lat1r) * cos(lon1r), y1 = cos(lat1r) * sin(lon1r), z1 = sin(lat1r)
        let x2 = cos(lat2r) * cos(lon2r), y2 = cos(lat2r) * sin(lon2r), z2 = sin(lat2r)
        let xm = (x1 + x2) / 2.0, ym = (y1 + y2) / 2.0, zm = (z1 + z2) / 2.0

        let longitudeMid = atan2(ym, xm) * toDeg
        let hypotenuse = sqrt(xm * xm + ym * ym)
        let latitudeMid = atan2(zm, hypotenuse) * toDeg
        return (latitudeMid, longitudeMid)
    }

    // MARK: - Original: solve the JD so the chart's MC matches the midpoint MC

    /// Finds the Julian Day (UT) closest to `nominalJulianDay` at which the local sidereal
    /// time at `longitude` equals the ARMC for `targetMcLongitude`. Converges in a couple of
    /// iterations since sidereal time is almost perfectly linear in JD over a fraction of a day.
    private static func solveJulianDay(
        targetMcLongitude: Double, obliquity: Double, longitude: Double,
        nominalJulianDay: Double, seWrapper: SEWrapper
    ) -> Double {
        let armcTarget = seWrapper.eclipticToEquatorial(
            eclipticCoordinates: [targetMcLongitude, 0.0], obliquity: obliquity
        ).rightAscension

        // Sidereal rate: degrees of sidereal time advance per solar day.
        let siderealRatePerDay = 360.9856473

        var jd = nominalJulianDay
        for _ in 0..<3 {
            let armcAtJd = normalizeDegrees(seWrapper.siderealTime(jdUt: jd) * 15.0 + longitude)
            let diff = normalizeSignedDegrees(armcTarget - armcAtJd)
            jd += diff / siderealRatePerDay
        }
        return jd
    }

    private static func normalizeDegrees(_ value: Double) -> Double {
        var v = value.truncatingRemainder(dividingBy: 360.0)
        if v < 0 { v += 360.0 }
        return v
    }

    private static func normalizeSignedDegrees(_ value: Double) -> Double {
        var v = normalizeDegrees(value)
        if v > 180.0 { v -= 360.0 }
        return v
    }
}
