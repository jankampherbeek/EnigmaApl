// CompositeOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Composite charts in a sidereal zodiac and in polar regions.
@MainActor
@Suite(.tags(.integration))
struct CompositeOrchestratorTests {

    private let arcMinute = 1.0 / 60.0
    private let firstJd = 2432412.2708333335    // 1947-08-14 18:30 UT
    private let secondJd = 2436065.5             // ten years later
    private let enschede = (latitude: 52.218056, longitude: 6.895556)
    private let tromso = (latitude: 69.649167, longitude: 18.955278)
    private let factors: [Factors] = [.sun, .moon, .mars, .jupiter]

    private var seWrapper: SEWrapper { SEWrapperTestCoordinator.shared.getSEWrapper() }

    private func chart(julianDay: Double, latitude: Double, longitude: Double,
                       houseSystem: HouseSystems = .placidus, ayanamsha: Ayanamshas = .tropical) -> FullChart {
        let request = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factors,
            HouseSystem: Int(houseSystem.seId.asciiValue ?? 80),
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: CalculationConfig(houseSystem: houseSystem, ayanamsha: ayanamsha)
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
    }

    private func composite(ayanamsha: Ayanamshas, method: CompositeOrchestrator.HouseMethod,
                           houseSystem: HouseSystems = .placidus) -> FullChart {
        let charts = [
            chart(julianDay: firstJd, latitude: enschede.latitude, longitude: enschede.longitude, houseSystem: houseSystem, ayanamsha: ayanamsha),
            chart(julianDay: secondJd, latitude: enschede.latitude, longitude: enschede.longitude, houseSystem: houseSystem, ayanamsha: ayanamsha)
        ]
        return CompositeOrchestrator.calculate(charts: charts, houseSystem: Int(houseSystem.seId.asciiValue ?? 80),
                                               method: method, ayanamsha: ayanamsha, seWrapper: seWrapper)
    }

    private func ayanamshaAtMeanJd() -> Double {
        seWrapper.setAyanamsha(idAyanamsha: Ayanamshas.lahiri.seId)
        return seWrapper.getAyanamshaOffset(jdUt: (firstJd + secondJd) / 2.0)
    }

    private func expectSidereal(_ sidereal: FullCuspPosition, matches tropical: FullCuspPosition, ayanamsha: Double,
                                _ label: String, sourceLocation: SourceLocation = #_sourceLocation) {
        let expectedLongitude = RangeUtil.valueToRange(tropical.longitude - ayanamsha, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(angularDifference(sidereal.longitude, expectedLongitude) < arcMinute, "\(label) longitude", sourceLocation: sourceLocation)
        #expect(angularDifference(sidereal.rightAscension, tropical.rightAscension) < arcMinute, "\(label) right ascension", sourceLocation: sourceLocation)
        #expect(abs(sidereal.declination - tropical.declination) < arcMinute, "\(label) declination", sourceLocation: sourceLocation)
    }

    // MARK: - Sidereal zodiac

    @Test func siderealCompositeFactorsKeepTheirEquatorialPositions() throws {
        let tropical = composite(ayanamsha: .tropical, method: .midpointsOnly)
        let sidereal = composite(ayanamsha: .lahiri, method: .midpointsOnly)
        let ayanamsha = ayanamshaAtMeanJd()

        for factor in factors {
            let trop = try #require(tropical.Coordinates[factor])
            let sid = try #require(sidereal.Coordinates[factor])
            let tropEcl = try #require(trop.ecliptical.first), sidEcl = try #require(sid.ecliptical.first)
            let tropEqu = try #require(trop.equatorial.first), sidEqu = try #require(sid.equatorial.first)
            let expectedLongitude = RangeUtil.valueToRange(tropEcl.mainPos - ayanamsha, lowerLimit: 0.0, upperLimit: 360.0)
            #expect(angularDifference(sidEcl.mainPos, expectedLongitude) < arcMinute, "\(factor) longitude")
            #expect(angularDifference(sidEqu.mainPos, tropEqu.mainPos) < arcMinute, "\(factor) right ascension")
            #expect(abs(sidEqu.deviation - tropEqu.deviation) < arcMinute, "\(factor) declination")
        }
    }

    @Test func siderealMidpointHousesKeepTheirEquatorialPositions() {
        let tropical = composite(ayanamsha: .tropical, method: .midpointsOnly)
        let sidereal = composite(ayanamsha: .lahiri, method: .midpointsOnly)
        let ayanamsha = ayanamshaAtMeanJd()

        expectSidereal(sidereal.HousePositions.ascendant, matches: tropical.HousePositions.ascendant, ayanamsha: ayanamsha, "ascendant")
        expectSidereal(sidereal.HousePositions.midheaven, matches: tropical.HousePositions.midheaven, ayanamsha: ayanamsha, "MC")
        for (index, (sid, trop)) in zip(sidereal.HousePositions.cusps, tropical.HousePositions.cusps).enumerated() {
            expectSidereal(sid, matches: trop, ayanamsha: ayanamsha, "cusp \(index + 1)")
        }
    }

    @Test func siderealReferenceLocationHousesUseTheTropicalArmc() {
        let method = CompositeOrchestrator.HouseMethod.referenceLocation(latitude: enschede.latitude, longitude: enschede.longitude)
        let tropical = composite(ayanamsha: .tropical, method: method)
        let sidereal = composite(ayanamsha: .lahiri, method: method)
        let ayanamsha = ayanamshaAtMeanJd()

        #expect(abs(sidereal.SiderealTime - tropical.SiderealTime) < arcMinute / 15.0)
        expectSidereal(sidereal.HousePositions.ascendant, matches: tropical.HousePositions.ascendant, ayanamsha: ayanamsha, "ascendant")
        expectSidereal(sidereal.HousePositions.midheaven, matches: tropical.HousePositions.midheaven, ayanamsha: ayanamsha, "MC")
        #expect(sidereal.HousePositions.cusps.count == 12)
        for (index, (sid, trop)) in zip(sidereal.HousePositions.cusps, tropical.HousePositions.cusps).enumerated() {
            expectSidereal(sid, matches: trop, ayanamsha: ayanamsha, "cusp \(index + 1)")
        }
    }

    @Test func tropicalCompositeIsTheDefault() {
        let charts = [
            chart(julianDay: firstJd, latitude: enschede.latitude, longitude: enschede.longitude),
            chart(julianDay: secondJd, latitude: enschede.latitude, longitude: enschede.longitude)
        ]
        let byDefault = CompositeOrchestrator.calculate(charts: charts, houseSystem: 80, method: .midpointsOnly, seWrapper: seWrapper)
        let explicit = CompositeOrchestrator.calculate(charts: charts, houseSystem: 80, method: .midpointsOnly, ayanamsha: .tropical, seWrapper: seWrapper)
        #expect(byDefault.Coordinates[.sun]?.equatorial.first?.mainPos == explicit.Coordinates[.sun]?.equatorial.first?.mainPos)
    }

    // MARK: - Polar regions

    @Test func referenceLocationInPolarRegionFallsBackToPorphyry() {
        let polar = composite(ayanamsha: .tropical, method: .referenceLocation(latitude: tromso.latitude, longitude: tromso.longitude))
        #expect(polar.HousePositions.porphyryFallback)
        #expect(polar.HousePositions.cusps.count == 12)
        #expect(polar.HousePositions.ascendant.longitude != 0.0)

        let regular = composite(ayanamsha: .tropical, method: .referenceLocation(latitude: enschede.latitude, longitude: enschede.longitude))
        #expect(!regular.HousePositions.porphyryFallback)
    }

    @Test func midpointHousesReportFallbackOfAPolarChart() {
        let charts = [
            chart(julianDay: firstJd, latitude: tromso.latitude, longitude: tromso.longitude),
            chart(julianDay: secondJd, latitude: enschede.latitude, longitude: enschede.longitude)
        ]
        let result = CompositeOrchestrator.calculate(charts: charts, houseSystem: 80, method: .midpointsOnly, seWrapper: seWrapper)
        #expect(result.HousePositions.porphyryFallback)
    }
}
