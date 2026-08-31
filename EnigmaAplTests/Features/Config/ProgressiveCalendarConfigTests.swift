// ProgressiveCalendarConfigTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct ProgressiveCalendarConfigTests {

    @Test("ProgressiveCalendarConfig: default technique selection is transits + secondary directions, not symbolic")
    func testDefaultTechniqueSelection() {
        let config = ProgressiveCalendarConfig()
        #expect(config.useTransits == true)
        #expect(config.useSecondaryDirections == true)
        #expect(config.useSymbolicDirections == false)
    }

    @Test("ProgressiveCalendarConfig: default orbs are 1.0")
    func testDefaultOrbs() {
        let config = ProgressiveCalendarConfig()
        #expect(config.aspectOrb == 1.0)
        #expect(config.parallelOrb == 1.0)
        #expect(config.cuspOrb == 1.0)
    }

    @Test("ProgressiveCalendarConfig: default event-kind toggles are sensible (aspects/parallels/cusps/stations on, OOB/declination extremes and prog-to-prog off)")
    func testDefaultEventKindToggles() {
        let config = ProgressiveCalendarConfig()
        #expect(config.useAspectsToRadix == true)
        #expect(config.useParallelsToRadix == true)
        #expect(config.useCuspConjunctions == true)
        #expect(config.useRetrogradeDirectStations == true)
        #expect(config.useAspectsProgToProg == false)
        #expect(config.useParallelsProgToProg == false)
        #expect(config.useOobEnterExit == false)
        #expect(config.useDeclinationExtremes == false)
    }

    @Test("ProgressiveCalendarConfig: custom values are stored correctly")
    func testCustomInit() {
        let config = ProgressiveCalendarConfig(
            useTransits: false,
            useSymbolicDirections: true,
            transitFactors: [.sun],
            radixFactors: [.moon],
            aspects: [.conjunction],
            aspectOrb: 2.5,
            useOobEnterExit: true
        )
        #expect(config.useTransits == false)
        #expect(config.useSymbolicDirections == true)
        #expect(config.transitFactors == [.sun])
        #expect(config.radixFactors == [.moon])
        #expect(config.aspects == [.conjunction])
        #expect(config.aspectOrb == 2.5)
        #expect(config.useOobEnterExit == true)
    }

    @Test("ProgressiveCalendarConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = ProgressiveCalendarConfig(
            useSymbolicDirections: true,
            symbolicDirectionFactors: [.sun, .moon],
            symbolicKey: .trueSun,
            aspects: [.conjunction, .square],
            parallelOrb: 0.5
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ProgressiveCalendarConfig.self, from: data)
        #expect(decoded.useSymbolicDirections == original.useSymbolicDirections)
        #expect(decoded.symbolicDirectionFactors == original.symbolicDirectionFactors)
        #expect(decoded.symbolicKey == original.symbolicKey)
        #expect(decoded.aspects == original.aspects)
        #expect(decoded.parallelOrb == original.parallelOrb)
    }

    @Test("ProgressionsConfig: progressiveCalendar sub-config round-trips through the container")
    func testProgressionsConfigContainsProgressiveCalendar() throws {
        let original = ProgressionsConfig(progressiveCalendar: ProgressiveCalendarConfig(aspectOrb: 3.0))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ProgressionsConfig.self, from: data)
        #expect(decoded.progressiveCalendar.aspectOrb == 3.0)
    }
}
