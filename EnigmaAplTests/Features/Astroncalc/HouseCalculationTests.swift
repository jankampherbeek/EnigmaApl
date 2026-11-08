// HouseCalculationTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Sidereal houses and the Porphyry fallback in polar regions, through the complete chart calculation.
@MainActor
@Suite(.tags(.integration))
struct HouseCalculationTests {

    private let arcSecond = 1.0 / 3600.0

    // New Delhi, 1947-08-14 18:30 UT (reference case new-delhi-1947-lahiri-wholesign).
    private let delhiJd = 2432412.2708333335, delhiLat = 28.613889, delhiLon = 77.209
    // Tromsø, 1999-12-21 12:00 UT (reference case tromso-1999-placidus-polar).
    private let tromsoJd = 2451534.0, tromsoLat = 69.649167, tromsoLon = 18.955278

    private func calculate(julianDay: Double, latitude: Double, longitude: Double,
                           houseSystem: HouseSystems, ayanamsha: Ayanamshas = .tropical) -> FullChart {
        let config = CalculationConfig(houseSystem: houseSystem, ayanamsha: ayanamsha)
        let request = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: [.sun],
            HouseSystem: Int(houseSystem.seId.asciiValue ?? 80),
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: config
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: SEWrapperTestCoordinator.shared.getSEWrapper())
    }

    // MARK: - Sidereal houses

    @Test func siderealHousesDifferFromTropicalByTheAyanamsha() {
        let tropical = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .placidus)
        let sidereal = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .placidus, ayanamsha: .lahiri)
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        seWrapper.setAyanamsha(idAyanamsha: Ayanamshas.lahiri.seId)
        let ayanamsha = seWrapper.getAyanamshaOffset(jdUt: delhiJd)

        // Swiss Ephemeris calculates sidereal houses without nutation (13″ for this date),
        // while swe_get_ayanamsa_ut includes it; a tolerance of 1′ covers that.
        let tolerance = 1.0 / 60.0
        let pairs = [(tropical.HousePositions.ascendant, sidereal.HousePositions.ascendant),
                     (tropical.HousePositions.midheaven, sidereal.HousePositions.midheaven)]
            + zip(tropical.HousePositions.cusps, sidereal.HousePositions.cusps).map { ($0, $1) }
        #expect(sidereal.HousePositions.cusps.count == 12)
        for (trop, sid) in pairs {
            let expected = RangeUtil.valueToRange(trop.longitude - ayanamsha, lowerLimit: 0.0, upperLimit: 360.0)
            #expect(angularDifference(sid.longitude, expected) < tolerance,
                    "expected \(expected), got \(sid.longitude)")
        }
    }

    @Test func ascendantOfIndianIndependenceIsInTaurus() {
        // The chart of Indian independence has its ascendant at about 7°46′ Taurus sidereal (Lahiri).
        let chart = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .placidus, ayanamsha: .lahiri)
        #expect(abs(chart.HousePositions.ascendant.longitude - (30.0 + 7.0 + 46.0 / 60.0)) < 0.1)
    }

    @Test func siderealHousesKeepTheirEquatorialPositions() {
        // RA and declination of a point do not depend on the zodiac.
        let tropical = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .regiomontanus)
        let sidereal = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .regiomontanus, ayanamsha: .lahiri)
        let pairs = [(tropical.HousePositions.ascendant, sidereal.HousePositions.ascendant),
                     (tropical.HousePositions.midheaven, sidereal.HousePositions.midheaven)]
            + zip(tropical.HousePositions.cusps, sidereal.HousePositions.cusps).map { ($0, $1) }
        for (trop, sid) in pairs {
            #expect(angularDifference(trop.rightAscension, sid.rightAscension) < arcSecond)
            #expect(abs(trop.declination - sid.declination) < arcSecond)
            #expect(angularDifference(trop.horizontal.azimuth, sid.horizontal.azimuth) < arcSecond)
        }
    }

    @Test func wholeSignHousesStartAtTheSiderealSignOfTheAscendant() {
        let chart = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .wholeSign, ayanamsha: .lahiri)
        let cusps = chart.HousePositions.cusps.map(\.longitude)
        #expect(cusps == (0..<12).map { Double(($0 + 1) % 12) * 30.0 })   // 30, 60, ... 330, 0
    }

    @Test func equalAriesHousesStartAtSiderealAries() {
        let chart = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .equalAries, ayanamsha: .lahiri)
        #expect(chart.HousePositions.cusps.first?.longitude == 0.0)
    }

    // MARK: - Polar regions

    @Test(arguments: [HouseSystems.placidus, .koch, .gauquelin, .sunShine])
    func polarRegionsFallBackToPorphyry(houseSystem: HouseSystems) {
        for latitude in [tromsoLat, -tromsoLat] {
            let porphyry = calculate(julianDay: tromsoJd, latitude: latitude, longitude: tromsoLon, houseSystem: .porphyri)
            let chart = calculate(julianDay: tromsoJd, latitude: latitude, longitude: tromsoLon, houseSystem: houseSystem)

            #expect(chart.HousePositions.porphyryFallback, "\(houseSystem) at \(latitude)")
            #expect(chart.HousePositions.cusps.count == 12)
            for (act, exp) in zip(chart.HousePositions.cusps, porphyry.HousePositions.cusps) {
                #expect(angularDifference(act.longitude, exp.longitude) < arcSecond)
            }
            #expect(angularDifference(chart.HousePositions.ascendant.longitude, porphyry.HousePositions.ascendant.longitude) < arcSecond)
            #expect(angularDifference(chart.HousePositions.midheaven.longitude, porphyry.HousePositions.midheaven.longitude) < arcSecond)
            #expect(chart.HousePositions.ascendant.longitude != 0.0)
        }
    }

    @Test func polarFallbackAlsoWorksForSiderealCharts() {
        let chart = calculate(julianDay: tromsoJd, latitude: tromsoLat, longitude: tromsoLon, houseSystem: .placidus, ayanamsha: .lahiri)
        let porphyry = calculate(julianDay: tromsoJd, latitude: tromsoLat, longitude: tromsoLon, houseSystem: .porphyri, ayanamsha: .lahiri)
        #expect(chart.HousePositions.porphyryFallback)
        #expect(angularDifference(chart.HousePositions.cusps[1].longitude, porphyry.HousePositions.cusps[1].longitude) < arcSecond)
    }

    @Test(arguments: [HouseSystems.regiomontanus, .campanus, .porphyri, .equalAsc])
    func otherHouseSystemsWorkInPolarRegions(houseSystem: HouseSystems) {
        let chart = calculate(julianDay: tromsoJd, latitude: tromsoLat, longitude: tromsoLon, houseSystem: houseSystem)
        #expect(!chart.HousePositions.porphyryFallback)
        #expect(chart.HousePositions.cusps.count == 12)
    }

    @Test func noFallbackOutsidePolarRegions() {
        let chart = calculate(julianDay: tromsoJd, latitude: 66.0, longitude: tromsoLon, houseSystem: .placidus)
        #expect(!chart.HousePositions.porphyryFallback)
    }

    @Test func gauquelinOutsidePolarRegionsKeeps36Sectors() {
        let chart = calculate(julianDay: delhiJd, latitude: delhiLat, longitude: delhiLon, houseSystem: .gauquelin)
        #expect(!chart.HousePositions.porphyryFallback)
        #expect(chart.HousePositions.cusps.count == 36)
    }
}
