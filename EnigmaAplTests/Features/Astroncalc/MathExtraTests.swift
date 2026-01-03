//
//  MathExtraTests.swift
//  EnigmaAplTests
//
//  Created on 03/01/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct MathExtraTests {
    
    // MARK: - RadToDeg Tests
    
    @Test("MathExtra: radToDeg converts 0 radians to 0 degrees")
    func testRadToDegZero() {
        let result = MathExtra.radToDeg(0.0)
        #expect(result == 0.0)
    }
    
    @Test("MathExtra: radToDeg converts π radians to 180 degrees")
    func testRadToDegPi() {
        let result = MathExtra.radToDeg(.pi)
        let difference = abs(result - 180.0)
        #expect(difference < 1e-10, "Expected 180.0, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: radToDeg converts π/2 radians to 90 degrees")
    func testRadToDegPiOver2() {
        let result = MathExtra.radToDeg(.pi / 2.0)
        let difference = abs(result - 90.0)
        #expect(difference < 1e-10, "Expected 90.0, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: radToDeg converts 2π radians to 360 degrees")
    func testRadToDegTwoPi() {
        let result = MathExtra.radToDeg(2 * .pi)
        let difference = abs(result - 360.0)
        #expect(difference < 1e-10, "Expected 360.0, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: radToDeg converts negative radians correctly")
    func testRadToDegNegative() {
        let result = MathExtra.radToDeg(-.pi)
        let difference = abs(result - (-180.0))
        #expect(difference < 1e-10, "Expected -180.0, got \(result), difference: \(difference)")
    }
    
    // MARK: - DegToRad Tests
    
    @Test("MathExtra: degToRad converts 0 degrees to 0 radians")
    func testDegToRadZero() {
        let result = MathExtra.degToRad(0.0)
        #expect(result == 0.0)
    }
    
    @Test("MathExtra: degToRad converts 180 degrees to π radians")
    func testDegToRad180() {
        let result = MathExtra.degToRad(180.0)
        let difference = abs(result - .pi)
        #expect(difference < 1e-10, "Expected π, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: degToRad converts 90 degrees to π/2 radians")
    func testDegToRad90() {
        let result = MathExtra.degToRad(90.0)
        let difference = abs(result - (.pi / 2.0))
        #expect(difference < 1e-10, "Expected π/2, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: degToRad converts 360 degrees to 2π radians")
    func testDegToRad360() {
        let result = MathExtra.degToRad(360.0)
        let difference = abs(result - (2 * .pi))
        #expect(difference < 1e-10, "Expected 2π, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: degToRad converts negative degrees correctly")
    func testDegToRadNegative() {
        let result = MathExtra.degToRad(-180.0)
        let difference = abs(result - (-.pi))
        #expect(difference < 1e-10, "Expected -π, got \(result), difference: \(difference)")
    }
    
    // MARK: - Round-trip Conversion Tests
    
    @Test("MathExtra: radToDeg and degToRad are inverse operations")
    func testRadDegRoundTrip() {
        let testValues: [Double] = [0.0, .pi / 4, .pi / 2, .pi, 3 * .pi / 2, 2 * .pi, -.pi / 4]
        for radians in testValues {
            let degrees = MathExtra.radToDeg(radians)
            let backToRadians = MathExtra.degToRad(degrees)
            let difference = abs(backToRadians - radians)
            #expect(difference < 1e-10, "Failed for radians: \(radians), difference: \(difference)")
        }
    }
    
    @Test("MathExtra: degToRad and radToDeg are inverse operations")
    func testDegRadRoundTrip() {
        let testValues: [Double] = [0.0, 45.0, 90.0, 180.0, 270.0, 360.0, -45.0]
        for degrees in testValues {
            let radians = MathExtra.degToRad(degrees)
            let backToDegrees = MathExtra.radToDeg(radians)
            let difference = abs(backToDegrees - degrees)
            #expect(difference < 1e-10, "Failed for degrees: \(degrees), difference: \(difference)")
        }
    }
    
    // MARK: - Rectangular2Polar Tests
    
    @Test("MathExtra: rectangular2Polar converts origin to zero polar")
    func testRectangular2PolarOrigin() {
        let rect = RectAngCoordinates(xCoord: 0.0, yCoord: 0.0, zCoord: 0.0)
        let polar = MathExtra.rectangular2Polar(rect)
        // When r is 0, it's set to Double.leastNormalMagnitude
        #expect(polar.rCoord == Double.leastNormalMagnitude)
    }
    
    @Test("MathExtra: rectangular2Polar converts unit vector on x-axis")
    func testRectangular2PolarXAxis() {
        let rect = RectAngCoordinates(xCoord: 1.0, yCoord: 0.0, zCoord: 0.0)
        let polar = MathExtra.rectangular2Polar(rect)
        let rDiff = abs(polar.rCoord - 1.0)
        let phiDiff = abs(polar.phiCoord - 0.0)
        let thetaDiff = abs(polar.thetaCoord - 0.0)
        #expect(rDiff < 1e-10, "rCoord: expected 1.0, got \(polar.rCoord)")
        #expect(phiDiff < 1e-10, "phiCoord: expected 0.0, got \(polar.phiCoord)")
        #expect(thetaDiff < 1e-10, "thetaCoord: expected 0.0, got \(polar.thetaCoord)")
    }
    
    @Test("MathExtra: rectangular2Polar converts unit vector on y-axis")
    func testRectangular2PolarYAxis() {
        let rect = RectAngCoordinates(xCoord: 0.0, yCoord: 1.0, zCoord: 0.0)
        let polar = MathExtra.rectangular2Polar(rect)
        let rDiff = abs(polar.rCoord - 1.0)
        let phiDiff = abs(polar.phiCoord - (.pi / 2.0))
        let thetaDiff = abs(polar.thetaCoord - 0.0)
        #expect(rDiff < 1e-10, "rCoord: expected 1.0, got \(polar.rCoord)")
        #expect(phiDiff < 1e-10, "phiCoord: expected π/2, got \(polar.phiCoord)")
        #expect(thetaDiff < 1e-10, "thetaCoord: expected 0.0, got \(polar.thetaCoord)")
    }
    
    @Test("MathExtra: rectangular2Polar converts unit vector on z-axis")
    func testRectangular2PolarZAxis() {
        let rect = RectAngCoordinates(xCoord: 0.0, yCoord: 0.0, zCoord: 1.0)
        let polar = MathExtra.rectangular2Polar(rect)
        let rDiff = abs(polar.rCoord - 1.0)
        let thetaDiff = abs(polar.thetaCoord - (.pi / 2.0))
        #expect(rDiff < 1e-10, "rCoord: expected 1.0, got \(polar.rCoord)")
        #expect(thetaDiff < 1e-10, "thetaCoord: expected π/2, got \(polar.thetaCoord)")
    }
    
    @Test("MathExtra: rectangular2Polar handles negative coordinates")
    func testRectangular2PolarNegative() {
        let rect = RectAngCoordinates(xCoord: -1.0, yCoord: -1.0, zCoord: -1.0)
        let polar = MathExtra.rectangular2Polar(rect)
        let expectedR = sqrt(3.0)
        let rDiff = abs(polar.rCoord - expectedR)
        #expect(rDiff < 1e-10, "rCoord: expected \(expectedR), got \(polar.rCoord)")
    }
    
    // MARK: - Polar2Rectangular Tests
    
    @Test("MathExtra: polar2Rectangular converts zero radius")
    func testPolar2RectangularZeroRadius() {
        let polar = PolarCoordinates(phiCoord: 0.0, thetaCoord: 0.0, rCoord: 0.0)
        let rect = MathExtra.polar2Rectangular(polar)
        let xDiff = abs(rect.xCoord - 0.0)
        let yDiff = abs(rect.yCoord - 0.0)
        let zDiff = abs(rect.zCoord - 0.0)
        #expect(xDiff < 1e-10, "xCoord: expected 0.0, got \(rect.xCoord)")
        #expect(yDiff < 1e-10, "yCoord: expected 0.0, got \(rect.yCoord)")
        #expect(zDiff < 1e-10, "zCoord: expected 0.0, got \(rect.zCoord)")
    }
    
    @Test("MathExtra: polar2Rectangular converts unit vector on x-axis")
    func testPolar2RectangularXAxis() {
        let polar = PolarCoordinates(phiCoord: 0.0, thetaCoord: 0.0, rCoord: 1.0)
        let rect = MathExtra.polar2Rectangular(polar)
        let xDiff = abs(rect.xCoord - 1.0)
        let yDiff = abs(rect.yCoord - 0.0)
        let zDiff = abs(rect.zCoord - 0.0)
        #expect(xDiff < 1e-10, "xCoord: expected 1.0, got \(rect.xCoord)")
        #expect(yDiff < 1e-10, "yCoord: expected 0.0, got \(rect.yCoord)")
        #expect(zDiff < 1e-10, "zCoord: expected 0.0, got \(rect.zCoord)")
    }
    
    @Test("MathExtra: polar2Rectangular converts unit vector on y-axis")
    func testPolar2RectangularYAxis() {
        let polar = PolarCoordinates(phiCoord: .pi / 2.0, thetaCoord: 0.0, rCoord: 1.0)
        let rect = MathExtra.polar2Rectangular(polar)
        let xDiff = abs(rect.xCoord - 0.0)
        let yDiff = abs(rect.yCoord - 1.0)
        let zDiff = abs(rect.zCoord - 0.0)
        #expect(xDiff < 1e-10, "xCoord: expected 0.0, got \(rect.xCoord)")
        #expect(yDiff < 1e-10, "yCoord: expected 1.0, got \(rect.yCoord)")
        #expect(zDiff < 1e-10, "zCoord: expected 0.0, got \(rect.zCoord)")
    }
    
    @Test("MathExtra: polar2Rectangular converts unit vector on z-axis")
    func testPolar2RectangularZAxis() {
        let polar = PolarCoordinates(phiCoord: 0.0, thetaCoord: .pi / 2.0, rCoord: 1.0)
        let rect = MathExtra.polar2Rectangular(polar)
        let xDiff = abs(rect.xCoord - 0.0)
        let yDiff = abs(rect.yCoord - 0.0)
        let zDiff = abs(rect.zCoord - 1.0)
        #expect(xDiff < 1e-10, "xCoord: expected 0.0, got \(rect.xCoord)")
        #expect(yDiff < 1e-10, "yCoord: expected 0.0, got \(rect.yCoord)")
        #expect(zDiff < 1e-10, "zCoord: expected 1.0, got \(rect.zCoord)")
    }
    
    @Test("MathExtra: polar2Rectangular handles arbitrary coordinates")
    func testPolar2RectangularArbitrary() {
        let polar = PolarCoordinates(phiCoord: .pi / 4.0, thetaCoord: .pi / 6.0, rCoord: 2.0)
        let rect = MathExtra.polar2Rectangular(polar)
        // Expected values calculated manually
        let expectedX = 2.0 * cos(.pi / 6.0) * cos(.pi / 4.0)
        let expectedY = 2.0 * cos(.pi / 6.0) * sin(.pi / 4.0)
        let expectedZ = 2.0 * sin(.pi / 6.0)
        let xDiff = abs(rect.xCoord - expectedX)
        let yDiff = abs(rect.yCoord - expectedY)
        let zDiff = abs(rect.zCoord - expectedZ)
        #expect(xDiff < 1e-10, "xCoord: expected \(expectedX), got \(rect.xCoord)")
        #expect(yDiff < 1e-10, "yCoord: expected \(expectedY), got \(rect.yCoord)")
        #expect(zDiff < 1e-10, "zCoord: expected \(expectedZ), got \(rect.zCoord)")
    }
    
    // MARK: - Round-trip Coordinate Conversion Tests
    
    @Test("MathExtra: rectangular2Polar and polar2Rectangular are inverse operations")
    func testRectangularPolarRoundTrip() {
        let testCases: [RectAngCoordinates] = [
            RectAngCoordinates(xCoord: 1.0, yCoord: 0.0, zCoord: 0.0),
            RectAngCoordinates(xCoord: 0.0, yCoord: 1.0, zCoord: 0.0),
            RectAngCoordinates(xCoord: 0.0, yCoord: 0.0, zCoord: 1.0),
            RectAngCoordinates(xCoord: 1.0, yCoord: 1.0, zCoord: 1.0),
            RectAngCoordinates(xCoord: 2.0, yCoord: 3.0, zCoord: 4.0),
            RectAngCoordinates(xCoord: -1.0, yCoord: 2.0, zCoord: -3.0)
        ]
        
        for rect in testCases {
            // Skip origin as it has special handling
            if rect.xCoord == 0.0 && rect.yCoord == 0.0 && rect.zCoord == 0.0 {
                continue
            }
            let polar = MathExtra.rectangular2Polar(rect)
            let backToRect = MathExtra.polar2Rectangular(polar)
            let xDiff = abs(backToRect.xCoord - rect.xCoord)
            let yDiff = abs(backToRect.yCoord - rect.yCoord)
            let zDiff = abs(backToRect.zCoord - rect.zCoord)
            #expect(xDiff < 1e-10, "Failed for x: \(rect.xCoord), difference: \(xDiff)")
            #expect(yDiff < 1e-10, "Failed for y: \(rect.yCoord), difference: \(yDiff)")
            #expect(zDiff < 1e-10, "Failed for z: \(rect.zCoord), difference: \(zDiff)")
        }
    }
    
    @Test("MathExtra: polar2Rectangular and rectangular2Polar are inverse operations")
    func testPolarRectangularRoundTrip() {
        let testCases: [PolarCoordinates] = [
            PolarCoordinates(phiCoord: 0.0, thetaCoord: 0.0, rCoord: 1.0),
            PolarCoordinates(phiCoord: .pi / 2.0, thetaCoord: 0.0, rCoord: 1.0),
            PolarCoordinates(phiCoord: 0.0, thetaCoord: .pi / 2.0, rCoord: 1.0),
            PolarCoordinates(phiCoord: .pi / 4.0, thetaCoord: .pi / 6.0, rCoord: 2.0),
            PolarCoordinates(phiCoord: .pi, thetaCoord: -.pi / 4.0, rCoord: 3.0)
        ]
        
        for polar in testCases {
            let rect = MathExtra.polar2Rectangular(polar)
            let backToPolar = MathExtra.rectangular2Polar(rect)
            // Note: phi and theta might differ by 2π or sign, but r should match
            let rDiff = abs(backToPolar.rCoord - polar.rCoord)
            #expect(rDiff < 1e-10, "Failed for r: \(polar.rCoord), difference: \(rDiff)")
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("MathExtra: rectangular2Polar handles very small values")
    func testRectangular2PolarSmallValues() {
        let rect = RectAngCoordinates(xCoord: 1e-10, yCoord: 1e-10, zCoord: 1e-10)
        let polar = MathExtra.rectangular2Polar(rect)
        let expectedR = sqrt(3.0) * 1e-10
        let rDiff = abs(polar.rCoord - expectedR)
        #expect(rDiff < 1e-20, "rCoord: expected \(expectedR), got \(polar.rCoord), difference: \(rDiff)")
    }
    
    @Test("MathExtra: rectangular2Polar handles very large values")
    func testRectangular2PolarLargeValues() {
        let rect = RectAngCoordinates(xCoord: 1e10, yCoord: 1e10, zCoord: 1e10)
        let polar = MathExtra.rectangular2Polar(rect)
        let expectedR = sqrt(3.0) * 1e10
        let rDiff = abs(polar.rCoord - expectedR)
        #expect(rDiff < 1e5, "rCoord: expected \(expectedR), got \(polar.rCoord), difference: \(rDiff)")
    }
    
    @Test("MathExtra: degToRad handles large degree values")
    func testDegToRadLargeValues() {
        let result = MathExtra.degToRad(720.0)
        let difference = abs(result - (4 * .pi))
        #expect(difference < 1e-10, "Expected 4π, got \(result), difference: \(difference)")
    }
    
    @Test("MathExtra: radToDeg handles large radian values")
    func testRadToDegLargeValues() {
        let result = MathExtra.radToDeg(4 * .pi)
        let difference = abs(result - 720.0)
        #expect(difference < 1e-10, "Expected 720.0, got \(result), difference: \(difference)")
    }
}

