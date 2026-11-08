// AppEnvironment.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Describes the environment the app runs in, so tests never touch the user's data.
/// The unit and integration tests are hosted in the app: the app starts for every test run.
enum AppEnvironment {

    /// Launch argument for UI tests (XCUIApplication.launchArguments).
    static let uiTestingArgument = "-uiTesting"

    /// True when the app is started as host for the unit and integration tests.
    static var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    /// True when the app is started by a UI test.
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTestingArgument)
    }

    /// Tests use an in-memory database instead of the database of the user.
    static var usesInMemoryStore: Bool { isRunningUnitTests || isUITesting }

    /// The host app of the unit tests does not calculate a startup chart: that would request
    /// the location of the device and depend on the current time.
    static var skipsStartupChart: Bool { isRunningUnitTests }
}
