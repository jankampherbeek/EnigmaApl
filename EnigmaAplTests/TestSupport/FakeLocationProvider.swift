// FakeLocationProvider.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import CoreLocation
@testable import EnigmaApl

/// Location provider for tests: returns a fixed location (or nil) after an optional delay,
/// and counts how often it was asked.
@MainActor
final class FakeLocationProvider: LocationProviding {
    private let location: CLLocationCoordinate2D?
    private let delay: Duration
    private(set) var requestCount = 0

    init(_ location: CLLocationCoordinate2D?, delay: Duration = .zero) {
        self.location = location
        self.delay = delay
    }

    func fetchCurrentLocation() async -> CLLocationCoordinate2D? {
        requestCount += 1
        if delay > .zero {
            try? await Task.sleep(for: delay)
        }
        return location
    }
}
