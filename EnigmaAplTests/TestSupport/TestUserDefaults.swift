// TestUserDefaults.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A fresh, empty UserDefaults suite per test, so tests never read or change the settings of the user.
enum TestUserDefaults {
    static func make(function: String = #function) -> UserDefaults {
        let suiteName = "EnigmaAplTests.\(function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
