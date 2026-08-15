// BlaSchemaPositions.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Sign/house/decan/quadrant calculations for the BLA schema.
/// Ported from Enigma.Core/Slices/BlaSchema/{BlaDetailsFactory,HousePositions,SignPositions,SignsOnCusps,
/// InterceptedClamped,BlaDecans,QuadrantPositions}.cs.
enum BlaSchemaPositions {

    /// The 4 angular points, excluded from house-position counts (their house is trivially the cusp itself).
    private static let angleFactors: Set<Factors> = [.ascendant, .mc, .eastPoint, .vertex]

    // MARK: - Sign / decan from a longitude

    static func sign(forLongitude longitude: Double) -> Int {
        Int(longitude / 30.0) + 1
    }

    static func decan(forLongitude longitude: Double) -> Int {
        var decan = Int(longitude / 10.0) + 1
        while decan > 7 { decan -= 7 }
        return decan
    }

    // MARK: - House lookup

    /// Finds the house (1-12) a longitude falls in, given the 12 cusp longitudes. Returns 0 if not found.
    static func house(forLongitude longitude: Double, cusps: [Int: Double]) -> Int {
        let sortedCusps = cusps.sorted { $0.key < $1.key }
        let nrOfHouses = sortedCusps.count
        guard nrOfHouses > 0 else { return 0 }

        for i in 0..<nrOfHouses {
            let currentCusp = sortedCusps[i].value
            let nextCusp = (i == nrOfHouses - 1) ? sortedCusps[0].value : sortedCusps[i + 1].value
            let houseNumber = sortedCusps[i].key

            if currentCusp > nextCusp {
                // Cusps cross 0° Aries
                if (longitude >= currentCusp && longitude <= 360.0) || (longitude >= 0.0 && longitude < nextCusp) {
                    return houseNumber
                }
            } else {
                if longitude >= currentCusp && longitude < nextCusp {
                    return houseNumber
                }
            }
        }
        return 0
    }

    // MARK: - Per-point / per-house details

    static func createBlaPointDetails(point: Factors, chart: BlaChartLongitudes) -> BlaPointDetails {
        let longitude = chart.points[point] ?? 0.0
        let sign = sign(forLongitude: longitude)
        let decanate = decan(forLongitude: longitude)
        let house = house(forLongitude: longitude, cusps: chart.cusps)
        let (mainRuledSign, subRuledSign) = signsRuled(byPoint: point)
        let (mainRuledHouses, subRuledHouses) = houses(ruledByMainSign: mainRuledSign, subSign: subRuledSign, cusps: chart.cusps)
        return BlaPointDetails(
            point: point, longitude: longitude, sign: sign, decanate: decanate, house: house,
            mainRuledSign: mainRuledSign, subRuledSign: subRuledSign,
            mainRuledHouses: mainRuledHouses, subRuledHouses: subRuledHouses
        )
    }

    static func createBlaHouseDetails(houseNr: Int, chart: BlaChartLongitudes) -> BlaHouseDetails {
        let signOnCusp = sign(onCusp: houseNr, cusps: chart.cusps)
        let (mainRuler, subRuler) = rulers(forSign: signOnCusp)
        let allPointsInHouses = definePositions(chart: chart)
        let pointsInHouse = allPointsInHouses.filter { $0.value == houseNr }.map { $0.key }
        let longitude = chart.cusps[houseNr] ?? 0.0
        let decanate = decan(forLongitude: longitude)
        return BlaHouseDetails(
            houseNr: houseNr, signOnCusp: signOnCusp, decanate: decanate, longitude: longitude,
            mainRuler: mainRuler, subRuler: subRuler, pointsInHouse: pointsInHouse
        )
    }

    /// Signs ruled by a point, as (main, sub). 0 when the point rules no sign in either role.
    static func signsRuled(byPoint point: Factors) -> (main: Int, sub: Int) {
        var signMain = 0
        var signSub = 0
        for pair in BlaSchemaDomain.rulerPairs() {
            if pair.mainRuler == point { signMain = pair.signIndex }
            else if pair.subRuler == point { signSub = pair.signIndex }
        }
        return (signMain, signSub)
    }

    /// Main/sub ruler for a given sign.
    static func rulers(forSign sign: Int) -> (main: Factors, sub: Factors) {
        guard let pair = BlaSchemaDomain.rulerPairs().first(where: { $0.signIndex == sign }) else {
            fatalError("Could not find rulers for sign \(sign)")
        }
        return (pair.mainRuler, pair.subRuler)
    }

    private static func houses(ruledByMainSign mainSign: Int, subSign: Int, cusps: [Int: Double]) -> (main: [Int], sub: [Int]) {
        var housesMain: [Int] = []
        var housesSub: [Int] = []
        for (house, longitude) in cusps.sorted(by: { $0.key < $1.key }) {
            let sign = sign(forLongitude: longitude)
            if sign == mainSign { housesMain.append(house) }
            if sign == subSign { housesSub.append(house) }
        }
        return (housesMain, housesSub)
    }

    static func sign(onCusp houseNr: Int, cusps: [Int: Double]) -> Int {
        guard let longitude = cusps[houseNr] else { return 0 }
        return sign(forLongitude: longitude)
    }

    // MARK: - House positions / counts

    /// House (1-12) for every non-angular point. Angles are excluded (trivially on the cusp itself).
    static func definePositions(chart: BlaChartLongitudes) -> [Factors: Int] {
        var positions: [Factors: Int] = [:]
        for (point, longitude) in chart.points where !angleFactors.contains(point) {
            let houseNumber = house(forLongitude: longitude, cusps: chart.cusps)
            if houseNumber > 0 {
                positions[point] = houseNumber
            }
        }
        return positions
    }

    /// Count of (non-angular) points per house, 1-12.
    static func defineHouseCounts(pointDetails: [BlaPointDetails]) -> [Int: Int] {
        var counts = zeroCounts()
        for detail in pointDetails where !angleFactors.contains(detail.point) {
            counts[detail.house, default: 0] += 1
        }
        return counts
    }

    /// Count of points per sign, 1-12. Angular points ARE included here (unlike house counts).
    static func defineSignCounts(pointDetails: [BlaPointDetails]) -> [Int: Int] {
        var counts = zeroCounts()
        for detail in pointDetails {
            counts[detail.sign, default: 0] += 1
        }
        return counts
    }

    /// Sign (1-12) on each house cusp.
    static func defineSignsOnCusps(cusps: [Int: Double]) -> [Int: Int] {
        var result: [Int: Int] = [:]
        for (house, longitude) in cusps {
            result[house] = sign(forLongitude: longitude)
        }
        return result
    }

    private static func zeroCounts() -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: (1...12).map { ($0, 0) })
    }

    // MARK: - Intercepted signs / clamped houses

    /// Signs that never appear as a house cusp sign.
    static func defineInterceptedSigns(chart: BlaChartLongitudes) -> [Int] {
        let cuspSigns = Set(chart.cusps.values.map { sign(forLongitude: $0) })
        return (1...12).filter { !cuspSigns.contains($0) }
    }

    /// Houses whose sign equals the next house's cusp sign (no new sign begins inside them).
    static func defineClampedHouses(chart: BlaChartLongitudes) -> [Int] {
        var clamped: [Int] = []
        for houseIndex in 1...12 {
            guard let currentLon = chart.cusps[houseIndex] else { continue }
            let nextIndex = houseIndex == 12 ? 1 : houseIndex + 1
            guard let nextLon = chart.cusps[nextIndex] else { continue }
            if sign(forLongitude: currentLon) == sign(forLongitude: nextLon) {
                clamped.append(houseIndex)
            }
        }
        return clamped
    }

    // MARK: - Quadrants

    /// Points-per-quadrant: Q1={1,2,3}, Q2={4,5,6}, Q3={7,8,9}, Q4={10,11,12}.
    static func defineQuadrants(houseDetails: [BlaHouseDetails]) -> [Int: Int] {
        var quadrants: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0]
        for details in houseDetails {
            let quadrant: Int
            switch details.houseNr {
            case 1, 2, 3: quadrant = 1
            case 4, 5, 6: quadrant = 2
            case 7, 8, 9: quadrant = 3
            default: quadrant = 4
            }
            quadrants[quadrant, default: 0] += details.pointsInHouse.count
        }
        return quadrants
    }
}
