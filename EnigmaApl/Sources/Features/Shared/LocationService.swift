// LocationService.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import CoreLocation

/// Fetches the device's current location once. Resolves to nil when permission is denied, unavailable,
/// or when no location is received within the timeout.
/// Concurrent callers share the same pending request, so no continuation is ever lost.
@MainActor
final class LocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuations: [CheckedContinuation<CLLocationCoordinate2D?, Never>] = []
    private var timeoutTask: Task<Void, Never>?

    /// Maximum time to wait for a location, including the time the user needs to answer the permission dialog.
    private let timeoutSeconds: UInt64 = 30

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func fetchCurrentLocation() async -> CLLocationCoordinate2D? {
        if let last = manager.location, Date().timeIntervalSince(last.timestamp) < 3600 {
            return last.coordinate
        }
        return await withCheckedContinuation { cont in
            continuations.append(cont)
            guard continuations.count == 1 else { return }   // a request is already in flight
            startTimeout()
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                Logger.log.warning("LocationService: location access denied or restricted (status \(manager.authorizationStatus.rawValue))")
                finish(with: nil)
            }
        }
    }

    private func startTimeout() {
        timeoutTask?.cancel()
        timeoutTask = Task { [weak self, timeoutSeconds] in
            try? await Task.sleep(nanoseconds: timeoutSeconds * 1_000_000_000)
            guard !Task.isCancelled, let self, !self.continuations.isEmpty else { return }
            Logger.log.warning("LocationService: no location received within \(timeoutSeconds) seconds")
            self.finish(with: nil)
        }
    }

    private func finish(with coordinate: CLLocationCoordinate2D?) {
        timeoutTask?.cancel()
        timeoutTask = nil
        let pending = continuations
        continuations = []
        pending.forEach { $0.resume(returning: coordinate) }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !continuations.isEmpty else { return }
        finish(with: locations.last?.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !continuations.isEmpty else { return }
        Logger.log.warning("LocationService: failed to get location: \(error.localizedDescription)")
        finish(with: nil)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard !continuations.isEmpty else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            Logger.log.warning("LocationService: location access denied or restricted")
            finish(with: nil)
        default:
            break
        }
    }
}
