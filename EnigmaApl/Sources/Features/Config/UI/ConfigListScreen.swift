// ConfigListScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shows all saved configurations. Lives in ContentColumn when mode == .config.
/// Tapping a row selects it for editing in DetailColumn.
struct ConfigListScreen: View {
    @EnvironmentObject private var configNav: ConfigNavigator
    @EnvironmentObject private var unsavedChanges: UnsavedChangesGuard
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserConfiguration.name) private var configurations: [UserConfiguration]

    @State private var showNewConfigSheet = false
    @State private var newConfigName = ""
    @State private var basedOnConfig: UserConfiguration? = nil
    @State private var configToDelete: UserConfiguration? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            ForEach(configurations) { config in
                configRow(config)
            }
        }
        .navigationTitle(t(ConfigEditKeys.listTitle))
        .onAppear { autoSelectIfNeeded() }
        .onChange(of: configurations) { autoSelectIfNeeded() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showNewConfigSheet = true } label: {
                    Label(t(ConfigEditKeys.listNew), systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewConfigSheet) {
            newConfigSheet
        }
        .alert(t(ConfigEditKeys.listAlertDeleteTitle),
               isPresented: $showDeleteAlert,
               presenting: configToDelete) { config in
            Button(t(ConfigEditKeys.listAlertDeleteButton), role: .destructive) { delete(config) }
            Button(t(ConfigEditKeys.cancel), role: .cancel) {}
        } message: { config in
            Text(String(format: t(ConfigEditKeys.listAlertDeleteMessage), config.name))
        }
    }

    // MARK: - Row

    private func configRow(_ config: UserConfiguration) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(config.name)
                    .font(.body)
                if config.isActive {
                    Text(t(ConfigEditKeys.listActiveBadge))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if config.isStandard == true {
                    Text(t(ConfigEditKeys.listStandardBadge))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if config.isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard configNav.selectedConfig !== config else { return }
            unsavedChanges.perform { configNav.select(config) }
        }
        .background(configNav.selectedConfig === config ? Color.accentColor.opacity(0.08) : .clear)
        .swipeActions(edge: .trailing) {
            if config.isStandard != true { deleteButton(config) }
        }
        .contextMenu {
            if config.isStandard != true { deleteButton(config) }
        }
    }

    private func deleteButton(_ config: UserConfiguration) -> some View {
        Button(role: .destructive) {
            configToDelete = config
            showDeleteAlert = true
        } label: {
            Label(t(ConfigEditKeys.listAlertDeleteButton), systemImage: "trash")
        }
    }

    // MARK: - New Config Sheet

    private var newConfigSheet: some View {
        NavigationStack {
            Form {
                Section(t(ConfigEditKeys.newNameLabel)) {
                    TextField(t(ConfigEditKeys.newNamePlaceholder), text: $newConfigName)
                }
                Section {
                    Picker(t(ConfigEditKeys.newBasedOn), selection: $basedOnConfig) {
                        Text(t(ConfigEditKeys.newDefaults)).tag(nil as UserConfiguration?)
                        ForEach(configurations) { config in
                            Text(config.name).tag(config as UserConfiguration?)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text(t(ConfigEditKeys.newBasedOn))
                } footer: {
                    Text(t(ConfigEditKeys.newBasedOnFooter))
                }
            }
            .navigationTitle(t(ConfigEditKeys.newSheetTitle))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.newCreate)) { createConfig() }
                        .disabled(newConfigName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { resetNewConfigForm(); showNewConfigSheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Actions

    /// Selects the active config (or the first one) when nothing is selected yet.
    /// If the database is empty, the standard configuration is created first.
    private func autoSelectIfNeeded() {
        let repository = UserConfigurationRepository(context: modelContext)
        if configurations.isEmpty {
            try? repository.addStandard(name: t(ConfigEditKeys.defaultConfigName))
            // onChange(of: configurations) will fire after the insert and call this again
            return
        }
        try? repository.markStandardIfNeeded(standardNames: Self.standardConfigNames)
        guard configNav.selectedConfig == nil else { return }
        let active = configurations.first(where: { $0.isActive }) ?? configurations.first
        configNav.select(active)
    }

    private func createConfig() {
        let newConfig: UserConfiguration
        if let base = basedOnConfig {
            newConfig = UserConfiguration(
                name: newConfigName,
                calculationConfig: base.calculationConfig,
                displayConfig: base.displayConfig,
                glyphsConfig: base.glyphsConfig,
                factorConfig: base.factorConfig,
                aspectConfig: base.aspectConfig,
                orbConfig: base.orbConfig,
                progressionsConfig: base.progressionsConfig
            )
        } else {
            newConfig = UserConfiguration(name: newConfigName)
        }
        modelContext.insert(newConfig)
        try? modelContext.save()
        configNav.select(newConfig)
        resetNewConfigForm()
        showNewConfigSheet = false
    }

    private func delete(_ config: UserConfiguration) {
        if configNav.selectedConfig === config { configNav.select(nil) }
        try? UserConfigurationRepository(context: modelContext).delete(config)
    }

    /// The name of the standard configuration in all supported languages.
    private static let standardConfigNames: Set<String> = Set(
        ["en", "nl", "de", "fr"].compactMap { language in
            Bundle.main.path(forResource: language, ofType: "lproj")
                .flatMap { Bundle(path: $0) }?
                .localizedString(forKey: ConfigEditKeys.defaultConfigName, value: nil, table: "ConfigEdit")
        }
    )

    private func resetNewConfigForm() {
        newConfigName = ""
        basedOnConfig = nil
    }
}

// MARK: - Localization helper

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ConfigEdit", bundle: .main, comment: "")
}
