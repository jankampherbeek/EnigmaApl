// PrimDirCalcAssistTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

private let DELTA = 1e-7

// MARK: - isChartLeft

struct PrimDirCalcAssistIsChartLeftTests {

    @Test("isChartLeft: point before MC in forward direction is chart-left")
    func testIsChartLeftScenario1() {
        let raMc    = 337.966666666667
        let raPoint = 130.83333333333
        #expect(PrimDirCalcAssist.isChartLeft(raPoint, mc: raMc) == true)
    }

    @Test("isChartLeft: point more than 180° after MC is not chart-left")
    func testIsChartLeftScenario2() {
        let raMc    = 337.966666666667
        let raPoint = 230.83333333333
        #expect(PrimDirCalcAssist.isChartLeft(raPoint, mc: raMc) == false)
    }

    @Test("isChartLeft: point less than 180° before MC wrapping through 0° is chart-left")
    func testIsChartLeftScenario3() {
        let raMc    = 337.966666666667
        let raPoint = 30.83333333333
        #expect(PrimDirCalcAssist.isChartLeft(raPoint, mc: raMc) == true)
    }

    @Test("isChartLeft: point just before MC wrapping is not chart-left")
    func testIsChartLeftScenario4() {
        let raMc    = 10.0
        let raPoint = 350.0
        #expect(PrimDirCalcAssist.isChartLeft(raPoint, mc: raMc) == false)
    }
}

// MARK: - isChartTop

struct PrimDirCalcAssistIsChartTopTests {

    @Test("isChartTop: point just after ASC is not chart-top")
    func testIsChartTopScenario1() {
        let raAsc   = 90.0
        let raPoint = 100.0
        #expect(PrimDirCalcAssist.isChartTop(raPoint, asc: raAsc) == false)
    }

    @Test("isChartTop: point just before ASC is chart-top")
    func testIsChartTopScenario2() {
        let raAsc   = 90.0
        let raPoint = 80.0
        #expect(PrimDirCalcAssist.isChartTop(raPoint, asc: raAsc) == true)
    }

    @Test("isChartTop: point before ASC wrapping through 0° is chart-top")
    func testIsChartTopScenario3() {
        let lonAsc   = 10.0
        let lonPoint = 350.0
        #expect(PrimDirCalcAssist.isChartTop(lonPoint, asc: lonAsc) == true)
    }

    @Test("isChartTop: point just after ASC wrapping is not chart-top")
    func testIsChartTopScenario4() {
        let lonAsc   = 350.0
        let lonPoint = 10.0
        #expect(PrimDirCalcAssist.isChartTop(lonPoint, asc: lonAsc) == false)
    }
}

// MARK: - meridianDistance

struct PrimDirCalcAssistMeridianDistanceTests {

    @Test("meridianDistance: chart-bottom point, normal case")
    func testMeridianDistanceScenario1() {
        let actual = PrimDirCalcAssist.meridianDistance(131, raMc: 338, raIc: 158, isTop: false)
        #expect(abs(actual - 27.0) < DELTA)
    }

    @Test("meridianDistance: chart-top point, normal case")
    func testMeridianDistanceScenario2() {
        let actual = PrimDirCalcAssist.meridianDistance(300, raMc: 338, raIc: 158, isTop: true)
        #expect(abs(actual - 38.0) < DELTA)
    }

    @Test("meridianDistance: chart-top point close to MC")
    func testMeridianDistanceScenario3() {
        let actual = PrimDirCalcAssist.meridianDistance(340, raMc: 338, raIc: 158, isTop: true)
        #expect(abs(actual - 2.0) < DELTA)
    }

    @Test("meridianDistance: chart-bottom point close to IC")
    func testMeridianDistanceScenario4() {
        let actual = PrimDirCalcAssist.meridianDistance(156, raMc: 338, raIc: 158, isTop: false)
        #expect(abs(actual - 2.0) < DELTA)
    }

    @Test("meridianDistance: chart-top point wrapping past 0°")
    func testMeridianDistanceScenario5() {
        let actual = PrimDirCalcAssist.meridianDistance(358, raMc: 8, raIc: 188, isTop: true)
        #expect(abs(actual - 10.0) < DELTA)
    }

    @Test("meridianDistance: chart-bottom point wrapping past 0° (IC near 359°)")
    func testMeridianDistanceScenario6() {
        let actual = PrimDirCalcAssist.meridianDistance(1, raMc: 179, raIc: 359, isTop: false)
        #expect(abs(actual - 2.0) < DELTA)
    }

    @Test("meridianDistance: chart-bottom point just before IC wrapping")
    func testMeridianDistanceScenario7() {
        let actual = PrimDirCalcAssist.meridianDistance(357, raMc: 179, raIc: 359, isTop: false)
        #expect(abs(actual - 2.0) < DELTA)
    }
}

// MARK: - horizontalDistance

struct PrimDirCalcAssistHorizontalDistanceTests {

    @Test("horizontalDistance: western hemisphere, southern latitude")
    func testHorizontalDistance() {
        // eastern = false → chartLeft = false; north = false (southern latitude)
        let actual = PrimDirCalcAssist.horizontalDistance(288, oaAsc: 247, chartLeft: false, north: false)
        #expect(abs(actual - 41.0) < DELTA)
    }
}

// MARK: - ascensionalDifference

struct PrimDirCalcAssistAscensionalDifferenceTests {

    @Test("ascensionalDifference: example from Gansten Primary Directions p.151")
    func testAscensionalDifference() {
        let actual = PrimDirCalcAssist.ascensionalDifference(18.16666666667, geoLat: 58.2666666666667)
        #expect(abs(actual - 32.04675727201) < DELTA)
    }

    @Test("ascensionalDifference: negative declination gives negative result")
    func testAscensionalDifferenceDeclSouth() {
        let actual = PrimDirCalcAssist.ascensionalDifference(-12.0, geoLat: 50.0)
        #expect(abs(actual - (-14.6737666261)) < DELTA)
    }

    @Test("ascensionalDifference: southern geographic latitude gives negative result")
    func testAscensionalDifferenceGeoLatSouth() {
        let actual = PrimDirCalcAssist.ascensionalDifference(12.0, geoLat: -50.0)
        #expect(abs(actual - (-14.6737666261)) < DELTA)
    }
}

// MARK: - poleRegiomontanus

struct PrimDirCalcAssistPoleRegiomontanusTests {

    // Values from Gansten, Primary Directions, p. 156.
    // Larger delta because the example values are rounded.
    @Test("poleRegiomontanus: example from Gansten p.156")
    func testPoleRegiomontanus() {
        let actual = PrimDirCalcAssist.poleRegiomontanus(
            18.1666666666667, mdUpper: 152.8666666666667, geoLat: 58.2666666666667
        )
        #expect(abs(actual - 51.7833333333333) < 1e-2)
    }
}

// MARK: - adUnderRegPole

struct PrimDirCalcAssistAdUnderRegPoleTests {

    // Values from Gansten, Primary Directions, p. 156.
    // Larger delta because the example values are rounded.
    @Test("adUnderRegPole: example from Gansten p.156")
    func testAdUnderRegPole() {
        let actual = PrimDirCalcAssist.adUnderRegPole(51.78333333, decl: 18.1666666666667)
        #expect(abs(actual - 24.63333333) < 1e-2)
    }
}

// MARK: - elevationOfThePolePlac

struct PrimDirCalcAssistElevationOfThePolePlacTests {

    @Test("elevationOfThePolePlac: atan(sin(adPole) / tan(decl))")
    func testElevationOfThePolePlac() {
        let actual = PrimDirCalcAssist.elevationOfThePolePlac(16.5042412351, decl: 18.3686111111)
        #expect(abs(actual - 40.5489600405) < DELTA)
    }
}

// MARK: - adPromUnderElevPoleSign

struct PrimDirCalcAssistAdPromUnderElevPoleSignTests {

    @Test("adPromUnderElevPoleSign: ascensional difference under elevation of the pole")
    func testAdPromUnderElevPoleSign() {
        let actual = PrimDirCalcAssist.adPromUnderElevPoleSign(40.5489600405, declProm: 18.0027777778)
        #expect(abs(actual - 16.1429042314) < DELTA)
    }
}

// MARK: - obliqueAscDesc

struct PrimDirCalcAssistObliqueAscDescTests {

    // Values from Gansten, Primary Directions, p. 151.
    @Test("obliqueAscDesc: example from Gansten p.151")
    func testObliqueAscDesc() {
        // east = true → chartLeft = true
        let actual = PrimDirCalcAssist.obliqueAscDesc(
            130.83333333333, ascDiff: 32.04675727201, chartLeft: true, north: true
        )
        #expect(abs(actual - 98.78657606132) < DELTA)
    }
}

// MARK: - declFromLongNoLat

struct PrimDirCalcAssistDeclFromLongNoLatTests {

    @Test("declFromLongNoLat: known longitude and obliquity")
    func testDeclFromLongNoLat() {
        let actual = PrimDirCalcAssist.declFromLongNoLat(220.884444444444, obliquity: 23.437101628)
        #expect(abs(actual - (-15.09002104)) < DELTA)
    }
}

// MARK: - rightAscFromLongNoLat

struct PrimDirCalcAssistRightAscFromLongNoLatTests {

    @Test("rightAscFromLongNoLat: known longitude and obliquity")
    func testRightAscFromLongNoLat() {
        let actual = PrimDirCalcAssist.rightAscFromLongNoLat(309.11851067931303, obliquity: 23.447072302623031)
        #expect(abs(actual - 311.55400138719745) < DELTA)
    }
}
