//
//  MathExtra.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 03/01/2026.
//

import Foundation

/// Several mathematical functions that are not covered by the standard Math library
struct MathExtra {
    /// Convert radians to degrees
    static func radToDeg(_ radians: Double) -> Double {
        return 180.0 / .pi * radians
    }
    
    /// Convert degrees to radians
    static func degToRad(_ degrees: Double) -> Double {
        return .pi / 180.0 * degrees
    }
    
    /// Convert rectangular coordinates to polar coordinates
    static func rectangular2Polar(_ rectAng: RectAngCoordinates) -> PolarCoordinates {
        let x = rectAng.xCoord
        let y = rectAng.yCoord
        let z = rectAng.zCoord
        
        var r = sqrt(x * x + y * y + z * z)
        if r == 0 { r = Double.leastNormalMagnitude }
        var xSafe = x
        if x == 0 { xSafe = Double.leastNormalMagnitude }
        
        let phi = atan2(y, xSafe)
        let theta = asin(z / r)
        
        return PolarCoordinates(phiCoord: phi, thetaCoord: theta, rCoord: r)
    }
    
    /// Convert polar coordinates to rectangular coordinates
    static func polar2Rectangular(_ polar: PolarCoordinates) -> RectAngCoordinates {
        let phi = polar.phiCoord
        let theta = polar.thetaCoord
        let r = polar.rCoord
        
        let x = r * cos(theta) * cos(phi)
        let y = r * cos(theta) * sin(phi)
        let z = r * sin(theta)
        
        return RectAngCoordinates(xCoord: x, yCoord: y, zCoord: z)
    }
}
