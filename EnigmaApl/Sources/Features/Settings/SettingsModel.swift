// SettingsModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import AppKit
import Combine

/// Model for the settings window: machine-specific file locations and the default location.
@MainActor
final class SettingsModel: ObservableObject {
    @Published private(set) var researchFolderPath: String = ""
    @Published private(set) var errorKey: String? = nil

    // Default location, used for the startup chart when the current location is not available.
    // Changes are stored immediately; when both degree fields are empty the setting is removed.
    @Published var locationName: String = "" { didSet { storeDefaultLocation() } }
    @Published var latitudeDegrees: Int? = nil { didSet { storeDefaultLocation() } }
    @Published var latitudeMinutes: Int? = nil { didSet { storeDefaultLocation() } }
    @Published var latitudeSeconds: Int? = nil { didSet { storeDefaultLocation() } }
    @Published var longitudeDegrees: Int? = nil { didSet { storeDefaultLocation() } }
    @Published var longitudeMinutes: Int? = nil { didSet { storeDefaultLocation() } }
    @Published var longitudeSeconds: Int? = nil { didSet { storeDefaultLocation() } }
    @Published var latHemi: LatitudeHemisphere = .north { didSet { storeDefaultLocation() } }
    @Published var lonHemi: LongitudeHemisphere = .east { didSet { storeDefaultLocation() } }
    private var isLoadingLocation = false

    var logFilePath: String { Logger.logFilePath ?? "" }

    /// Key of a validation message for the default location, or nil when it is empty or valid (and stored).
    var locationErrorKey: String? {
        if latitudeDegrees == nil && longitudeDegrees == nil {
            return locationName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : SettingsKeys.errorLocationIncomplete
        }
        guard let latDeg = latitudeDegrees, let lonDeg = longitudeDegrees else {
            return SettingsKeys.errorLocationIncomplete
        }
        let latitude = Self.dmsToDecimal(deg: latDeg, min: latitudeMinutes ?? 0, sec: latitudeSeconds ?? 0, negative: latHemi == .south)
        let longitude = Self.dmsToDecimal(deg: lonDeg, min: longitudeMinutes ?? 0, sec: longitudeSeconds ?? 0, negative: lonHemi == .west)
        if !CoordinateValidation.validateLatitude(latitude) || !CoordinateValidation.validateLongitude(longitude) {
            return SettingsKeys.errorLocationInvalid
        }
        return nil
    }

    var hasDefaultLocation: Bool {
        latitudeDegrees != nil || longitudeDegrees != nil || !locationName.isEmpty
    }

    init() {
        researchFolderPath = FileLocations.defaultResearchFolder?.path ?? ""
        loadDefaultLocation()
    }

    // MARK: - Default location

    private func loadDefaultLocation() {
        isLoadingLocation = true
        defer { isLoadingLocation = false }
        guard let location = DefaultLocation.stored() else { return }
        locationName = location.name
        let (latDeg, latMin, latSec, latNeg) = Self.decimalToDms(location.latitude)
        latitudeDegrees = latDeg
        latitudeMinutes = latMin
        latitudeSeconds = latSec
        latHemi = latNeg ? .south : .north
        let (lonDeg, lonMin, lonSec, lonNeg) = Self.decimalToDms(location.longitude)
        longitudeDegrees = lonDeg
        longitudeMinutes = lonMin
        longitudeSeconds = lonSec
        lonHemi = lonNeg ? .west : .east
    }

    private func storeDefaultLocation() {
        guard !isLoadingLocation else { return }
        guard let latDeg = latitudeDegrees, let lonDeg = longitudeDegrees else {
            if latitudeDegrees == nil && longitudeDegrees == nil {
                DefaultLocation.store(nil)
            }
            return
        }
        let latitude = Self.dmsToDecimal(deg: latDeg, min: latitudeMinutes ?? 0, sec: latitudeSeconds ?? 0, negative: latHemi == .south)
        let longitude = Self.dmsToDecimal(deg: lonDeg, min: longitudeMinutes ?? 0, sec: longitudeSeconds ?? 0, negative: lonHemi == .west)
        guard CoordinateValidation.validateLatitude(latitude), CoordinateValidation.validateLongitude(longitude) else { return }
        let name = locationName.trimmingCharacters(in: .whitespaces)
        DefaultLocation.store(DefaultLocation(name: name, latitude: latitude, longitude: longitude))
    }

    func clearDefaultLocation() {
        isLoadingLocation = true
        locationName = ""
        latitudeDegrees = nil
        latitudeMinutes = nil
        latitudeSeconds = nil
        longitudeDegrees = nil
        longitudeMinutes = nil
        longitudeSeconds = nil
        latHemi = .north
        lonHemi = .east
        isLoadingLocation = false
        DefaultLocation.store(nil)
    }

    private static func dmsToDecimal(deg: Int, min: Int, sec: Int, negative: Bool) -> Double {
        let value = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return negative ? -value : value
    }

    private static func decimalToDms(_ decimal: Double) -> (Int, Int, Int, Bool) {
        let totalSeconds = Int((Swift.abs(decimal) * 3600.0).rounded())
        return (totalSeconds / 3600, (totalSeconds % 3600) / 60, totalSeconds % 60, decimal < 0)
    }

    /// Lets the user select the default research folder in an open panel.
    func chooseResearchFolder(prompt: String) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = prompt
        panel.directoryURL = FileLocations.defaultResearchFolder
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try FileLocations.setDefaultResearchFolder(url)
            researchFolderPath = url.path
            errorKey = nil
        } catch {
            Logger.log.error("SettingsModel: could not store the default research folder: \(error.localizedDescription)")
            errorKey = SettingsKeys.errorResearchFolder
        }
    }

    func clearResearchFolder() {
        try? FileLocations.setDefaultResearchFolder(nil)
        researchFolderPath = ""
        errorKey = nil
    }

    /// Shows the log file in Finder, or its folder if nothing has been logged yet.
    func showLogFile() {
        guard let url = Logger.logFileURL else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.open(url.deletingLastPathComponent())
        }
    }
}
