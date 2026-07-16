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

    /// The calculated chart together with the julianDay/latitude/longitude used to build it,
    /// so a results screen can display the computed date/time and location.
    struct Result {
        let chart: FullChart
        let latitude: Double
        let longitude: Double
    }

    enum LocationMethod {
        /// Arithmetic mean of the latitudes and the longitudes (flat-earth mean).
        case simplified
        /// Same flat-mean location as `.simplified`, but the moment in time is solved so
        /// that the resulting chart's MC equals the (circular) mean of the natal MCs — this
        /// shifts both the houses and the planetary positions.
        case original
        /// A user-chosen location; only the time is the midpoint.
        case referenceLocation(latitude: Double, longitude: Double)
        /// True geographic midpoint along the shortest (great-circle) arc between the
        /// locations.
        case sphericalMidpoint
    }

    /// Builds the Davison chart for two or more charts. Date/time and (for the flat methods)
    /// location are the arithmetic mean across all charts; `.sphericalMidpoint` averages the
    /// unit vectors of every location; `.original` uses the circular mean of every natal MC.
    static func calculate(
        charts: [NamedChart],
        factorsToUse: [Factors],
        calculationConfig: CalculationConfig,
        method: LocationMethod,
        seWrapper: SEWrapper
    ) -> Result {
        precondition(charts.count >= 2, "Davison chart needs at least two charts")
        let count = Double(charts.count)
        let midJulianDay = charts.map { $0.baseRequest.JulianDay }.reduce(0, +) / count

        let flatLatitude  = charts.map { $0.baseRequest.Latitude }.reduce(0, +) / count
        let flatLongitude = charts.map { $0.baseRequest.Longitude }.reduce(0, +) / count

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
                coordinates: charts.map { ($0.baseRequest.Latitude, $0.baseRequest.Longitude) }
            )

        case .original:
            let obliquity = charts.map { $0.chart.Obliquity }.reduce(0, +) / count
            let targetMcLongitude = MidpointsCalculator.circularMean(
                charts.map { $0.chart.HousePositions.midheaven.longitude }
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
        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        return Result(chart: chart, latitude: latitude, longitude: longitude)
    }

    // MARK: - Spherical midpoint

    /// True midpoint of two or more geographic locations, via the standard unit-vector-average
    /// method (for two locations this is the shortest great-circle arc between them).
    private static func sphericalMidpoint(coordinates: [(latitude: Double, longitude: Double)]) -> (latitude: Double, longitude: Double) {
        let toRad = Double.pi / 180.0
        let toDeg = 180.0 / Double.pi

        var xs = 0.0, ys = 0.0, zs = 0.0
        for (lat, lon) in coordinates {
            let latR = lat * toRad, lonR = lon * toRad
            xs += cos(latR) * cos(lonR)
            ys += cos(latR) * sin(lonR)
            zs += sin(latR)
        }
        let count = Double(coordinates.count)
        let xm = xs / count, ym = ys / count, zm = zs / count

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
