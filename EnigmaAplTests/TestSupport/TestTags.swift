// TestTags.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing

extension Tag {
    /// Tests that combine several parts of the app (calculation, persistence, session, settings).
    @Tag static var integration: Self
    /// Tests that compare with reference charts in Fixtures/ReferenceCharts.json.
    @Tag static var reference: Self
}
