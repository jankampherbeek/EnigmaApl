//
//  ConfigSectionEditors.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/03/2026.
//

import SwiftUI
import SwiftData

// MARK: - Base protocol helper
//
// Each section editor receives the full UserConfiguration so it can
// read and write back its specific sub-config. Working with local
// @State copies ensures Save/Cancel behaviour per section.

// MARK: - Calculation

struct CalculationConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    // Individual state vars because CalculationConfig has immutable let-properties
    @State private var houseSystem: HouseSystems = .placidus
    @State private var ayanamsha: Ayanamshas = .tropical
    @State private var observerPosition: ObserverPositions = .geoCentric
    @State private var projectionType: ProjectionTypes = .twoDimensional
    @State private var blackMoonCorrectionType: BlackMoonCorrectionTypes = .duval
    @State private var lunarNodeType: LunarNodeTypes = .meanNode
    @State private var lotsType: LotsTypes = .sect
    @State private var stationaryPercentage: Int = 10
    @State private var slowPercentage: Int = 20
    @State private var isDirty = false
    @State private var showHelp = false

    var body: some View {
        Form {
            Text(sectionEditorTitle(.calculation))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Section {
                Picker(t(ConfigEditKeys.calcHouseSystem), selection: $houseSystem) {
                    ForEach(HouseSystems.allCases, id: \.self) { system in
                        Text(le(system.localizedName)).tag(system)
                    }
                }
                Picker(t(ConfigEditKeys.calcAyanamsha), selection: $ayanamsha) {
                    ForEach(Ayanamshas.allCases, id: \.self) { ayan in
                        Text(le(ayan.rbKey)).tag(ayan)
                    }
                }
            }

            Section {
                Picker(t(ConfigEditKeys.calcObserverPosition), selection: $observerPosition) {
                    ForEach(ObserverPositions.allCases, id: \.self) { pos in
                        Text(le(pos.rbKey)).tag(pos)
                    }
                }
                Picker(t(ConfigEditKeys.calcProjectionType), selection: $projectionType) {
                    ForEach(ProjectionTypes.allCases, id: \.self) { proj in
                        Text(le(proj.rbKey)).tag(proj)
                    }
                }
            }

            Section {
                Picker(t(ConfigEditKeys.calcBlackMoon), selection: $blackMoonCorrectionType) {
                    ForEach(BlackMoonCorrectionTypes.allCases, id: \.self) { bm in
                        Text(le(bm.rbKey)).tag(bm)
                    }
                }
                Picker(t(ConfigEditKeys.calcLunarNode), selection: $lunarNodeType) {
                    ForEach(LunarNodeTypes.allCases, id: \.self) { node in
                        Text(le(node.rbKey)).tag(node)
                    }
                }
                Picker(t(ConfigEditKeys.calcLotsType), selection: $lotsType) {
                    ForEach(LotsTypes.allCases, id: \.self) { lots in
                        Text(le(lots.rbKey)).tag(lots)
                    }
                }
            }

            Section {
                Stepper(
                    "\(t(ConfigEditKeys.calcStationary)): \(stationaryPercentage)",
                    value: $stationaryPercentage,
                    in: 1...50
                )
            } footer: {
                Text(t(ConfigEditKeys.calcStationaryFooter))
            }

            Section {
                Stepper(
                    "\(t(ConfigEditKeys.calcSlow)): \(slowPercentage)",
                    value: $slowPercentage,
                    in: 1...99
                )
            } footer: {
                Text(t(ConfigEditKeys.calcSlowFooter))
            }
        }
        .navigationTitle(sectionEditorTitle(.calculation))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { CalculationConfigHelpView() }
        .onAppear { loadFromConfig() }
        .onChange(of: houseSystem)            { isDirty = true }
        .onChange(of: ayanamsha)              { isDirty = true }
        .onChange(of: observerPosition)       { isDirty = true }
        .onChange(of: projectionType)         { isDirty = true }
        .onChange(of: blackMoonCorrectionType){ isDirty = true }
        .onChange(of: lunarNodeType)          { isDirty = true }
        .onChange(of: lotsType)               { isDirty = true }
        .onChange(of: stationaryPercentage)   { isDirty = true }
        .onChange(of: slowPercentage)         { isDirty = true }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.calcHelpTooltip))
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) { save() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { loadFromConfig(); isDirty = false }
                }
            }
        }
    }

    private func loadFromConfig() {
        let c = config.calculationConfig
        houseSystem             = c.houseSystem
        ayanamsha               = c.ayanamsha
        observerPosition        = c.observerPosition
        projectionType          = c.projectionType
        blackMoonCorrectionType = c.blackMoonCorrectionType
        lunarNodeType           = c.lunarNodeType
        lotsType                = c.lotsType
        stationaryPercentage    = c.stationaryPercentage
        slowPercentage          = c.slowPercentage
    }

    private func save() {
        config.calculationConfig = CalculationConfig(
            houseSystem:             houseSystem,
            ayanamsha:               ayanamsha,
            observerPosition:        observerPosition,
            projectionType:          projectionType,
            blackMoonCorrectionType: blackMoonCorrectionType,
            lunarNodeType:           lunarNodeType,
            lotsType:                lotsType,
            stationaryPercentage:    stationaryPercentage,
            slowPercentage:          slowPercentage
        )
        try? modelContext.save()
        isDirty = false
    }
}

// MARK: - Calculation help view

struct CalculationConfigHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.calcHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.calcHelpLine1))
                            Text(t(ConfigEditKeys.calcHelpLine2))
                            Text(t(ConfigEditKeys.calcHelpLine3))
                            Text(t(ConfigEditKeys.calcHelpLine4))
                            Text(t(ConfigEditKeys.calcHelpLine5))
                            Text(t(ConfigEditKeys.calcHelpLine6))
                            Text(t(ConfigEditKeys.calcHelpLine7))
                            Text(t(ConfigEditKeys.calcHelpLine8))
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

/// Looks up an enum rbKey in the shared Localizable.strings table.
private func le(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

// MARK: - Display

struct DisplayConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var draft: DisplayConfig = .init()
    @State private var isDirty = false

    var body: some View {
        Form {
            Text(sectionEditorTitle(.display))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            // TODO: Add pickers/color selectors for DisplayConfig properties.
            Section {
                Text("TODO: \(ConfigSection.display.localizedName)")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(sectionEditorTitle(.display))
        .toolbar { saveToolbar }
        .onAppear { draft = config.displayConfig }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) {
                        config.displayConfig = draft
                        try? modelContext.save()
                        isDirty = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { draft = config.displayConfig; isDirty = false }
                }
            }
        }
    }
}

// MARK: - Glyphs

struct GlyphsConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var draft: GlyphsConfig = .init()
    @State private var isDirty = false

    var body: some View {
        Form {
            Text(sectionEditorTitle(.glyphs))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            // TODO: Sign glyphs, factor glyphs, aspect glyphs — three sub-sections.
            Section {
                Text("TODO: \(ConfigSection.glyphs.localizedName)")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(sectionEditorTitle(.glyphs))
        .toolbar { saveToolbar }
        .onAppear { draft = config.glyphsConfig }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) {
                        config.glyphsConfig = draft
                        try? modelContext.save()
                        isDirty = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { draft = config.glyphsConfig; isDirty = false }
                }
            }
        }
    }
}

// MARK: - Factors

struct FactorConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var draft: FactorConfig = .init()
    @State private var isDirty = false

    var body: some View {
        List {
            Text(sectionEditorTitle(.factors))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            // TODO: ForEach over draft.factorSettings with Toggle + Stepper per factor.
            Section {
                Text("TODO: \(ConfigSection.factors.localizedName)")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(sectionEditorTitle(.factors))
        .toolbar { saveToolbar }
        .onAppear { draft = config.factorConfig }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) {
                        config.factorConfig = draft
                        try? modelContext.save()
                        isDirty = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { draft = config.factorConfig; isDirty = false }
                }
            }
        }
    }
}

// MARK: - Aspects

struct AspectConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var draft: AspectConfig = .init()
    @State private var isDirty = false

    var body: some View {
        List {
            Text(sectionEditorTitle(.aspects))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            // TODO: ForEach over draft.aspectSettings with Toggle + Stepper per aspect.
            Section {
                Text("TODO: \(ConfigSection.aspects.localizedName)")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(sectionEditorTitle(.aspects))
        .toolbar { saveToolbar }
        .onAppear { draft = config.aspectConfig }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) {
                        config.aspectConfig = draft
                        try? modelContext.save()
                        isDirty = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { draft = config.aspectConfig; isDirty = false }
                }
            }
        }
    }
}

// MARK: - Orbs

struct OrbConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var draft: OrbConfig = .init()
    @State private var isDirty = false

    var body: some View {
        Form {
            Text(sectionEditorTitle(.orbs))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.sectionOrbs)) {
                // TODO: Picker for orbSystem
                Text("TODO: OrbSystem picker")
                    .foregroundStyle(.secondary)
            }
            Section {
                // TODO: Steppers/TextFields for aspectBaseOrb, midpointOrb, harmonicOrb, parallelOrb
                Text("TODO: Orb-waarden invoer")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(sectionEditorTitle(.orbs))
        .toolbar { saveToolbar }
        .onAppear { draft = config.orbConfig }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) {
                        config.orbConfig = draft
                        try? modelContext.save()
                        isDirty = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { draft = config.orbConfig; isDirty = false }
                }
            }
        }
    }
}

// MARK: - Progressions

struct ProgressionsConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var draft: ProgressionsConfig = .init()
    @State private var isDirty = false

    var body: some View {
        List {
            Text(sectionEditorTitle(.progressions))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            // TODO: Sub-sections for PrimaryDirections, Transits,
            //       SecondaryDirections, SymbolicDirections, SolarReturn.
            Section {
                Text("TODO: \(ConfigSection.progressions.localizedName)")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(sectionEditorTitle(.progressions))
        .toolbar { saveToolbar }
        .onAppear { draft = config.progressionsConfig }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
            if isDirty {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(ConfigEditKeys.editSave)) {
                        config.progressionsConfig = draft
                        try? modelContext.save()
                        isDirty = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ConfigEditKeys.cancel)) { draft = config.progressionsConfig; isDirty = false }
                }
            }
        }
    }
}

// MARK: - Localization helpers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ConfigEdit", bundle: .main, comment: "")
}

/// Builds a section editor title: "<config label> <section name>", e.g. "Configuratie berekening".
private func sectionEditorTitle(_ section: ConfigSection) -> String {
    "\(t(ConfigEditKeys.editFallbackTitle)) \(section.localizedName.lowercased())"
}
