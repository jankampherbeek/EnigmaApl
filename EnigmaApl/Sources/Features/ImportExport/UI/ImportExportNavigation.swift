// ImportExportNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

struct ImportExportNav: Equatable {
    var section: ImportExportSection = .enigma
}

/// The supported import/export formats. Enigma supports charts and events,
/// both import and export. QuickChart and AAF'97 are chart-only, both import
/// and export (AAF's event/country/organisation record types are kept as a
/// chart category, since an Enigma event must already be linked to an
/// existing chart). AstroDienst (Astro.com / Astro-Databank XML) is
/// chart-only and import-only.
enum ImportExportSection: String, CaseIterable, Identifiable, Hashable {
    case enigma      = "Enigma"
    case quickChart  = "QuickChart"
    case aaf97       = "AAF'97"
    case astroDienst = "AstroDienst"

    var id: String { rawValue }
}

@MainActor
final class ImportExportNavigator: ObservableObject {
    @Binding private var nav: ImportExportNav

    init(nav: Binding<ImportExportNav>) { _nav = nav }

    func setSection(_ section: ImportExportSection) {
        nav.section = section
    }
}
