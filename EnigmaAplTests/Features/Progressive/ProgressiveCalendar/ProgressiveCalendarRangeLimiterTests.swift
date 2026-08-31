// ProgressiveCalendarRangeLimiterTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct ProgressiveCalendarRangeLimiterTests {

    private let tropicalYear = 365.242199074

    @Test("ProgressiveCalendarRangeLimiter: no matching rule falls back to 125 years")
    func testDefaultLimit() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .transit, factors: [.uranus, .neptune, .pluto])
        ]
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        #expect(abs(limit - 125.0 * tropicalYear) < 1e-6)
    }

    @Test("ProgressiveCalendarRangeLimiter: transit + Moon limits to 60 days")
    func testTransitMoon() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .transit, factors: [.moon])
        ]
        #expect(ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections) == 60.0)
    }

    @Test("ProgressiveCalendarRangeLimiter: transit + Mercury/Venus/Mars limits to 2 years")
    func testTransitInnerPlanets() {
        for factor: Factors in [.mercury, .venus, .mars] {
            let selections = [
                ProgressiveCalendarOrchestrator.Selection(technique: .transit, factors: [factor])
            ]
            let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
            #expect(abs(limit - 2.0 * tropicalYear) < 1e-6, "Factor \(factor) should yield the 2-year limit")
        }
    }

    @Test("ProgressiveCalendarRangeLimiter: transit + Jupiter/Saturn limits to 40 years")
    func testTransitJupiterSaturn() {
        for factor: Factors in [.jupiter, .saturn] {
            let selections = [
                ProgressiveCalendarOrchestrator.Selection(technique: .transit, factors: [factor])
            ]
            let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
            #expect(abs(limit - 40.0 * tropicalYear) < 1e-6, "Factor \(factor) should yield the 40-year limit")
        }
    }

    @Test("ProgressiveCalendarRangeLimiter: secondary directions + Moon limits to 60 years")
    func testSecondaryDirectionMoon() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .secondaryDirection, factors: [.moon])
        ]
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        #expect(abs(limit - 60.0 * tropicalYear) < 1e-6)
    }

    @Test("ProgressiveCalendarRangeLimiter: secondary directions without the Moon falls back to 125 years")
    func testSecondaryDirectionWithoutMoon() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .secondaryDirection, factors: [.sun, .jupiter])
        ]
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        #expect(abs(limit - 125.0 * tropicalYear) < 1e-6)
    }

    @Test("ProgressiveCalendarRangeLimiter: symbolic directions never restrict the range on their own")
    func testSymbolicDirectionAlone() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .symbolicDirection, factors: [.sun, .moon], symbolicKey: .oneDegree)
        ]
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        #expect(abs(limit - 125.0 * tropicalYear) < 1e-6)
    }

    @Test("ProgressiveCalendarRangeLimiter: the shortest matching limit always wins across multiple selections")
    func testShortestLimitWins() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .transit, factors: [.moon, .jupiter]),
            ProgressiveCalendarOrchestrator.Selection(technique: .secondaryDirection, factors: [.moon])
        ]
        // transit+Moon → 60 days; transit+Jupiter → 40y; secdir+Moon → 60y. Shortest: 60 days.
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        #expect(limit == 60.0)
    }

    @Test("ProgressiveCalendarRangeLimiter: transit + Venus and secondary directions + Moon — the 2-year limit wins over 60 years")
    func testTwoYearBeatsSixtyYears() {
        let selections = [
            ProgressiveCalendarOrchestrator.Selection(technique: .transit, factors: [.venus]),
            ProgressiveCalendarOrchestrator.Selection(technique: .secondaryDirection, factors: [.moon])
        ]
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        #expect(abs(limit - 2.0 * tropicalYear) < 1e-6)
    }

    @Test("ProgressiveCalendarRangeLimiter: empty selection falls back to 125 years")
    func testEmptySelection() {
        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: [])
        #expect(abs(limit - 125.0 * tropicalYear) < 1e-6)
    }
}
