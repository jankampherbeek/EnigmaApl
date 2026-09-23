// AltZodiacStartModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Shared state for the AltZodiacStart feature: which factor's position defines the
/// start of the alternative zodiac. Injected as an EnvironmentObject so
/// AltZodiacStartInputView and AltZodiacStartResultsView stay in sync.
@MainActor
final class AltZodiacStartModel: ObservableObject {

    @Published var startFactor: Factors = .sun
}
