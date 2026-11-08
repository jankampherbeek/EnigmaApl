// StartupChartModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import CoreLocation
import Foundation

/// Provides the current location of the device; nil when it is not available.
@MainActor
protocol LocationProviding {
    func fetchCurrentLocation() async -> CLLocationCoordinate2D?
}

extension LocationService: LocationProviding {}

/// Where the location of the startup chart came from.
enum StartupLocationSource: Equatable {
    case currentLocation
    case defaultLocation
    case none
}

/// Calculates the chart for the current moment at startup and adds it to the chart session.
/// The location is, in order of preference: the current location, the default location from Settings, 0° / 0°.
/// Time, timezone and both locations are injected, so the model can be tested without the device.
@MainActor
final class StartupChartModel {
    private let locationProvider: LocationProviding
    private let defaultLocation: () -> DefaultLocation?
    private let now: () -> Date
    private let timeZone: () -> TimeZone
    private let seWrapper: SEWrapper
    private var isBuilding = false

    /// Source of the location used for the last startup chart; nil when no chart was built yet.
    private(set) var lastLocationSource: StartupLocationSource?

    static let defaultFactors: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto]

    init(locationProvider: LocationProviding,
         defaultLocation: @escaping () -> DefaultLocation? = { DefaultLocation.stored() },
         now: @escaping () -> Date = { Date() },
         timeZone: @escaping () -> TimeZone = { TimeZone.current },
         seWrapper: SEWrapper = SEWrapper()) {
        self.locationProvider = locationProvider
        self.defaultLocation = defaultLocation
        self.now = now
        self.timeZone = timeZone
        self.seWrapper = seWrapper
    }

    /// Adds the startup chart to `session` when the session is still empty.
    /// Returns true when a chart was added. Safe to call more than once: only one startup chart is added,
    /// and none when the user already added a chart while the location was being determined.
    @discardableResult
    func addIfNeeded(to session: ChartSession, config: UserConfiguration?) async -> Bool {
        guard session.charts.isEmpty, !isBuilding else { return false }
        isBuilding = true
        defer { isBuilding = false }

        let current = await locationProvider.fetchCurrentLocation()
        guard session.charts.isEmpty else { return false }

        let (latitude, longitude, source) = resolveLocation(current: current)

        // Take the moment once, so the UT time and the local offset belong to the same instant.
        let moment = now()
        let timeZoneOffsetHours = Double(timeZone().secondsFromGMT(for: moment)) / 3600.0

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let comps = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: moment)
        let astroDate = AstronomicalDate(
            Year: comps.year ?? 2000,
            Month: comps.month ?? 1,
            Day: comps.day ?? 1,
            Gregorian: true
        )
        let astroTime = AstronomicalTime(
            Hour: comps.hour ?? 0,
            Minute: comps.minute ?? 0,
            Second: comps.second ?? 0
        )

        let calcConfig = config?.calculationConfig ?? CalculationConfig()
        let factors = config?.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor } ?? Self.defaultFactors

        let request = CalcRequest(
            JulianDay: seWrapper.julianDay(date: astroDate, time: astroTime),
            FactorsToUse: factors,
            HouseSystem: Int(calcConfig.houseSystem.seId.asciiValue ?? 80),
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: calcConfig
        )
        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let chartName = NSLocalizedString(StartupChartKeys.chartName, tableName: "StartupChart", bundle: .main, comment: "")
        session.add(name: chartName, chart: chart, baseRequest: request, timeZoneOffsetHours: timeZoneOffsetHours)
        lastLocationSource = source
        return true
    }

    private func resolveLocation(current: CLLocationCoordinate2D?) -> (Double, Double, StartupLocationSource) {
        if let current {
            return (current.latitude, current.longitude, .currentLocation)
        }
        if let fallback = defaultLocation() {
            Logger.log.info("Startup chart: no current location available, using the default location '\(fallback.name)'")
            return (fallback.latitude, fallback.longitude, .defaultLocation)
        }
        Logger.log.warning("Startup chart: no current location and no default location available, using 0° latitude / 0° longitude")
        return (0.0, 0.0, .none)
    }
}
