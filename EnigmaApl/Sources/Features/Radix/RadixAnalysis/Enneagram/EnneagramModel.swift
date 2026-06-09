// EnneagramModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class EnneagramModel: ObservableObject {
    @Published var options = EnneagramOrchestrator.Options()
}
