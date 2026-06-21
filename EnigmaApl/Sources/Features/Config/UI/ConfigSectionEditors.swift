// ConfigSectionEditors.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

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
        lunarNodeType           = c.lunarNodeType
        lotsType                = c.lotsType
        stationaryPercentage    = c.stationaryPercentage
        slowPercentage          = c.slowPercentage
    }

    private func save() {
        config.calculationConfig = CalculationConfig(
            houseSystem:          houseSystem,
            ayanamsha:            ayanamsha,
            observerPosition:     observerPosition,
            projectionType:       projectionType,
            lunarNodeType:        lunarNodeType,
            lotsType:             lotsType,
            stationaryPercentage: stationaryPercentage,
            slowPercentage:       slowPercentage
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

    @State private var drawingType: DrawingType = .signBased
    @State private var signColors: [Signs: Color] = [:]
    @State private var isDirty = false
    @State private var showHelp = false

    var body: some View {
        Form {
            Text(sectionEditorTitle(.display))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 4)
                .listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.displaySectionDrawing)) {
                Picker("", selection: $drawingType) {
                    ForEach(DrawingType.allCases, id: \.self) { type in
                        Text(le(type.rbKey)).tag(type)
                    }
                }
            }
            Section(t(ConfigEditKeys.displaySectionSignColors)) {
                ForEach(Signs.allCases, id: \.self) { sign in
                    LabeledContent(le(sign.rbKey)) {
                        ColorPicker("", selection: colorBinding(for: sign))
                            .labelsHidden()
                    }
                }
            }
        }
        .navigationTitle(sectionEditorTitle(.display))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { DisplayConfigHelpView() }
        .onAppear { loadFromConfig() }
        .onChange(of: drawingType) { isDirty = true }
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
                .help(t(ConfigEditKeys.displayHelpTooltip))
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

    /// Returns a Binding<Color> for a sign, using the default sign color when absent.
    private func colorBinding(for sign: Signs) -> Binding<Color> {
        Binding(
            get: { signColors[sign] ?? Color(ColorConfig.defaultSignColor) },
            set: { newColor in
                signColors[sign] = newColor
                isDirty = true
            }
        )
    }

    private func loadFromConfig() {
        drawingType = config.displayConfig.drawingType
        // Build map from existing overrides; missing signs will use the default.
        signColors = Dictionary(
            uniqueKeysWithValues: config.displayConfig.signColors.map {
                ($0.sign, Color($0.color))
            }
        )
    }

    private func save() {
        let overrides = Signs.allCases.map { sign in
            SignColorOverride(
                sign: sign,
                color: (signColors[sign] ?? Color(ColorConfig.defaultSignColor)).colorConfig
            )
        }
        config.displayConfig = DisplayConfig(
            drawingType: drawingType,
            signColors: overrides
        )
        try? modelContext.save()
        isDirty = false
    }
}

// MARK: - Display help view

struct DisplayConfigHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.displayHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.displayHelpLine1))
                            Text(t(ConfigEditKeys.displayHelpLine2))
                            Text(t(ConfigEditKeys.displayHelpLine3))
                            Text(t(ConfigEditKeys.displayHelpLine4))
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

// MARK: - Glyphs

struct GlyphsConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var signGlyphs:   [Signs: String]   = [:]
    @State private var factorGlyphs: [Factors: String] = [:]
    @State private var aspectGlyphs: [Aspects: String] = [:]
    @State private var isDirty = false
    @State private var showHelp = false

    private let signsWithChoice   = Signs.allCases.filter   { GlyphCandidates.candidates(for: $0).count > 1 }
    private let factorsWithChoice = Factors.allCases.filter { GlyphCandidates.candidates(for: $0).count > 1 }
    private let aspectsWithChoice = Aspects.allCases.filter { GlyphCandidates.candidates(for: $0).count > 1 }

    var body: some View {
        Form {
            Text(sectionEditorTitle(.glyphs))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 4)
                .listRowBackground(Color.clear)
            if !signsWithChoice.isEmpty {
                Section(t(ConfigEditKeys.glyphsSectionSigns)) {
                    ForEach(signsWithChoice, id: \.self) { sign in
                        glyphRow(label: le(sign.rbKey),
                                 candidates: GlyphCandidates.candidates(for: sign),
                                 current: signGlyphs[sign] ?? "") { g in
                            signGlyphs[sign] = g; isDirty = true
                        }
                    }
                }
            }
            if !factorsWithChoice.isEmpty {
                Section(t(ConfigEditKeys.glyphsSectionFactors)) {
                    ForEach(factorsWithChoice, id: \.self) { factor in
                        glyphRow(label: le(factor.localizedName),
                                 candidates: GlyphCandidates.candidates(for: factor),
                                 current: factorGlyphs[factor] ?? "") { g in
                            factorGlyphs[factor] = g; isDirty = true
                        }
                    }
                }
            }
            if !aspectsWithChoice.isEmpty {
                Section(t(ConfigEditKeys.glyphsSectionAspects)) {
                    ForEach(aspectsWithChoice, id: \.self) { aspect in
                        glyphRow(label: le(aspect.rbKey),
                                 candidates: GlyphCandidates.candidates(for: aspect),
                                 current: aspectGlyphs[aspect] ?? "") { g in
                            aspectGlyphs[aspect] = g; isDirty = true
                        }
                    }
                }
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(sectionEditorTitle(.glyphs))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { GlyphsConfigHelpView() }
        .onAppear { loadFromConfig() }
    }

    private func glyphRow(label: String, candidates: [String], current: String,
                          onSelect: @escaping (String) -> Void) -> some View {
        LabeledContent(label) {
            HStack(spacing: 6) {
                ForEach(candidates, id: \.self) { glyph in
                    Button { onSelect(glyph) } label: {
                        Text(glyph)
                            .font(.custom("EnigmaAstrology3", size: 20))
                            .frame(width: 28, height: 28)
                            .background(current == glyph ? Color.accentColor.opacity(0.25) : Color.clear)
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
                .help(t(ConfigEditKeys.glyphsHelpTooltip))
            }
            ToolbarItem(placement: .primaryAction) {
                Button(t(ConfigEditKeys.glyphsRestoreDefaults)) { restoreDefaults() }
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
        // Start from the live GlyphSelector state (which includes migration fixes applied at startup),
        // then let stored user overrides take precedence.
        signGlyphs   = Dictionary(uniqueKeysWithValues: Signs.allCases.map   { ($0, GlyphSelector.getGlyphForSign($0)) })
        factorGlyphs = Dictionary(uniqueKeysWithValues: Factors.allCases.map { ($0, GlyphSelector.getGlyphForFactor($0)) })
        aspectGlyphs = Dictionary(uniqueKeysWithValues: Aspects.allCases.map { ($0, GlyphSelector.getGlyphForAspect($0)) })
    }

    private func restoreDefaults() {
        signGlyphs   = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultSignGlyphs.map   { ($0.sign,   $0.glyph) })
        factorGlyphs = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultFactorGlyphs.map { ($0.factor, $0.glyph) })
        aspectGlyphs = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultAspectGlyphs.map { ($0.aspect, $0.glyph) })
        isDirty = true
    }

    private func save() {
        let defSigns   = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultSignGlyphs.map   { ($0.sign,   $0.glyph) })
        let defFactors = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultFactorGlyphs.map { ($0.factor, $0.glyph) })
        let defAspects = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultAspectGlyphs.map { ($0.aspect, $0.glyph) })
        config.glyphsConfig = GlyphsConfig(
            signGlyphs:   Signs.allCases.map   { SignGlyphSetting(sign: $0,     glyph: signGlyphs[$0]   ?? defSigns[$0]   ?? "") },
            factorGlyphs: Factors.allCases.map { FactorGlyphSetting(factor: $0, glyph: factorGlyphs[$0] ?? defFactors[$0] ?? "") },
            aspectGlyphs: Aspects.allCases.map { AspectGlyphSetting(aspect: $0, glyph: aspectGlyphs[$0] ?? defAspects[$0] ?? "") }
        )
        try? modelContext.save()
        GlyphSelector.configure(with: config.glyphsConfig)
        isDirty = false
    }
}

// MARK: - Glyphs help view

struct GlyphsConfigHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.glyphsHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.glyphsHelpLine1))
                            Text(t(ConfigEditKeys.glyphsHelpLine2))
                            Text(t(ConfigEditKeys.glyphsHelpLine3))
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

// MARK: - Factors

struct FactorConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var isUsed:        [Factors: Bool]
    @State private var isDrawn:       [Factors: Bool]
    @State private var orbPercentage: [Factors: Int]
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        var used: [Factors: Bool] = [:]
        var drawn: [Factors: Bool] = [:]
        var orbs: [Factors: Int] = [:]
        for s in config.factorConfig.factorSettings {
            used[s.factor]  = s.isUsed
            drawn[s.factor] = s.isDrawn
            orbs[s.factor]  = s.orbPercentage
        }
        _isUsed        = State(initialValue: used)
        _isDrawn       = State(initialValue: drawn)
        _orbPercentage = State(initialValue: orbs)
    }

    var body: some View {
        List {
            Text(sectionEditorTitle(.factors))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 4)
                .listRowBackground(Color.clear)
            Section {
                ForEach(Factors.allCases, id: \.self) { factor in
                    factorRow(factor)
                }
            } header: {
                HStack {
                    Text("").frame(width: 28)
                    Text("").frame(maxWidth: .infinity, alignment: .leading)
                    Text(t(ConfigEditKeys.factorColUsed))
                        .frame(width: 60, alignment: .center)
                    Text(t(ConfigEditKeys.factorColDrawn))
                        .frame(width: 60, alignment: .center)
                    Text(t(ConfigEditKeys.factorColOrb))
                        .frame(width: 100, alignment: .center)
                }
                .textCase(nil)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(sectionEditorTitle(.factors))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { FactorConfigHelpView() }
        .onAppear { loadFromConfig() }
    }

    private func factorRow(_ factor: Factors) -> some View {
        HStack {
            Text(GlyphSelector.getGlyphForFactor(factor))
                .font(.custom("EnigmaAstrology3", size: 16))
                .frame(width: 28)
            Text(le(factor.localizedName))
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: Binding(
                get: { isUsed[factor] ?? false },
                set: { isUsed[factor] = $0; isDirty = true }
            ))
            .labelsHidden()
            .frame(width: 60)
            Toggle("", isOn: Binding(
                get: { isDrawn[factor] ?? false },
                set: { isDrawn[factor] = $0; isDirty = true }
            ))
            .labelsHidden()
            .frame(width: 60)
            .disabled(!(isUsed[factor] ?? false))
            Text("\(orbPercentage[factor] ?? 50)%")
                .frame(width: 36, alignment: .trailing)
            Stepper("", value: Binding(
                get: { orbPercentage[factor] ?? 50 },
                set: { orbPercentage[factor] = $0; isDirty = true }
            ), in: 0...100, step: 1)
            .labelsHidden()
            .fixedSize()
        }
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
                .help(t(ConfigEditKeys.factorHelpTooltip))
            }
            ToolbarItem(placement: .primaryAction) {
                Button(t(ConfigEditKeys.factorRestoreDefaults)) { restoreDefaults() }
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
        for s in config.factorConfig.factorSettings {
            isUsed[s.factor]        = s.isUsed
            isDrawn[s.factor]       = s.isDrawn
            orbPercentage[s.factor] = s.orbPercentage
        }
    }

    private func restoreDefaults() {
        for s in FactorConfig.defaultSettings {
            isUsed[s.factor]        = s.isUsed
            isDrawn[s.factor]       = s.isDrawn
            orbPercentage[s.factor] = s.orbPercentage
        }
        isDirty = true
    }

    private func save() {
        let defMap = Dictionary(uniqueKeysWithValues: FactorConfig.defaultSettings.map { ($0.factor, $0) })
        config.factorConfig = FactorConfig(factorSettings: Factors.allCases.map { factor in
            FactorSettings(
                factor:        factor,
                isUsed:        isUsed[factor]        ?? defMap[factor]?.isUsed        ?? false,
                isDrawn:       isDrawn[factor]       ?? defMap[factor]?.isDrawn       ?? false,
                orbPercentage: orbPercentage[factor] ?? defMap[factor]?.orbPercentage ?? 50
            )
        })
        try? modelContext.save()
        isDirty = false
    }
}

// MARK: - Factor help view

struct FactorConfigHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.factorHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.factorHelpLine1))
                            Text(t(ConfigEditKeys.factorHelpLine2))
                            Text(t(ConfigEditKeys.factorHelpLine3))
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

// MARK: - Aspects

struct AspectConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var isUsed:        [Aspects: Bool]
    @State private var isDrawn:       [Aspects: Bool]
    @State private var orbPercentage: [Aspects: Int]
    @State private var colors:        [Aspects: Color]
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        var used:  [Aspects: Bool]  = [:]
        var drawn: [Aspects: Bool]  = [:]
        var orbs:  [Aspects: Int]   = [:]
        var cols:  [Aspects: Color] = [:]
        for s in config.aspectConfig.aspectSettings {
            used[s.aspect]  = s.isUsed
            drawn[s.aspect] = s.isDrawn
            orbs[s.aspect]  = s.orbPercentage
            cols[s.aspect]  = Color(s.color)
        }
        _isUsed        = State(initialValue: used)
        _isDrawn       = State(initialValue: drawn)
        _orbPercentage = State(initialValue: orbs)
        _colors        = State(initialValue: cols)
    }

    var body: some View {
        List {
            Text(sectionEditorTitle(.aspects))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 4)
                .listRowBackground(Color.clear)
            Section {
                ForEach(Aspects.allCases, id: \.self) { aspect in
                    aspectRow(aspect)
                }
            } header: {
                HStack {
                    Text("").frame(width: 28)
                    Text("").frame(maxWidth: .infinity, alignment: .leading)
                    Text(t(ConfigEditKeys.aspectColUsed))
                        .frame(width: 60, alignment: .center)
                    Text(t(ConfigEditKeys.aspectColDrawn))
                        .frame(width: 60, alignment: .center)
                    Text(t(ConfigEditKeys.aspectColOrb))
                        .frame(width: 100, alignment: .center)
                    Text(t(ConfigEditKeys.aspectColColor))
                        .frame(width: 50, alignment: .center)
                }
                .textCase(nil)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(sectionEditorTitle(.aspects))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { AspectConfigHelpView() }
        .onAppear { loadFromConfig() }
    }

    private func aspectRow(_ aspect: Aspects) -> some View {
        HStack {
            Text(GlyphSelector.getGlyphForAspect(aspect))
                .font(.custom("EnigmaAstrology3", size: 16))
                .frame(width: 28)
            Text(le(aspect.rbKey))
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: Binding(
                get: { isUsed[aspect] ?? false },
                set: { isUsed[aspect] = $0; isDirty = true }
            ))
            .labelsHidden()
            .frame(width: 60)
            Toggle("", isOn: Binding(
                get: { isDrawn[aspect] ?? false },
                set: { isDrawn[aspect] = $0; isDirty = true }
            ))
            .labelsHidden()
            .frame(width: 60)
            .disabled(!(isUsed[aspect] ?? false))
            Text("\(orbPercentage[aspect] ?? 50)%")
                .frame(width: 36, alignment: .trailing)
            Stepper("", value: Binding(
                get: { orbPercentage[aspect] ?? 50 },
                set: { orbPercentage[aspect] = $0; isDirty = true }
            ), in: 0...100, step: 1)
            .labelsHidden()
            .fixedSize()
            ColorPicker("", selection: Binding(
                get: { colors[aspect] ?? Color(AspectSettings.defaultColor(for: aspect)) },
                set: { colors[aspect] = $0; isDirty = true }
            ))
            .labelsHidden()
            .frame(width: 50)
        }
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
                .help(t(ConfigEditKeys.aspectHelpTooltip))
            }
            ToolbarItem(placement: .primaryAction) {
                Button(t(ConfigEditKeys.aspectRestoreDefaults)) { restoreDefaults() }
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
        for s in config.aspectConfig.aspectSettings {
            isUsed[s.aspect]        = s.isUsed
            isDrawn[s.aspect]       = s.isDrawn
            orbPercentage[s.aspect] = s.orbPercentage
            colors[s.aspect]        = Color(s.color)
        }
    }

    private func restoreDefaults() {
        for s in AspectConfig.defaultSettings {
            isUsed[s.aspect]        = s.isUsed
            isDrawn[s.aspect]       = s.isDrawn
            orbPercentage[s.aspect] = s.orbPercentage
            colors[s.aspect]        = Color(s.color)
        }
        isDirty = true
    }

    private func save() {
        let defMap = Dictionary(uniqueKeysWithValues: AspectConfig.defaultSettings.map { ($0.aspect, $0) })
        config.aspectConfig = AspectConfig(aspectSettings: Aspects.allCases.map { aspect in
            AspectSettings(
                aspect:        aspect,
                isUsed:        isUsed[aspect]        ?? defMap[aspect]?.isUsed        ?? false,
                isDrawn:       isDrawn[aspect]       ?? defMap[aspect]?.isDrawn       ?? false,
                orbPercentage: orbPercentage[aspect] ?? defMap[aspect]?.orbPercentage ?? 50,
                color:         (colors[aspect] ?? Color(AspectSettings.defaultColor(for: aspect))).colorConfig
            )
        })
        try? modelContext.save()
        isDirty = false
    }
}

// MARK: - Aspect help view

struct AspectConfigHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.aspectHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.aspectHelpLine1))
                            Text(t(ConfigEditKeys.aspectHelpLine2))
                            Text(t(ConfigEditKeys.aspectHelpLine3))
                            Text(t(ConfigEditKeys.aspectHelpLine4))
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

// MARK: - Orbs

struct OrbConfigEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let config: UserConfiguration

    @State private var orbSystem:        OrbSystem = .procentual
    @State private var aspectBaseDeg:    Int = 10
    @State private var aspectBaseMin:    Int = 0
    @State private var midpoint360Deg:   Int = 1
    @State private var midpoint360Min:   Int = 30
    @State private var midpoint90Deg:    Int = 1
    @State private var midpoint90Min:    Int = 0
    @State private var midpoint45Deg:    Int = 0
    @State private var midpoint45Min:    Int = 30
    @State private var harmonicDeg:      Int = 2
    @State private var harmonicMin:      Int = 0
    @State private var parallelDeg:      Int = 1
    @State private var parallelMin:      Int = 0
    @State private var declinationMidpointDeg: Int = 0
    @State private var declinationMidpointMin: Int = 45
    @State private var isDirty = false
    @State private var showHelp = false

    var body: some View {
        Form {
            Text(sectionEditorTitle(.orbs))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 4)
                .listRowBackground(Color.clear)
            Section {
                Picker(t(ConfigEditKeys.orbSystem), selection: $orbSystem) {
                    ForEach(OrbSystem.allCases, id: \.self) { system in
                        Text(le(system.rbKey)).tag(system)
                    }
                }
            }
            Section(t(ConfigEditKeys.orbSectionValues)) {
                orbRow(label: t(ConfigEditKeys.orbAspectBase),
                       deg: $aspectBaseDeg, min: $aspectBaseMin, maxDeg: 30)
                orbRow(label: t(ConfigEditKeys.orbMidpoint360),
                       deg: $midpoint360Deg, min: $midpoint360Min, maxDeg: 10)
                orbRow(label: t(ConfigEditKeys.orbMidpoint90),
                       deg: $midpoint90Deg,  min: $midpoint90Min,  maxDeg: 10)
                orbRow(label: t(ConfigEditKeys.orbMidpoint45),
                       deg: $midpoint45Deg,  min: $midpoint45Min,  maxDeg: 10)
                orbRow(label: t(ConfigEditKeys.orbHarmonic),
                       deg: $harmonicDeg,   min: $harmonicMin,   maxDeg: 10)
                orbRow(label: t(ConfigEditKeys.orbParallel),
                       deg: $parallelDeg,   min: $parallelMin,   maxDeg: 10)
                orbRow(label: t(ConfigEditKeys.orbDeclinationMidpoint),
                       deg: $declinationMidpointDeg, min: $declinationMidpointMin, maxDeg: 10)
            }
        }
        .navigationTitle(sectionEditorTitle(.orbs))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { OrbConfigHelpView() }
        .onAppear { loadFromConfig() }
        .onChange(of: orbSystem) { isDirty = true }
    }

    private func orbRow(label: String,
                        deg: Binding<Int>, min: Binding<Int>,
                        maxDeg: Int) -> some View {
        LabeledContent(label) {
            HStack(spacing: 4) {
                Text("\(deg.wrappedValue)°")
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
                Stepper("", value: deg, in: 0...maxDeg)
                    .labelsHidden().fixedSize()
                    .onChange(of: deg.wrappedValue) { isDirty = true }
                Text("\(min.wrappedValue)'")
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
                Stepper("", value: min, in: 0...59)
                    .labelsHidden().fixedSize()
                    .onChange(of: min.wrappedValue) { isDirty = true }
            }
        }
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
                .help(t(ConfigEditKeys.orbHelpTooltip))
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
        let c = config.orbConfig
        orbSystem = c.orbSystem
        (aspectBaseDeg, aspectBaseMin) = sexagesimalFromDouble(c.aspectBaseOrb)
        (midpoint360Deg, midpoint360Min) = sexagesimalFromDouble(c.midpoint360DialOrb)
        (midpoint90Deg,  midpoint90Min)  = sexagesimalFromDouble(c.midpoint90DialOrb)
        (midpoint45Deg,  midpoint45Min)  = sexagesimalFromDouble(c.midpoint45DialOrb)
        (harmonicDeg,   harmonicMin)   = sexagesimalFromDouble(c.harmonicOrb)
        (parallelDeg,   parallelMin)   = sexagesimalFromDouble(c.parallelOrb)
        (declinationMidpointDeg, declinationMidpointMin) = sexagesimalFromDouble(c.declinationMidpointOrb)
    }

    private func save() {
        config.orbConfig = OrbConfig(
            orbSystem:     orbSystem,
            aspectBaseOrb: doubleFromSexagesimal(aspectBaseDeg, aspectBaseMin),
            midpoint360DialOrb: doubleFromSexagesimal(midpoint360Deg, midpoint360Min),
            midpoint90DialOrb:  doubleFromSexagesimal(midpoint90Deg,  midpoint90Min),
            midpoint45DialOrb:  doubleFromSexagesimal(midpoint45Deg,  midpoint45Min),
            harmonicOrb:   doubleFromSexagesimal(harmonicDeg,   harmonicMin),
            parallelOrb:   doubleFromSexagesimal(parallelDeg,   parallelMin),
            declinationMidpointOrb: doubleFromSexagesimal(declinationMidpointDeg, declinationMidpointMin)
        )
        try? modelContext.save()
        isDirty = false
    }

}

// MARK: - Orb help view

struct OrbConfigHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.orbHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.orbHelpLine1))
                            Text(t(ConfigEditKeys.orbHelpLine2))
                            Text(t(ConfigEditKeys.orbHelpLine3))
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

// MARK: - Progressions (navigation hub)

struct ProgressionsConfigEditor: View {
    @Environment(\.dismiss) private var dismiss
    let config: UserConfiguration

    var body: some View {
        List {
            Text(sectionEditorTitle(.progressions))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 4)
                .listRowBackground(Color.clear)
            Section {
                NavigationLink(t(ConfigEditKeys.progNavPrimary)) {
                    PrimaryDirectionsEditor(config: config)
                }
                NavigationLink(t(ConfigEditKeys.progNavTransits)) {
                    TransitsEditor(config: config)
                }
                NavigationLink(t(ConfigEditKeys.progNavSecondary)) {
                    SecondaryDirectionsEditor(config: config)
                }
                NavigationLink(t(ConfigEditKeys.progNavSymbolic)) {
                    SymbolicDirectionsEditor(config: config)
                }
                NavigationLink(t(ConfigEditKeys.progNavSolar)) {
                    SolarReturnEditor(config: config)
                }
            }
        }
        .navigationTitle(sectionEditorTitle(.progressions))
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(t(ConfigEditKeys.backToOverview)) { dismiss() }
            }
        }
    }
}

// MARK: - Progressions shared helpers

private struct ProgFactorRow: View {
    let factor: Factors
    @Binding var isSelected: Bool

    var body: some View {
        HStack {
            Text(GlyphSelector.getGlyphForFactor(factor))
                .font(.custom("EnigmaAstrology3", size: 16))
                .frame(width: 28)
            Text(le(factor.localizedName))
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isSelected)
                .labelsHidden()
        }
    }
}

private struct ProgOrbRow: View {
    @Binding var deg: Int
    @Binding var min: Int
    @Binding var isDirty: Bool

    var body: some View {
        LabeledContent(t(ConfigEditKeys.progOrbLabel)) {
            HStack(spacing: 4) {
                Text("\(deg)°")
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
                Stepper("", value: $deg, in: 0...10)
                    .labelsHidden().fixedSize()
                    .onChange(of: deg) { isDirty = true }
                Text("\(min)'")
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
                Stepper("", value: $min, in: 0...59)
                    .labelsHidden().fixedSize()
                    .onChange(of: min) { isDirty = true }
            }
        }
    }
}

// MARK: - Primary Directions

struct PrimaryDirectionsEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let config: UserConfiguration

    @State private var promissors:    [Factors: Bool]
    @State private var significators: [Factors: Bool]
    @State private var orbDeg:  Int
    @State private var orbMin:  Int
    @State private var method:   PrimaryMethod
    @State private var approach: PrimaryApproach
    @State private var timeKey:  PrimaryTimeKey
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        let c = config.progressionsConfig.primaryDirections
        let selProm = Set(c.promissors)
        let selSig  = Set(c.significators)
        var prom: [Factors: Bool] = [:]
        var sig:  [Factors: Bool] = [:]
        for f in Factors.allCases {
            prom[f] = selProm.contains(f)
            sig[f]  = selSig.contains(f)
        }
        let (deg, min) = sexagesimalFromDouble(c.orb)
        _promissors    = State(initialValue: prom)
        _significators = State(initialValue: sig)
        _orbDeg        = State(initialValue: deg)
        _orbMin        = State(initialValue: min)
        _method        = State(initialValue: c.method)
        _approach      = State(initialValue: c.approach)
        _timeKey       = State(initialValue: c.timeKey)
    }

    var body: some View {
        List {
            Text(t(ConfigEditKeys.progNavPrimary))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer().frame(height: 4).listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.progSectionSettings)) {
                Picker(t(ConfigEditKeys.progPrimaryMethod), selection: $method) {
                    ForEach(PrimaryMethod.allCases, id: \.self) { m in
                        Text(le(m.rbKey)).tag(m)
                    }
                }
                Picker(t(ConfigEditKeys.progPrimaryApproach), selection: $approach) {
                    ForEach(PrimaryApproach.allCases, id: \.self) { a in
                        Text(le(a.rbKey)).tag(a)
                    }
                }
                Picker(t(ConfigEditKeys.progPrimaryTimeKey), selection: $timeKey) {
                    ForEach(PrimaryTimeKey.allCases, id: \.self) { tk in
                        Text(le(tk.rbKey)).tag(tk)
                    }
                }
                ProgOrbRow(deg: $orbDeg, min: $orbMin, isDirty: $isDirty)
            }
            Section {
                ForEach(Factors.allCases, id: \.self) { factor in
                    HStack {
                        Text(GlyphSelector.getGlyphForFactor(factor))
                            .font(.custom("EnigmaAstrology3", size: 16))
                            .frame(width: 28)
                        Text(le(factor.localizedName))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Toggle("", isOn: Binding(
                            get: { promissors[factor] ?? false },
                            set: { promissors[factor] = $0; isDirty = true }
                        ))
                        .labelsHidden()
                        .frame(width: 70)
                        Toggle("", isOn: Binding(
                            get: { significators[factor] ?? false },
                            set: { significators[factor] = $0; isDirty = true }
                        ))
                        .labelsHidden()
                        .frame(width: 90)
                    }
                }
            } header: {
                HStack {
                    Text("").frame(width: 28)
                    Text("").frame(maxWidth: .infinity, alignment: .leading)
                    Text(t(ConfigEditKeys.progPrimaryPromissors))
                        .frame(width: 70, alignment: .center)
                    Text(t(ConfigEditKeys.progPrimarySignificators))
                        .frame(width: 90, alignment: .center)
                }
                .textCase(nil)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(t(ConfigEditKeys.progNavPrimary))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { PrimaryDirectionsHelpView() }
        .onChange(of: method)   { isDirty = true }
        .onChange(of: approach) { isDirty = true }
        .onChange(of: timeKey)  { isDirty = true }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.progPrimaryHelpTooltip))
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
        let c = config.progressionsConfig.primaryDirections
        let selProm = Set(c.promissors)
        let selSig  = Set(c.significators)
        for f in Factors.allCases {
            promissors[f]    = selProm.contains(f)
            significators[f] = selSig.contains(f)
        }
        (orbDeg, orbMin) = sexagesimalFromDouble(c.orb)
        method   = c.method
        approach = c.approach
        timeKey  = c.timeKey
    }

    private func save() {
        let pd = config.progressionsConfig
        config.progressionsConfig = ProgressionsConfig(
            primaryDirections: PrimaryDirectionsConfig(
                promissors:    Factors.allCases.filter { promissors[$0] ?? false },
                significators: Factors.allCases.filter { significators[$0] ?? false },
                orb:           doubleFromSexagesimal(orbDeg, orbMin),
                method:        method,
                approach:      approach,
                timeKey:       timeKey
            ),
            transits:            pd.transits,
            secondaryDirections: pd.secondaryDirections,
            symbolicDirections:  pd.symbolicDirections,
            solarReturn:         pd.solarReturn
        )
        try? modelContext.save()
        isDirty = false
    }
}

struct PrimaryDirectionsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.progPrimaryHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.progPrimaryHelpLine3))
                            Text(t(ConfigEditKeys.progPrimaryHelpLine1))
                            Text(t(ConfigEditKeys.progPrimaryHelpLine2))
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

// MARK: - Transits

struct TransitsEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let config: UserConfiguration

    @State private var factors: [Factors: Bool]
    @State private var orbDeg:  Int
    @State private var orbMin:  Int
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        let c = config.progressionsConfig.transits
        let selected = Set(c.factors)
        var f: [Factors: Bool] = [:]
        for factor in Factors.allCases { f[factor] = selected.contains(factor) }
        let (deg, min) = sexagesimalFromDouble(c.orb)
        _factors = State(initialValue: f)
        _orbDeg  = State(initialValue: deg)
        _orbMin  = State(initialValue: min)
    }

    var body: some View {
        List {
            Text(t(ConfigEditKeys.progNavTransits))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer().frame(height: 4).listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.progSectionOrb)) {
                ProgOrbRow(deg: $orbDeg, min: $orbMin, isDirty: $isDirty)
            }
            Section(t(ConfigEditKeys.progSectionFactors)) {
                ForEach(Factors.allCases, id: \.self) { factor in
                    ProgFactorRow(factor: factor, isSelected: Binding(
                        get: { factors[factor] ?? false },
                        set: { factors[factor] = $0; isDirty = true }
                    ))
                }
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(t(ConfigEditKeys.progNavTransits))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { TransitsHelpView() }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.progTransitsHelpTooltip))
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
        let c = config.progressionsConfig.transits
        let selected = Set(c.factors)
        for f in Factors.allCases { factors[f] = selected.contains(f) }
        (orbDeg, orbMin) = sexagesimalFromDouble(c.orb)
    }

    private func save() {
        let pd = config.progressionsConfig
        config.progressionsConfig = ProgressionsConfig(
            primaryDirections:   pd.primaryDirections,
            transits: TransitsConfig(
                factors: Factors.allCases.filter { factors[$0] ?? false },
                orb:     doubleFromSexagesimal(orbDeg, orbMin)
            ),
            secondaryDirections: pd.secondaryDirections,
            symbolicDirections:  pd.symbolicDirections,
            solarReturn:         pd.solarReturn
        )
        try? modelContext.save()
        isDirty = false
    }
}

struct TransitsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.progTransitsHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.progTransitsHelpLine2))
                            Text(t(ConfigEditKeys.progTransitsHelpLine1))
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

// MARK: - Secondary Directions

struct SecondaryDirectionsEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let config: UserConfiguration

    @State private var factors: [Factors: Bool]
    @State private var orbDeg:  Int
    @State private var orbMin:  Int
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        let c = config.progressionsConfig.secondaryDirections
        let selected = Set(c.factors)
        var f: [Factors: Bool] = [:]
        for factor in Factors.allCases { f[factor] = selected.contains(factor) }
        let (deg, min) = sexagesimalFromDouble(c.orb)
        _factors = State(initialValue: f)
        _orbDeg  = State(initialValue: deg)
        _orbMin  = State(initialValue: min)
    }

    var body: some View {
        List {
            Text(t(ConfigEditKeys.progNavSecondary))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer().frame(height: 4).listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.progSectionOrb)) {
                ProgOrbRow(deg: $orbDeg, min: $orbMin, isDirty: $isDirty)
            }
            Section(t(ConfigEditKeys.progSectionFactors)) {
                ForEach(Factors.allCases, id: \.self) { factor in
                    ProgFactorRow(factor: factor, isSelected: Binding(
                        get: { factors[factor] ?? false },
                        set: { factors[factor] = $0; isDirty = true }
                    ))
                }
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(t(ConfigEditKeys.progNavSecondary))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { SecondaryDirectionsHelpView() }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.progSecondaryHelpTooltip))
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
        let c = config.progressionsConfig.secondaryDirections
        let selected = Set(c.factors)
        for f in Factors.allCases { factors[f] = selected.contains(f) }
        (orbDeg, orbMin) = sexagesimalFromDouble(c.orb)
    }

    private func save() {
        let pd = config.progressionsConfig
        config.progressionsConfig = ProgressionsConfig(
            primaryDirections:   pd.primaryDirections,
            transits:            pd.transits,
            secondaryDirections: SecondaryDirectionsConfig(
                factors: Factors.allCases.filter { factors[$0] ?? false },
                orb:     doubleFromSexagesimal(orbDeg, orbMin)
            ),
            symbolicDirections:  pd.symbolicDirections,
            solarReturn:         pd.solarReturn
        )
        try? modelContext.save()
        isDirty = false
    }
}

struct SecondaryDirectionsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.progSecondaryHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.progSecondaryHelpLine2))
                            Text(t(ConfigEditKeys.progSecondaryHelpLine1))
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

// MARK: - Symbolic Directions

struct SymbolicDirectionsEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let config: UserConfiguration

    @State private var factors: [Factors: Bool]
    @State private var orbDeg:  Int
    @State private var orbMin:  Int
    @State private var timeKey: SymbolicTimeKey
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        let c = config.progressionsConfig.symbolicDirections
        let selected = Set(c.factors)
        var f: [Factors: Bool] = [:]
        for factor in Factors.allCases { f[factor] = selected.contains(factor) }
        let (deg, min) = sexagesimalFromDouble(c.orb)
        _factors = State(initialValue: f)
        _orbDeg  = State(initialValue: deg)
        _orbMin  = State(initialValue: min)
        _timeKey = State(initialValue: c.timeKey)
    }

    var body: some View {
        List {
            Text(t(ConfigEditKeys.progNavSymbolic))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer().frame(height: 4).listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.progSectionSettings)) {
                Picker(t(ConfigEditKeys.progSymbolicTimeKey), selection: $timeKey) {
                    ForEach(SymbolicTimeKey.allCases, id: \.self) { tk in
                        Text(le(tk.rbKey)).tag(tk)
                    }
                }
                ProgOrbRow(deg: $orbDeg, min: $orbMin, isDirty: $isDirty)
            }
            Section(t(ConfigEditKeys.progSectionFactors)) {
                ForEach(Factors.allCases, id: \.self) { factor in
                    ProgFactorRow(factor: factor, isSelected: Binding(
                        get: { factors[factor] ?? false },
                        set: { factors[factor] = $0; isDirty = true }
                    ))
                }
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle(t(ConfigEditKeys.progNavSymbolic))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { SymbolicDirectionsHelpView() }
        .onChange(of: timeKey) { isDirty = true }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.progSymbolicHelpTooltip))
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
        let c = config.progressionsConfig.symbolicDirections
        let selected = Set(c.factors)
        for f in Factors.allCases { factors[f] = selected.contains(f) }
        (orbDeg, orbMin) = sexagesimalFromDouble(c.orb)
        timeKey = c.timeKey
    }

    private func save() {
        let pd = config.progressionsConfig
        config.progressionsConfig = ProgressionsConfig(
            primaryDirections:   pd.primaryDirections,
            transits:            pd.transits,
            secondaryDirections: pd.secondaryDirections,
            symbolicDirections: SymbolicDirectionsConfig(
                factors: Factors.allCases.filter { factors[$0] ?? false },
                orb:     doubleFromSexagesimal(orbDeg, orbMin),
                timeKey: timeKey
            ),
            solarReturn: pd.solarReturn
        )
        try? modelContext.save()
        isDirty = false
    }
}

struct SymbolicDirectionsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.progSymbolicHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.progSymbolicHelpLine2))
                            Text(t(ConfigEditKeys.progSymbolicHelpLine1))
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

// MARK: - Solar Return

struct SolarReturnEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let config: UserConfiguration

    @State private var orbDeg:   Int
    @State private var orbMin:   Int
    @State private var method:   SolarMethod
    @State private var location: SolarLocation
    @State private var isDirty = false
    @State private var showHelp = false

    init(config: UserConfiguration) {
        self.config = config
        let c = config.progressionsConfig.solarReturn
        let (deg, min) = sexagesimalFromDouble(c.orb)
        _orbDeg   = State(initialValue: deg)
        _orbMin   = State(initialValue: min)
        _method   = State(initialValue: c.method)
        _location = State(initialValue: c.location)
    }

    var body: some View {
        Form {
            Text(t(ConfigEditKeys.progNavSolar))
                .font(.title2).fontWeight(.semibold)
                .listRowBackground(Color.clear)
            Spacer().frame(height: 4).listRowBackground(Color.clear)
            Section(t(ConfigEditKeys.progSectionSettings)) {
                Picker(t(ConfigEditKeys.progSolarMethod), selection: $method) {
                    ForEach(SolarMethod.allCases, id: \.self) { m in
                        Text(le(m.rbKey)).tag(m)
                    }
                }
                Picker(t(ConfigEditKeys.progSolarLocation), selection: $location) {
                    ForEach(SolarLocation.allCases, id: \.self) { l in
                        Text(le(l.rbKey)).tag(l)
                    }
                }
                ProgOrbRow(deg: $orbDeg, min: $orbMin, isDirty: $isDirty)
            }
        }
        .navigationTitle(t(ConfigEditKeys.progNavSolar))
        .toolbar { saveToolbar }
        .sheet(isPresented: $showHelp) { SolarReturnHelpView() }
        .onChange(of: method)   { isDirty = true }
        .onChange(of: location) { isDirty = true }
    }

    private var saveToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(ConfigEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
                .help(t(ConfigEditKeys.progSolarHelpTooltip))
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
        let c = config.progressionsConfig.solarReturn
        (orbDeg, orbMin) = sexagesimalFromDouble(c.orb)
        method   = c.method
        location = c.location
    }

    private func save() {
        let pd = config.progressionsConfig
        config.progressionsConfig = ProgressionsConfig(
            primaryDirections:   pd.primaryDirections,
            transits:            pd.transits,
            secondaryDirections: pd.secondaryDirections,
            symbolicDirections:  pd.symbolicDirections,
            solarReturn: SolarReturnConfig(
                orb:      doubleFromSexagesimal(orbDeg, orbMin),
                method:   method,
                location: location
            )
        )
        try? modelContext.save()
        isDirty = false
    }
}

struct SolarReturnHelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(t(ConfigEditKeys.progSolarHelpGroupBox)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(t(ConfigEditKeys.progSolarHelpLine1))
                            Text(t(ConfigEditKeys.progSolarHelpLine2))
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

// MARK: - Sexagesimal helpers

private func sexagesimalFromDouble(_ value: Double) -> (Int, Int) {
    let totalMinutes = Int((value * 60.0).rounded())
    return (totalMinutes / 60, totalMinutes % 60)
}

private func doubleFromSexagesimal(_ deg: Int, _ min: Int) -> Double {
    Double(deg) + Double(min) / 60.0
}

// MARK: - Localization helpers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ConfigEdit", bundle: .main, comment: "")
}

/// Builds a section editor title: "<config label> <section name>", e.g. "Configuratie berekening".
private func sectionEditorTitle(_ section: ConfigSection) -> String {
    "\(t(ConfigEditKeys.editFallbackTitle)) \(section.localizedName.lowercased())"
}
