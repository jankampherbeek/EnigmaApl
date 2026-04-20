// LocationOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

// MARK: - Country tests

@MainActor
struct LocationCountryTests {

    private let orch: LocationOrchestrator

    init() throws {
        orch = try LocationOrchestrator(seWrapper: SEWrapperTestCoordinator.shared.getSEWrapper())
    }

    @Test("allCountries: returns 252 countries for English")
    func testAllCountriesCount() async throws {
        let countries = try orch.allCountries(lang: "en")
        #expect(countries.count == 252, "Expected 252 countries, got \(countries.count)")
    }

    @Test("allCountries: sorted alphabetically")
    func testAllCountriesSorted() async throws {
        let countries = try orch.allCountries(lang: "en")
        let names = countries.map(\.name)
        #expect(names == names.sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }),
                "Countries are not in alphabetical order")
    }

    @Test("allCountries: Netherlands is present with correct code in English")
    func testNetherlandsPresent() async throws {
        let countries = try orch.allCountries(lang: "en")
        let nl = countries.first { $0.code == "NL" }
        #expect(nl != nil, "NL not found in country list")
        #expect(nl?.name == "The Netherlands", "Expected 'The Netherlands', got '\(nl?.name ?? "nil")'")
    }

    @Test("allCountries: Netherlands has Dutch name in nl")
    func testNetherlandsDutch() async throws {
        let countries = try orch.allCountries(lang: "nl")
        let nl = countries.first { $0.code == "NL" }
        #expect(nl != nil, "NL not found in Dutch country list")
        #expect(nl?.name == "Nederland", "Expected 'Nederland', got '\(nl?.name ?? "nil")'")
    }

    @Test("countries: pattern 'Ger' matches Germany in English")
    func testCountrySearch() async throws {
        let results = try orch.countries(lang: "en", pattern: "Ger")
        #expect(results.contains { $0.code == "DE" }, "Expected Germany in results for 'Ger'")
    }
}

// MARK: - City tests

@MainActor
struct LocationCityTests {

    private let orch: LocationOrchestrator

    init() throws {
        orch = try LocationOrchestrator(seWrapper: SEWrapperTestCoordinator.shared.getSEWrapper())
    }

    @Test("cities: Netherlands returns 7145 cities")
    func testCitiesNLCount() async throws {
        let cities = try orch.cities(countryCode: "NL")
        #expect(cities.count == 7145, "Expected 7145 NL cities, got \(cities.count)")
    }

    @Test("cities: Enschede has timezone Europe/Amsterdam")
    func testEnschedeTimezone() async throws {
        let cities = try orch.cities(countryCode: "NL")
        let enschede = cities.first { $0.name.hasPrefix("Enschede") }
        #expect(enschede != nil, "Enschede not found in NL cities")
        #expect(enschede?.timezoneName == "Europe/Amsterdam",
                "Expected Europe/Amsterdam, got '\(enschede?.timezoneName ?? "nil")'")
    }

    @Test("cities: wildcard A* returns only cities starting with A")
    func testWildcardPrefix() async throws {
        let cities = try orch.cities(countryCode: "NL", pattern: "A*")
        #expect(cities.count == 254, "Expected 254 NL cities starting with A, got \(cities.count)")
        for city in cities {
            #expect(city.name.uppercased().hasPrefix("A"),
                    "City '\(city.name)' does not start with A")
        }
    }

    @Test("cities: wildcard *dam* returns cities with 'dam' in name")
    func testWildcardContainsDam() async throws {
        // Stored names include region: "Zaandam (North Holland)" — use *dam* to match anywhere.
        let cities = try orch.cities(countryCode: "NL", pattern: "*dam*")
        #expect(!cities.isEmpty, "Expected at least one NL city containing 'dam'")
        for city in cities {
            #expect(city.name.lowercased().contains("dam"),
                    "City '\(city.name)' does not contain 'dam'")
        }
    }

    @Test("cities: wildcard *ster* finds cities containing 'ster'")
    func testWildcardContains() async throws {
        let cities = try orch.cities(countryCode: "NL", pattern: "*ster*")
        #expect(!cities.isEmpty, "Expected at least one NL city containing 'ster'")
        for city in cities {
            #expect(city.name.lowercased().contains("ster"),
                    "City '\(city.name)' does not contain 'ster'")
        }
    }

    @Test("cities: pattern with no matches returns empty list")
    func testWildcardNoMatch() async throws {
        let cities = try orch.cities(countryCode: "NL", pattern: "ZZZZZ*")
        #expect(cities.isEmpty, "Expected empty result for pattern 'ZZZZZ*'")
    }

    @Test("cities: city has valid coordinates")
    func testCityCoordinates() async throws {
        let cities = try orch.cities(countryCode: "NL")
        let amsterdam = cities.first { $0.name.hasPrefix("Amsterdam") }
        guard let city = amsterdam else {
            Issue.record("Amsterdam not found in NL cities")
            return
        }
        #expect(city.latitude > 50.0 && city.latitude < 54.0,
                "Amsterdam latitude \(city.latitude) out of expected range")
        #expect(city.longitude > 3.0 && city.longitude < 8.0,
                "Amsterdam longitude \(city.longitude) out of expected range")
    }

    @Test("cities: empty country code returns empty list")
    func testEmptyCountryCode() async throws {
        let cities = try orch.cities(countryCode: "XX")
        #expect(cities.isEmpty, "Expected empty result for unknown country code 'XX'")
    }
}

// MARK: - DayDefinitionResolver tests

struct DayDefinitionResolverTests {

    @Test("resolveIana: fixed day returns that day")
    func testFixedDay() {
        let result = DayDefinitionResolver.resolveIana(expression: "14", year: 2025, month: 3)
        #expect(result == 14, "Expected 14, got \(String(describing: result))")
    }

    @Test("resolveIana: 6>=1 in Feb 2025 returns 2 (first Sunday on or after 1)")
    func testGteSunday() {
        // Mon=0..Sun=6: Feb 2025 day 1 = Sat(5), day 2 = Sun(6) → first Sunday on or after 1 is 2
        let result = DayDefinitionResolver.resolveIana(expression: "6>=1", year: 2025, month: 2)
        #expect(result == 2, "Expected 2, got \(String(describing: result))")
    }

    @Test("resolveIana: 5>=2 in May 2026 returns 2 (first Saturday on or after 2)")
    func testGteSaturday() {
        // Mon=0..Sun=6: May 2026 day 1 = Fri(4), day 2 = Sat(5) → first Saturday on or after 2 is 2
        let result = DayDefinitionResolver.resolveIana(expression: "5>=2", year: 2026, month: 5)
        #expect(result == 2, "Expected 2, got \(String(describing: result))")
    }

    @Test("resolveIana: 5>=3 in May 2026 returns 9 (first Saturday on or after 3)")
    func testGteSaturdayFrom3() {
        // May 2026: day 3 = Sun(6), next Saturday is day 9
        let result = DayDefinitionResolver.resolveIana(expression: "5>=3", year: 2026, month: 5)
        #expect(result == 9, "Expected 9, got \(String(describing: result))")
    }

    @Test("resolveIana: last2 in Feb 2025 returns 26 (last Wednesday)")
    func testLastWednesday() {
        // Mon=0..Sun=6: Wed=2; last Wednesday Feb 2025 = 26
        let result = DayDefinitionResolver.resolveIana(expression: "last2", year: 2025, month: 2)
        #expect(result == 26, "Expected 26, got \(String(describing: result))")
    }

    @Test("resolveIana: 6>=23 in Oct 1981 returns 25 (first Sunday on or after 23 — GB-Eire DST edge case)")
    func testGbEireDstEdgeCase() {
        // Mon=0..Sun=6: Oct 1981 day 23 = Fri(4), day 24 = Sat(5), day 25 = Sun(6)
        let result = DayDefinitionResolver.resolveIana(expression: "6>=23", year: 1981, month: 10)
        #expect(result == 25, "Expected 25, got \(String(describing: result))")
    }

    @Test("resolveIana: last6 returns last Sunday of the month")
    func testLastSunday() {
        // Mon=0..Sun=6: last6 = last Sunday; March 2025 last Sunday = 30
        let result = DayDefinitionResolver.resolveIana(expression: "last6", year: 2025, month: 3)
        #expect(result == 30, "Expected 30 (last Sunday March 2025), got \(String(describing: result))")
    }
}

// MARK: - Timezone resolution tests

@MainActor
struct TimezoneResolutionTests {

    private let orch: LocationOrchestrator
    private static let delta = 1.0 / 3600.0  // 1-second tolerance in hours

    init() throws {
        orch = try LocationOrchestrator(seWrapper: SEWrapperTestCoordinator.shared.getSEWrapper())
    }

    private func dt(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int, _ s: Int) -> AstronomicalDateTime {
        AstronomicalDateTime(
            Date: AstronomicalDate(Year: y, Month: mo, Day: d),
            Time: AstronomicalTime(Hour: h, Minute: mi, Second: s)
        )
    }

    private func offsetHours(_ seconds: Int) -> Double { Double(seconds) / 3600.0 }

    // MARK: Standard time (no DST)

    @Test("timezoneInfo: Amsterdam March 2025 — standard CET offset +1")
    func testAmsterdamWinter() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 3, 1, 12, 0, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST in March 1")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Amsterdam April 2025 — summer CEST offset +2")
    func testAmsterdamSummer() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 4, 6, 21, 20, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 2.0)
        #expect(diff < Self.delta, "Expected +2h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST active in April")
        #expect(zone.tzName == "CEST", "Expected CEST, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Amsterdam Jan 1953 — standard CET offset +1")
    func testAmsterdam1953() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(1953, 1, 29, 8, 37, 30))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST in January 1953")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Paris April 1973 — standard CET offset +1")
    func testParis1973() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Paris", dateTime: dt(1973, 4, 19, 8, 30, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Paris August 1953 — standard CET offset +1")
    func testParis1953() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Paris", dateTime: dt(1953, 8, 2, 14, 0, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Rome March 1931 — standard CET offset +1")
    func testRome1931() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Rome", dateTime: dt(1931, 3, 1, 6, 0, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Rome Aug 1968 — summer CEST offset +2")
    func testRome1968Summer() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Rome", dateTime: dt(1968, 8, 22, 17, 10, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 2.0)
        #expect(diff < Self.delta, "Expected +2h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST active")
        #expect(zone.tzName == "CEST", "Expected CEST, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Oslo May 1947 — standard CET offset +1")
    func testOslo1947() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Oslo", dateTime: dt(1947, 5, 15, 23, 55, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: Dublin May 1955 — Irish Summer Time offset +1")
    func testDublin1955() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Dublin", dateTime: dt(1955, 5, 23, 19, 0, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST active")
    }

    @Test("timezoneInfo: New York Oct 1993 — EDT offset -4")
    func testNewYork1993() async throws {
        let zone = try orch.timezoneInfo(tzName: "America/New_York", dateTime: dt(1993, 10, 13, 12, 50, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - (-4.0))
        #expect(diff < Self.delta, "Expected -4h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST active")
        #expect(zone.tzName == "EDT", "Expected EDT, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: New York May 1949 — EDT offset -4")
    func testNewYork1949() async throws {
        let zone = try orch.timezoneInfo(tzName: "America/New_York", dateTime: dt(1949, 5, 15, 23, 39, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - (-4.0))
        #expect(diff < Self.delta, "Expected -4h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST active")
        #expect(zone.tzName == "EDT", "Expected EDT, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: New York Sep 1997 — EDT offset -4")
    func testNewYork1997() async throws {
        let zone = try orch.timezoneInfo(tzName: "America/New_York", dateTime: dt(1997, 9, 12, 9, 0, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - (-4.0))
        #expect(diff < Self.delta, "Expected -4h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST active")
        #expect(zone.tzName == "EDT", "Expected EDT, got '\(zone.tzName)'")
    }

    // MARK: LMT (historical, pre-standard-time)

    @Test("timezoneInfo: Brussels June 1864 — LMT")
    func testBrussels1864LMT() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Brussels", dateTime: dt(1864, 6, 12, 7, 0, 0))
        #expect(zone.tzName == "LMT", "Expected LMT, got '\(zone.tzName)'")
        #expect(!zone.dstUsed, "Expected no DST for LMT")
    }

    @Test("timezoneInfo: Rome 99 BCE June — LMT")
    func testRomeAncient() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Rome", dateTime: dt(-99, 6, 29, 0, 0, 0))
        #expect(zone.tzName == "LMT", "Expected LMT for ancient date, got '\(zone.tzName)'")
    }

    // MARK: DST boundary edge cases (Amsterdam 2025)

    @Test("timezoneInfo: just before DST start — CET, no DST")
    func testJustBeforeDstStart() async throws {
        // Amsterdam clocks spring forward at 02:00 on March 30 2025
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 3, 30, 1, 55, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST just before spring-forward")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: just after DST start — CEST, DST active")
    func testJustAfterDstStart() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 3, 30, 3, 5, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 2.0)
        #expect(diff < Self.delta, "Expected +2h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST just after spring-forward")
        #expect(zone.tzName == "CEST", "Expected CEST, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: invalid time during DST gap — isInvalid true")
    func testInvalidDstGap() async throws {
        // 02:15 does not exist on March 30 2025 (clocks jump from 02:00 to 03:00)
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 3, 30, 2, 15, 0))
        #expect(zone.isInvalid, "Expected isInvalid=true for time in DST gap")
    }

    @Test("timezoneInfo: just before DST end — CEST, DST active")
    func testJustBeforeDstEnd() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 10, 26, 1, 55, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 2.0)
        #expect(diff < Self.delta, "Expected +2h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(zone.dstUsed, "Expected DST just before fall-back")
        #expect(zone.tzName == "CEST", "Expected CEST, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: just after DST end — CET, no DST")
    func testJustAfterDstEnd() async throws {
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 10, 26, 3, 5, 0))
        let diff = abs(offsetHours(zone.offsetSeconds) - 1.0)
        #expect(diff < Self.delta, "Expected +1h, got \(offsetHours(zone.offsetSeconds))h")
        #expect(!zone.dstUsed, "Expected no DST just after fall-back")
        #expect(zone.tzName == "CET", "Expected CET, got '\(zone.tzName)'")
    }

    @Test("timezoneInfo: ambiguous time during DST overlap — isAmbiguous true")
    func testAmbiguousDstOverlap() async throws {
        // 02:15 occurs twice on October 26 2025 (clocks fall back from 03:00 to 02:00)
        let zone = try orch.timezoneInfo(tzName: "Europe/Amsterdam", dateTime: dt(2025, 10, 26, 2, 15, 0))
        #expect(zone.isAmbiguous, "Expected isAmbiguous=true for time in DST overlap")
    }
}
