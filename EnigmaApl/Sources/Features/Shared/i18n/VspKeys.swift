// VspKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for VspScreen, resolved from Vsp.strings.
struct VspKeys {
    private init() {}

    // VspScreen
    static let title         = "view.vspscreen.title"
    static let noChart       = "view.vspscreen.nochart"
    static let explanation   = "view.vspscreen.explanation"
    static let help          = "view.vspscreen.help"

    // Table columns
    static let colSeq        = "view.vspscreen.col.seq"
    static let colName       = "view.vspscreen.col.name"
    static let colPhenomenon = "view.vspscreen.col.phenomenon"
    static let colDate       = "view.vspscreen.col.date"
    static let colLongitude  = "view.vspscreen.col.longitude"

    // Position names (pentagram points)
    static let nameLeg       = "view.vspscreen.name.leg"
    static let nameArm       = "view.vspscreen.name.arm"
    static let nameHead      = "view.vspscreen.name.head"

    // Phenomena
    static let phenInferior  = "view.vspscreen.phen.inferior"
    static let phenSuperior  = "view.vspscreen.phen.superior"
}
