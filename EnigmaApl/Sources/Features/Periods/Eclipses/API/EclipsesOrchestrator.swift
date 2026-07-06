// EclipsesOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

// MARK: - Domain Types

enum EclipseSearchType: String, CaseIterable, Identifiable {
    case solar = "Solar"
    case lunar = "Lunar"
    case all   = "All"
    var id: String { rawValue }
}

struct EclipseEvent: Identifiable {
    enum Kind { case solar, lunar }

    let id            = UUID()
    let kind          : Kind
    /// JD used for date/time display: local eclipse JD when local data matches, else global JD.
    let displayJD     : Double
    /// Ecliptic longitude of the Sun (solar) or Moon (lunar) at maximum eclipse.
    let longitude     : Double

    let isTotal       : Bool
    let isAnnular     : Bool   // solar only
    let isPartial     : Bool
    let isPenumbral   : Bool   // lunar only

    /// True when a local eclipse call was made and the result corresponds to this global eclipse.
    let hasLocalData  : Bool
    /// Solar: SE_ECL_VISIBLE flag; Lunar: trueAltitude > 0. Only meaningful when hasLocalData.
    let isVisible     : Bool
    let sarosNumber      : Double  // -99999999 when unavailable
    let sarosMemberNumber: Double
}

// MARK: - Model (shared between input and results screens)

@MainActor
final class EclipsesModel: ObservableObject {
    @Published var results    : [EclipseEvent] = []
    @Published var hasLocation: Bool           = false

    var hasResults: Bool { !results.isEmpty }
}

// MARK: - Orchestrator

final class EclipsesOrchestrator {
    private let seWrapper: SEWrapper

    init(seWrapper: SEWrapper = SEWrapper()) {
        self.seWrapper = seWrapper
    }

    /// Search for eclipses between startJD and endJD.
    /// When geoLon/geoLat are provided, each global eclipse is also queried locally
    /// to add type, visibility, and Saros data for that specific location.
    func findEclipses(startJD: Double, endJD: Double,
                      type: EclipseSearchType,
                      geoLon: Double?, geoLat: Double?,
                      height: Double = 0.0) -> [EclipseEvent] {
        guard startJD < endJD else { return [] }

        let useLocal = geoLon != nil && geoLat != nil
        let lon = geoLon ?? 0.0
        let lat = geoLat ?? 0.0

        var events: [EclipseEvent] = []

        if type == .solar || type == .all {
            events += searchSolar(startJD: startJD, endJD: endJD,
                                  useLocal: useLocal, lon: lon, lat: lat, height: height)
        }
        if type == .lunar || type == .all {
            events += searchLunar(startJD: startJD, endJD: endJD,
                                  useLocal: useLocal, lon: lon, lat: lat, height: height)
        }

        return events.sorted { $0.displayJD < $1.displayJD }
    }

    // MARK: - Private Helpers

    private func searchSolar(startJD: Double, endJD: Double,
                             useLocal: Bool,
                             lon: Double, lat: Double, height: Double) -> [EclipseEvent] {
        var results: [EclipseEvent] = []
        var searchFrom = startJD

        for _ in 0..<1000 {
            guard searchFrom <= endJD else { break }
            guard let g = seWrapper.nextSolarEclipse(afterJD: searchFrom) else { break }
            guard g.maxJD <= endJD else { break }

            if useLocal {
                let local = seWrapper.solEclipseLocal(afterJD: g.maxJD - 1.0,
                                                       geoLon: lon, geoLat: lat, height: height)
                let sameEclipse = local != nil && abs(local!.maxEclipseJD - g.maxJD) < 1.0

                // When the eclipse is not visible from the location, the local function returns
                // a different (next locally visible) eclipse. Fall back to swe_sol_eclipse_where
                // to get the Saros data from the eclipse path's central point.
                let saros: Double
                let sarosMember: Double
                if sameEclipse {
                    saros = local!.sarosNumber
                    sarosMember = local!.sarosMemberNumber
                } else if let fallback = seWrapper.solEclipseSaros(jd: g.maxJD) {
                    saros = fallback.sarosNumber
                    sarosMember = fallback.sarosMemberNumber
                } else {
                    saros = -99999999
                    sarosMember = -99999999
                }

                results.append(EclipseEvent(
                    kind: .solar,
                    displayJD: sameEclipse ? local!.maxEclipseJD : g.maxJD,
                    longitude: g.longitude,
                    isTotal:    sameEclipse ? local!.isTotal   : g.isTotal,
                    isAnnular:  sameEclipse ? local!.isAnnular : g.isAnnular,
                    isPartial:  sameEclipse ? local!.isPartial : g.isPartial,
                    isPenumbral: false,
                    hasLocalData: sameEclipse,
                    isVisible:  sameEclipse ? local!.isVisible : false,
                    sarosNumber: saros, sarosMemberNumber: sarosMember
                ))
            } else {
                results.append(EclipseEvent(
                    kind: .solar,
                    displayJD: g.maxJD,
                    longitude: g.longitude,
                    isTotal: g.isTotal, isAnnular: g.isAnnular, isPartial: g.isPartial,
                    isPenumbral: false,
                    hasLocalData: false, isVisible: false,
                    sarosNumber: -99999999, sarosMemberNumber: -99999999
                ))
            }
            searchFrom = g.maxJD + 1.0
        }
        return results
    }

    private func searchLunar(startJD: Double, endJD: Double,
                             useLocal: Bool,
                             lon: Double, lat: Double, height: Double) -> [EclipseEvent] {
        var results: [EclipseEvent] = []
        var searchFrom = startJD

        for _ in 0..<1000 {
            guard searchFrom <= endJD else { break }
            guard let g = seWrapper.nextLunarEclipse(afterJD: searchFrom) else { break }
            guard g.maxJD <= endJD else { break }

            if useLocal {
                let local = seWrapper.lunEclipseLocal(afterJD: g.maxJD - 1.0,
                                                       geoLon: lon, geoLat: lat, height: height)
                let sameEclipse = local != nil && abs(local!.maxEclipseJD - g.maxJD) < 1.0

                // When the moon is below the horizon at the given location, the local function
                // returns the next VISIBLE eclipse. Fall back to swe_lun_eclipse_how to get
                // the Saros data directly at the eclipse time (horizon-independent).
                let saros: Double
                let sarosMember: Double
                if sameEclipse {
                    saros = local!.sarosNumber
                    sarosMember = local!.sarosMemberNumber
                } else if let fallback = seWrapper.lunEclipseSaros(jd: g.maxJD) {
                    saros = fallback.sarosNumber
                    sarosMember = fallback.sarosMemberNumber
                } else {
                    saros = -99999999
                    sarosMember = -99999999
                }

                results.append(EclipseEvent(
                    kind: .lunar,
                    displayJD: sameEclipse ? local!.maxEclipseJD : g.maxJD,
                    longitude: g.longitude,
                    isTotal:     sameEclipse ? local!.isTotal     : g.isTotal,
                    isAnnular:   false,
                    isPartial:   sameEclipse ? local!.isPartial   : g.isPartial,
                    isPenumbral: sameEclipse ? local!.isPenumbral : g.isPenumbral,
                    hasLocalData: sameEclipse,
                    isVisible:  sameEclipse ? local!.trueAltitude > 0 : false,
                    sarosNumber: saros, sarosMemberNumber: sarosMember
                ))
            } else {
                results.append(EclipseEvent(
                    kind: .lunar,
                    displayJD: g.maxJD,
                    longitude: g.longitude,
                    isTotal: g.isTotal, isAnnular: false, isPartial: g.isPartial,
                    isPenumbral: g.isPenumbral,
                    hasLocalData: false, isVisible: false,
                    sarosNumber: -99999999, sarosMemberNumber: -99999999
                ))
            }
            searchFrom = g.maxJD + 1.0
        }
        return results
    }
}
