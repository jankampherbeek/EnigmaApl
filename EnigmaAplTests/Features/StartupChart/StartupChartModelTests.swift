// StartupChartModelTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
import CoreLocation
@testable import EnigmaApl

/// Integration tests for the startup chart: real Swiss Ephemeris calculation and a real ChartSession,
/// with a fake location provider and a fixed moment and timezone.
@MainActor
@Suite(.tags(.integration))
struct StartupChartModelTests {

    private let enschede = CLLocationCoordinate2D(latitude: 52.218055, longitude: 6.895555)
    private let paris = DefaultLocation(name: "Paris", latitude: 48.856667, longitude: 2.351667)
    private let amsterdamZone = TimeZone(identifier: "Europe/Amsterdam")!
    private let tolerance = 1e-9

    /// 2026-01-29 08:37:30 UT; Julian Day = 2461069.5 + 8.625 / 24.
    private let winterMoment = Date(timeIntervalSince1970: 1_769_675_850)
    private let winterJulianDay = 2461069.859375

    private func makeModel(location: CLLocationCoordinate2D?,
                           defaultLocation: DefaultLocation? = nil,
                           now: Date? = nil,
                           delay: Duration = .zero) -> (StartupChartModel, FakeLocationProvider) {
        let provider = FakeLocationProvider(location, delay: delay)
        let moment = now ?? winterMoment
        let model = StartupChartModel(
            locationProvider: provider,
            defaultLocation: { defaultLocation },
            now: { moment },
            timeZone: { amsterdamZone }
        )
        return (model, provider)
    }

    // MARK: - Location

    @Test func usesCurrentLocationWhenAvailable() async throws {
        let (model, _) = makeModel(location: enschede, defaultLocation: paris)
        let session = ChartSession()

        let added = await model.addIfNeeded(to: session, config: nil)

        #expect(added)
        let chart = try #require(session.selected)
        #expect(abs(chart.baseRequest.Latitude - enschede.latitude) < tolerance)
        #expect(abs(chart.baseRequest.Longitude - enschede.longitude) < tolerance)
        #expect(model.lastLocationSource == .currentLocation)
    }

    @Test func usesDefaultLocationWhenCurrentLocationIsNotAvailable() async throws {
        let (model, _) = makeModel(location: nil, defaultLocation: paris)
        let session = ChartSession()

        await model.addIfNeeded(to: session, config: nil)

        let chart = try #require(session.selected)
        #expect(abs(chart.baseRequest.Latitude - paris.latitude) < tolerance)
        #expect(abs(chart.baseRequest.Longitude - paris.longitude) < tolerance)
        #expect(model.lastLocationSource == .defaultLocation)
    }

    @Test func usesZeroZeroWhenNoLocationIsAvailable() async throws {
        let (model, _) = makeModel(location: nil, defaultLocation: nil)
        let session = ChartSession()

        await model.addIfNeeded(to: session, config: nil)

        let chart = try #require(session.selected)
        #expect(chart.baseRequest.Latitude == 0.0)
        #expect(chart.baseRequest.Longitude == 0.0)
        #expect(model.lastLocationSource == StartupLocationSource.none)
    }

    // MARK: - Moment and timezone

    @Test func calculatesForTheGivenMomentInUT() async throws {
        let (model, _) = makeModel(location: enschede)
        let session = ChartSession()

        await model.addIfNeeded(to: session, config: nil)

        let chart = try #require(session.selected)
        #expect(abs(chart.baseRequest.JulianDay - winterJulianDay) < 1e-6)
        #expect(abs(chart.chart.JulianDay - winterJulianDay) < 1e-6)
    }

    @Test func storesTheLocalOffsetForWinterTime() async throws {
        let (model, _) = makeModel(location: enschede)
        let session = ChartSession()

        await model.addIfNeeded(to: session, config: nil)

        #expect(session.selected?.timeZoneOffsetHours == 1.0)
    }

    @Test func storesTheLocalOffsetForSummerTime() async throws {
        // 2026-07-15 12:00:00 UT: Amsterdam uses daylight saving time (+02:00).
        let summer = Date(timeIntervalSince1970: 1_784_116_800)
        let (model, _) = makeModel(location: enschede, now: summer)
        let session = ChartSession()

        await model.addIfNeeded(to: session, config: nil)

        #expect(session.selected?.timeZoneOffsetHours == 2.0)
    }

    // MARK: - Only one startup chart

    @Test func addsOnlyOneChartWhenStartedTwiceConcurrently() async {
        let (model, provider) = makeModel(location: enschede, delay: .milliseconds(50))
        let session = ChartSession()

        async let first = model.addIfNeeded(to: session, config: nil)
        async let second = model.addIfNeeded(to: session, config: nil)
        let results = await [first, second]

        #expect(results.filter { $0 }.count == 1)
        #expect(session.charts.count == 1)
        #expect(provider.requestCount == 1)
    }

    @Test func doesNothingWhenTheSessionAlreadyHasCharts() async throws {
        let (model, provider) = makeModel(location: enschede)
        let session = ChartSession()
        await model.addIfNeeded(to: session, config: nil)

        let addedAgain = await model.addIfNeeded(to: session, config: nil)

        #expect(!addedAgain)
        #expect(session.charts.count == 1)
        #expect(provider.requestCount == 1)
    }

    // MARK: - Calculation

    @Test func calculatesTheDefaultFactorsWithoutConfiguration() async throws {
        let (model, _) = makeModel(location: enschede)
        let session = ChartSession()

        await model.addIfNeeded(to: session, config: nil)

        let chart = try #require(session.selected)
        #expect(chart.baseRequest.FactorsToUse == StartupChartModel.defaultFactors)
    }
}
