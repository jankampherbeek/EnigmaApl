//
//  WheelGeometryTests.swift
//  EnigmaAplTests
//

import Testing
import CoreGraphics
@testable import EnigmaApl

struct WheelGeometryTests {

    private let accuracy = 1e-10

    // MARK: - point()

    @Test("point: angle 0° (top) staat recht boven het middelpunt")
    func testPointAngle0() {
        let center = CGPoint(x: 100, y: 100)
        let p = WheelGeometry.point(angleDeg: 0, radius: 100, center: center)
        #expect(abs(Double(p.x) - 100.0) < accuracy)
        #expect(abs(Double(p.y) - 0.0) < accuracy)
    }

    @Test("point: angle 90° staat links van het middelpunt (counter-clockwise conventie)")
    func testPointAngle90() {
        let center = CGPoint(x: 0, y: 0)
        let p = WheelGeometry.point(angleDeg: 90, radius: 100, center: center)
        #expect(abs(Double(p.x) - (-100.0)) < accuracy)
        #expect(abs(Double(p.y) - 0.0) < accuracy)
    }

    @Test("point: angle 180° staat recht onder het middelpunt")
    func testPointAngle180() {
        let center = CGPoint(x: 0, y: 0)
        let p = WheelGeometry.point(angleDeg: 180, radius: 100, center: center)
        #expect(abs(Double(p.x) - 0.0) < 1e-6)
        #expect(abs(Double(p.y) - 100.0) < accuracy)
    }

    @Test("point: angle 270° staat rechts van het middelpunt")
    func testPointAngle270() {
        let center = CGPoint(x: 0, y: 0)
        let p = WheelGeometry.point(angleDeg: 270, radius: 100, center: center)
        #expect(abs(Double(p.x) - 100.0) < accuracy)
        #expect(abs(Double(p.y) - 0.0) < 1e-6)
    }

    @Test("point: straal 0 geeft altijd het middelpunt terug")
    func testPointRadius0() {
        let center = CGPoint(x: 50, y: 75)
        let p = WheelGeometry.point(angleDeg: 45, radius: 0, center: center)
        #expect(abs(Double(p.x) - 50.0) < accuracy)
        #expect(abs(Double(p.y) - 75.0) < accuracy)
    }

    @Test("point: negatieve hoek (-90°) is equivalent aan 270°")
    func testPointNegativeAngle() {
        let center = CGPoint(x: 0, y: 0)
        let pNeg = WheelGeometry.point(angleDeg: -90, radius: 100, center: center)
        let p270 = WheelGeometry.point(angleDeg: 270, radius: 100, center: center)
        #expect(abs(Double(pNeg.x) - Double(p270.x)) < accuracy)
        #expect(abs(Double(pNeg.y) - Double(p270.y)) < accuracy)
    }

    // MARK: - mundaneAngle()

    @Test("mundaneAngle: ascendant komt altijd op 90°")
    func testMundaneAngleAscendantAt90() {
        let asc = 45.0
        let result = WheelGeometry.mundaneAngle(longitude: asc, ascendantLongitude: asc)
        #expect(result == 90.0)
    }

    @Test("mundaneAngle: MC (asc - 90°) komt op 0° (top)")
    func testMundaneAngleMCAtTop() {
        let asc = 90.0
        let mc  = 0.0  // MC = ASC - 90
        let result = WheelGeometry.mundaneAngle(longitude: mc, ascendantLongitude: asc)
        #expect(result == 0.0)
    }

    @Test("mundaneAngle: DSC (asc + 180°) komt op 270°")
    func testMundaneAngleDSCAt270() {
        let asc = 0.0
        let dsc = 180.0
        let result = WheelGeometry.mundaneAngle(longitude: dsc, ascendantLongitude: asc)
        #expect(result == 270.0)
    }

    @Test("mundaneAngle: negatief tussenresultaat wordt gecorrigeerd naar 0..<360")
    func testMundaneAngleNegativeWraps() {
        // longitude=0, asc=180 → 0 - 180 + 90 = -90 → moet 270 worden
        let result = WheelGeometry.mundaneAngle(longitude: 0, ascendantLongitude: 180)
        #expect(result == 270.0)
    }

    @Test("mundaneAngle: waarde boven 360 wordt teruggebracht naar 0..<360")
    func testMundaneAngleWrapsAbove360() {
        // longitude=350, asc=10 → 350 - 10 + 90 = 430 → 70
        let result = WheelGeometry.mundaneAngle(longitude: 350, ascendantLongitude: 10)
        #expect(result == 70.0)
    }

    // MARK: - signOffset()

    @Test("signOffset: ascendant op 0° → offset is 30°")
    func testSignOffsetAt0() {
        let result = WheelGeometry.signOffset(ascendantLongitude: 0)
        #expect(result == 30.0)
    }

    @Test("signOffset: ascendant halverwege teken (15°) → offset is 15°")
    func testSignOffsetAt15() {
        let result = WheelGeometry.signOffset(ascendantLongitude: 15)
        #expect(result == 15.0)
    }

    @Test("signOffset: ascendant precies op tekengrens (30°) → offset is 30°")
    func testSignOffsetAt30() {
        let result = WheelGeometry.signOffset(ascendantLongitude: 30)
        #expect(result == 30.0)
    }

    @Test("signOffset: ascendant op 29° → offset is 1°")
    func testSignOffsetAt29() {
        let result = WheelGeometry.signOffset(ascendantLongitude: 29)
        #expect(result == 1.0)
    }

    @Test("signOffset: ascendant op 359° (359 % 30 = 29) → offset is 1°")
    func testSignOffsetAt359() {
        let result = WheelGeometry.signOffset(ascendantLongitude: 359)
        #expect(result == 1.0)
    }

    // MARK: - normalise()

    @Test("normalise: waarde in 0..<360 blijft ongewijzigd")
    func testNormaliseInRange() {
        #expect(WheelGeometry.normalise(90.0)  == 90.0)
        #expect(WheelGeometry.normalise(0.0)   == 0.0)
        #expect(WheelGeometry.normalise(359.0) == 359.0)
    }

    @Test("normalise: 360 wordt 0")
    func testNormalise360() {
        #expect(WheelGeometry.normalise(360.0) == 0.0)
    }

    @Test("normalise: waarden boven 360 worden teruggebracht")
    func testNormaliseAbove360() {
        #expect(WheelGeometry.normalise(450.0) == 90.0)
        #expect(WheelGeometry.normalise(720.0) == 0.0)
    }

    @Test("normalise: negatieve waarden worden gecorrigeerd naar 0..<360")
    func testNormaliseNegative() {
        #expect(WheelGeometry.normalise(-90.0)  == 270.0)
        #expect(WheelGeometry.normalise(-1.0)   == 359.0)
        #expect(WheelGeometry.normalise(-360.0) == 0.0)
    }
}
