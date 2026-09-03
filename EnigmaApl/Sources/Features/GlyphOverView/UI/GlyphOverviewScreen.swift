// GlyphOverviewScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func go(_ key: String) -> String {
    NSLocalizedString(key, tableName: "GlyphOverview", bundle: .main, comment: "")
}

private func sh(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Shared", bundle: .main, comment: "")
}

struct GlyphOverviewScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let model = GlyphOverviewModel()
    private let columns = [GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(title: go(GlyphOverviewKeys.sectionFactors), entries: model.factorEntries)
                    section(title: go(GlyphOverviewKeys.sectionAspects), entries: model.aspectEntries)
                    section(title: go(GlyphOverviewKeys.sectionSigns), entries: model.otherEntries)
                }
                .padding()
            }
            .navigationTitle(go(GlyphOverviewKeys.title))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(sh(SharedKeys.close)) { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 420)
        #endif
    }

    // MARK: - Sections

    private func section(title: String, entries: [GlyphOverviewEntry]) -> some View {
        GroupBox(title) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(entries) { entry in
                    VStack(spacing: 4) {
                        Text(entry.glyph)
                            .font(.custom("EnigmaAstrology3", size: 22))
                        Text(entry.name)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
            }
            .padding(.top, 4)
        }
    }
}
