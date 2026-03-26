// SpeedOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Determines the SpeedType for a celestial factor based on its current speed.
struct SpeedOrchestrator {

    /// Determines the speed type for a factor.
    /// - Parameters:
    ///   - speed: The current daily speed in decimal degrees (negative = retrograde).
    ///   - factor: The celestial factor.
    ///   - config: The calculation configuration containing stationary and slow percentages.
    /// - Returns: The corresponding SpeedType.
    func determine(speed: Double, for factor: Factors, config: CalculationConfig) -> SpeedType {
        let isRetrograde = speed < 0.0
        let absSpeed = abs(speed)

        guard let average = AverageSpeed.averageFor(factor) else {
            return isRetrograde ? .retrograde : .direct
        }

        let stationaryThreshold = average * Double(config.stationaryPercentage) / 100.0
        let slowThreshold = average * Double(config.slowPercentage) / 100.0

        if absSpeed <= stationaryThreshold {
            return isRetrograde ? .stationaryRetrograde : .stationaryDirect
        } else if absSpeed <= slowThreshold {
            return isRetrograde ? .slowRetrograde : .slow
        } else {
            return isRetrograde ? .retrograde : .direct
        }
    }
}
