// DefaultLocation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A location that is used for the chart of the current moment when the actual location
/// of the device is not available. Coordinates in decimal degrees: north and east are positive.
struct DefaultLocation: Codable, Equatable {
    var name: String
    var latitude: Double
    var longitude: Double

    private static let storageKey = "settings.location.defaultLocation"

    /// Stored in UserDefaults rather than in the (syncable) configuration, because it belongs to this Mac.
    /// Tests pass their own `UserDefaults(suiteName:)`.
    static func stored(in defaults: UserDefaults = .standard) -> DefaultLocation? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        guard let location = try? JSONDecoder().decode(DefaultLocation.self, from: data) else {
            Logger.log.warning("DefaultLocation: could not decode the stored default location")
            return nil
        }
        return location
    }

    /// Stores `location` as the default location; nil removes the setting.
    static func store(_ location: DefaultLocation?, in defaults: UserDefaults = .standard) {
        guard let location else {
            defaults.removeObject(forKey: storageKey)
            return
        }
        guard let data = try? JSONEncoder().encode(location) else {
            Logger.log.error("DefaultLocation: could not encode the default location")
            return
        }
        defaults.set(data, forKey: storageKey)
    }
}
