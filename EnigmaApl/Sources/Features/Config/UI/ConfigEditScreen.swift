// ConfigEditScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shows the 7 config sections for a selected UserConfiguration.
/// Lives in DetailColumn when mode == .config and a config is selected.
/// Uses a NavigationStack to push into per-section editor screens.
struct ConfigEditScreen: View {
    @Environment(\.modelContext) private var modelContext

    let config: UserConfiguration

    @State private var name: String = ""
    @State private var isDirty = false
    @State private var showHelp = false

    var body: some View {
        List {
            nameSection
            sectionsSection
            activeSection
        }
        .navigationTitle(name.isEmpty ? t(ConfigEditKeys.editFallbackTitle) : name)
        .navigationDestination(for: ConfigSection.self) { section in
            sectionEditor(for: section)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.helpTooltip))
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) { save() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { revert() }
                }
            }
        }
        .sheet(isPresented: $showHelp) { ConfigEditHelpView() }
        .onAppear { name = config.name }
    }

    // MARK: - Sections

    private var nameSection: some View {
        Section(t(ConfigEditKeys.editNameLabel)) {
            TextField(t(ConfigEditKeys.editNameLabel), text: $name)
                .onChange(of: name) { isDirty = true }
        }
    }

    private var sectionsSection: some View {
        Section(t(ConfigEditKeys.editSettings)) {
            ForEach(ConfigSection.allCases) { section in
                NavigationLink(value: section) {
                    Label(section.localizedName, systemImage: section.systemImage)
                }
            }
        }
    }

    private var activeSection: some View {
        Section {
            Toggle(t(ConfigEditKeys.editActiveToggle), isOn: Binding(
                get: { config.isActive },
                set: { newValue in
                    setActive(newValue)
                    isDirty = true
                }
            ))
        } footer: {
            Text(t(ConfigEditKeys.editActiveFooter))
        }
    }

    // MARK: - Section editors router

    @ViewBuilder
    private func sectionEditor(for section: ConfigSection) -> some View {
        switch section {
        case .calculation:  CalculationConfigEditor(config: config)
        case .display:      DisplayConfigEditor(config: config)
        case .glyphs:       GlyphsConfigEditor(config: config)
        case .factors:      FactorConfigEditor(config: config)
        case .fixstars:     FixStarConfigEditor(config: config)
        case .aspects:      AspectConfigEditor(config: config)
        case .orbs:         OrbConfigEditor(config: config)
        case .progressions: ProgressionsConfigEditor(config: config)
        }
    }

    // MARK: - Actions

    private func save() {
        config.name = name
        try? modelContext.save()
        isDirty = false
    }

    private func revert() {
        name = config.name
        isDirty = false
    }

    /// Activates this config and deactivates all others.
    private func setActive(_ active: Bool) {
        guard active else { config.isActive = false; return }
        let descriptor = FetchDescriptor<UserConfiguration>()
        let all = (try? modelContext.fetch(descriptor)) ?? []
        for c in all { c.isActive = false }
        config.isActive = true
    }
}

// MARK: - Help view

struct ConfigEditHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.listTitle)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.helpLine1))
                            Text(t(ConfigEditKeys.helpLine2))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle(t(ConfigEditKeys.helpTitle))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.helpClose)) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Empty state

struct ConfigEmptyState: View {
    var body: some View {
        ContentUnavailableView(
            t(ConfigEditKeys.emptyTitle),
            systemImage: "gear",
            description: Text(t(ConfigEditKeys.emptyDescription))
        )
    }
}

// MARK: - Localization helper

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ConfigEdit", bundle: .main, comment: "")
}
