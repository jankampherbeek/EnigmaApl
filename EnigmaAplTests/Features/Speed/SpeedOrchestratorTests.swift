// SpeedOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct SpeedOrchestratorTests {

    private let orchestrator = SpeedOrchestrator()

    // Mars is used as the reference planet throughout most tests.
    // AverageSpeed.averageFor(.mars) = 0.5242 °/day
    // Default config: stationaryPercentage=10, slowPercentage=20
    //   stationaryThreshold = 0.5242 × 0.10 = 0.05242
    //   slowThreshold        = 0.5242 × 0.20 = 0.10484

    // MARK: - Direct motion

    @Test("SpeedOrchestrator: normal direct speed returns .direct")
    func testNormalDirect() {
        // 0.40 > slowThreshold (0.10484) → .direct
        let result = orchestrator.determine(speed: 0.40, for: .mars, config: config())
        #expect(result == .direct)
    }

    @Test("SpeedOrchestrator: slow direct speed returns .slow")
    func testSlowDirect() {
        // 0.08 > stationaryThreshold (0.05242) and ≤ slowThreshold (0.10484) → .slow
        let result = orchestrator.determine(speed: 0.08, for: .mars, config: config())
        #expect(result == .slow)
    }

    @Test("SpeedOrchestrator: very slow direct speed returns .stationaryDirect")
    func testStationaryDirect() {
        // 0.02 ≤ stationaryThreshold (0.05242) → .stationaryDirect
        let result = orchestrator.determine(speed: 0.02, for: .mars, config: config())
        #expect(result == .stationaryDirect)
    }

    @Test("SpeedOrchestrator: speed exactly zero returns .stationaryDirect")
    func testZeroSpeedIsStationaryDirect() {
        // 0.0 ≤ stationaryThreshold → .stationaryDirect (not retrograde)
        let result = orchestrator.determine(speed: 0.0, for: .mars, config: config())
        #expect(result == .stationaryDirect)
    }

    // MARK: - Retrograde motion

    @Test("SpeedOrchestrator: normal retrograde speed returns .retrograde")
    func testNormalRetrograde() {
        // abs(-0.40) = 0.40 > slowThreshold → .retrograde
        let result = orchestrator.determine(speed: -0.40, for: .mars, config: config())
        #expect(result == .retrograde)
    }

    @Test("SpeedOrchestrator: slow retrograde speed returns .slowRetrograde")
    func testSlowRetrograde() {
        // abs(-0.08) = 0.08 > stationaryThreshold and ≤ slowThreshold → .slowRetrograde
        let result = orchestrator.determine(speed: -0.08, for: .mars, config: config())
        #expect(result == .slowRetrograde)
    }

    @Test("SpeedOrchestrator: very slow retrograde speed returns .stationaryRetrograde")
    func testStationaryRetrograde() {
        // abs(-0.02) = 0.02 ≤ stationaryThreshold → .stationaryRetrograde
        let result = orchestrator.determine(speed: -0.02, for: .mars, config: config())
        #expect(result == .stationaryRetrograde)
    }

    // MARK: - Boundaries around stationaryThreshold

    @Test("SpeedOrchestrator: direct speed exactly at stationaryThreshold returns .stationaryDirect")
    func testExactlyAtStationaryThresholdDirect() {
        // 0.05242 ≤ 0.05242 → .stationaryDirect
        let result = orchestrator.determine(speed: 0.05242, for: .mars, config: config())
        #expect(result == .stationaryDirect)
    }

    @Test("SpeedOrchestrator: direct speed just above stationaryThreshold returns .slow")
    func testJustAboveStationaryThresholdDirect() {
        // 0.05243 > 0.05242 and ≤ 0.10484 → .slow
        let result = orchestrator.determine(speed: 0.05243, for: .mars, config: config())
        #expect(result == .slow)
    }

    @Test("SpeedOrchestrator: retrograde speed exactly at stationaryThreshold returns .stationaryRetrograde")
    func testExactlyAtStationaryThresholdRetrograde() {
        let result = orchestrator.determine(speed: -0.05242, for: .mars, config: config())
        #expect(result == .stationaryRetrograde)
    }

    @Test("SpeedOrchestrator: retrograde speed just above stationaryThreshold returns .slowRetrograde")
    func testJustAboveStationaryThresholdRetrograde() {
        let result = orchestrator.determine(speed: -0.05243, for: .mars, config: config())
        #expect(result == .slowRetrograde)
    }

    // MARK: - Boundaries around slowThreshold

    @Test("SpeedOrchestrator: direct speed exactly at slowThreshold returns .slow")
    func testExactlyAtSlowThresholdDirect() {
        // 0.10484 ≤ 0.10484 → .slow
        let result = orchestrator.determine(speed: 0.10484, for: .mars, config: config())
        #expect(result == .slow)
    }

    @Test("SpeedOrchestrator: direct speed just above slowThreshold returns .direct")
    func testJustAboveSlowThresholdDirect() {
        // 0.10485 > 0.10484 → .direct
        let result = orchestrator.determine(speed: 0.10485, for: .mars, config: config())
        #expect(result == .direct)
    }

    @Test("SpeedOrchestrator: retrograde speed exactly at slowThreshold returns .slowRetrograde")
    func testExactlyAtSlowThresholdRetrograde() {
        let result = orchestrator.determine(speed: -0.10484, for: .mars, config: config())
        #expect(result == .slowRetrograde)
    }

    @Test("SpeedOrchestrator: retrograde speed just above slowThreshold returns .retrograde")
    func testJustAboveSlowThresholdRetrograde() {
        let result = orchestrator.determine(speed: -0.10485, for: .mars, config: config())
        #expect(result == .retrograde)
    }

    // MARK: - Factors without average speed

    @Test("SpeedOrchestrator: factor without average speed and positive speed returns .direct")
    func testNoAverageSpeedDirect() {
        // northNode has no AverageSpeed entry → guard triggers → .direct
        let result = orchestrator.determine(speed: 0.05, for: .northNode, config: config())
        #expect(result == .direct)
    }

    @Test("SpeedOrchestrator: factor without average speed and negative speed returns .retrograde")
    func testNoAverageSpeedRetrograde() {
        let result = orchestrator.determine(speed: -0.05, for: .northNode, config: config())
        #expect(result == .retrograde)
    }

    @Test("SpeedOrchestrator: factor without average speed and zero speed returns .direct")
    func testNoAverageSpeedZero() {
        // speed = 0.0 → isRetrograde = false → .direct
        let result = orchestrator.determine(speed: 0.0, for: .northNode, config: config())
        #expect(result == .direct)
    }

    // MARK: - Custom config

    @Test("SpeedOrchestrator: higher stationaryPercentage widens the stationary zone")
    func testCustomStationaryPercentage() {
        // stationaryPct=50: stationaryThreshold = 0.5242 × 0.50 = 0.2621
        // Speed 0.20: with defaults → .direct; with pct=50 → .stationaryDirect
        let resultDefault = orchestrator.determine(speed: 0.20, for: .mars, config: config())
        let resultCustom  = orchestrator.determine(speed: 0.20, for: .mars, config: config(stationaryPct: 50, slowPct: 80))
        #expect(resultDefault == .direct)
        #expect(resultCustom == .stationaryDirect)
    }

    @Test("SpeedOrchestrator: higher slowPercentage widens the slow zone")
    func testCustomSlowPercentage() {
        // slowPct=80: slowThreshold = 0.5242 × 0.80 = 0.41936
        // Speed 0.30: with defaults → .direct; with pct=80 → .slow
        let resultDefault = orchestrator.determine(speed: 0.30, for: .mars, config: config())
        let resultCustom  = orchestrator.determine(speed: 0.30, for: .mars, config: config(slowPct: 80))
        #expect(resultDefault == .direct)
        #expect(resultCustom == .slow)
    }

    // MARK: - All planets with average speed

    @Test("SpeedOrchestrator: all planets with average speed return .slow at 15% of average")
    func testAllPlanetsSlowAt15Percent() {
        // 15% of average speed lies between stationaryThreshold (10%) and slowThreshold (20%)
        let planets: [(Factors, Double)] = [
            (.sun,     0.985555  * 0.15),
            (.moon,    13.17666  * 0.15),
            (.mercury, 1.3833    * 0.15),
            (.venus,   1.2       * 0.15),
            (.mars,    0.5242    * 0.15),
            (.jupiter, 0.0831    * 0.15),
            (.saturn,  0.0336    * 0.15),
            (.uranus,  0.026666  * 0.15),
            (.neptune, 0.006668  * 0.15),
            (.pluto,   0.0041666 * 0.15)
        ]
        for (factor, speed) in planets {
            let result = orchestrator.determine(speed: speed, for: factor, config: config())
            #expect(result == .slow, "Expected .slow for \(factor) at speed \(speed)")
        }
    }

    @Test("SpeedOrchestrator: all planets with average speed return .stationaryDirect at 5% of average")
    func testAllPlanetsStationaryAt5Percent() {
        // 5% of average speed is below stationaryThreshold (10%)
        let planets: [(Factors, Double)] = [
            (.sun,     0.985555  * 0.05),
            (.moon,    13.17666  * 0.05),
            (.mercury, 1.3833    * 0.05),
            (.venus,   1.2       * 0.05),
            (.mars,    0.5242    * 0.05),
            (.jupiter, 0.0831    * 0.05),
            (.saturn,  0.0336    * 0.05),
            (.uranus,  0.026666  * 0.05),
            (.neptune, 0.006668  * 0.05),
            (.pluto,   0.0041666 * 0.05)
        ]
        for (factor, speed) in planets {
            let result = orchestrator.determine(speed: speed, for: factor, config: config())
            #expect(result == .stationaryDirect, "Expected .stationaryDirect for \(factor) at speed \(speed)")
        }
    }

    // MARK: - Helpers

    private func config(stationaryPct: Int = 10, slowPct: Int = 20) -> CalculationConfig {
        CalculationConfig(stationaryPercentage: stationaryPct, slowPercentage: slowPct)
    }
}
