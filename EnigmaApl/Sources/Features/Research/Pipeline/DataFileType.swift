// DataFileType.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Supported formats for research input data files.
public enum DataFileType: Int, CaseIterable {
    case standardEnigma = 0
    case gauquelin      = 1
    case quickChart     = 2

    /// Resource bundle key for the localized display name.
    var rbKey: String { DataFileTypeKeys.nameKey(for: self) }
}
