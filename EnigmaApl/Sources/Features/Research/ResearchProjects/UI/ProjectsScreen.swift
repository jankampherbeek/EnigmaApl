// ProjectsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import AppKit
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ResearchProjects", bundle: .main, comment: "")
}

// MARK: - Subscreen routing

enum ResearchProjectSubscreen {
    case overview
    case newProject
    case configProject(ProjectDraft)
    case allProjects
    case searchProjects
    case openProject(ResearchProjectModel)
    case showResult(ResearchProjectModel, AnalysisResult)
}

/// Collects all data from the input screen to pass to the config screen.
struct ProjectDraft {
    let name: String
    let projectDescription: String
    let inquiry: Inquiries
    let cgMultiplication: Int
    let baseFolder: String
    /// The URL returned by NSOpenPanel; used to create a security-scoped bookmark.
    let selectedURL: URL?
}

// MARK: - Root switcher

struct ResearchProjectsScreen: View {
    @State private var activeSubscreen: ResearchProjectSubscreen = .overview

    var body: some View {
        switch activeSubscreen {
        case .overview:
            ResearchProjectsOverview(activeSubscreen: $activeSubscreen)
        case .newProject:
            ResearchProjectInputScreen(activeSubscreen: $activeSubscreen)
        case .configProject(let draft):
            ResearchProjectConfigScreen(activeSubscreen: $activeSubscreen, draft: draft)
        case .allProjects:
            ResearchProjectListScreen(activeSubscreen: $activeSubscreen, mode: .all)
        case .searchProjects:
            ResearchProjectListScreen(activeSubscreen: $activeSubscreen, mode: .search)
        case .openProject(let project):
            ResearchProjectDetailScreen(activeSubscreen: $activeSubscreen, project: project)
        case .showResult(let project, let result):
            ResearchResultScreen(activeSubscreen: $activeSubscreen, project: project, result: result)
        }
    }
}

// MARK: - Overview

struct ResearchProjectsOverview: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen

    var body: some View {
        VStack(spacing: 24) {
            Text(t(ResearchProjectsKeys.title))
                .font(.title)
            HStack(spacing: 16) {
                Button(t(ResearchProjectsKeys.buttonNew)) {
                    activeSubscreen = .newProject
                }
                Button(t(ResearchProjectsKeys.buttonSearch)) {
                    activeSubscreen = .searchProjects
                }
                Button(t(ResearchProjectsKeys.buttonAll)) {
                    activeSubscreen = .allProjects
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(t(ResearchProjectsKeys.title))
    }
}

// MARK: - Input screen (step 1)

struct ResearchProjectInputScreen: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var projectDescription: String = ""
    @State private var selectedInquiry: Inquiries = .factorsInSigns
    @State private var cgMultiplicationText: String = "1"
    @State private var selectedPath: String = ""
    @State private var selectedURL: URL? = nil
    @State private var errorMessage: String = ""

    private var nameIsEmpty: Bool { name.trimmingCharacters(in: .whitespaces).isEmpty }
    private var pathIsEmpty: Bool { selectedPath.isEmpty }
    private var canProceed: Bool { !nameIsEmpty && !pathIsEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(ResearchProjectsKeys.newTitle))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                FieldBlock(t(ResearchProjectsKeys.labelName)) {
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
                FieldBlock(t(ResearchProjectsKeys.labelDescription)) {
                    TextField("", text: $projectDescription)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
                FieldBlock(t(ResearchProjectsKeys.labelInquiry)) {
                    Picker("", selection: $selectedInquiry) {
                        ForEach(Inquiries.allCases, id: \.self) { inquiry in
                            Text(NSLocalizedString(inquiry.rbKey, bundle: .main, comment: ""))
                                .tag(inquiry)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                FieldBlock(t(ResearchProjectsKeys.labelCgMult)) {
                    TextField("", text: $cgMultiplicationText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 80)
                        .onChange(of: cgMultiplicationText) { _, newValue in
                            let filtered = newValue.filter(\.isNumber)
                            let capped = Int(filtered).map { min($0, 1000) }.map { String($0) } ?? filtered
                            if capped != newValue { cgMultiplicationText = capped }
                        }
                }
                FieldBlock(t(ResearchProjectsKeys.labelPath)) {
                    HStack {
                        Text(selectedPath.isEmpty ? "-" : selectedPath)
                            .foregroundStyle(selectedPath.isEmpty ? .secondary : .primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button(t(ResearchProjectsKeys.buttonSelectPath)) {
                            selectFolder()
                        }
                    }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                HStack {
                    Button(t(ResearchProjectsKeys.buttonCancel)) {
                        activeSubscreen = .overview
                    }
                    Spacer()
                    Button(t(ResearchProjectsKeys.buttonNext)) {
                        proceed()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(ResearchProjectsKeys.newTitle))
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = t(ResearchProjectsKeys.buttonSelectPath)
        if panel.runModal() == .OK, let url = panel.url {
            selectedURL = url
            selectedPath = url.path
        }
    }

    private func proceed() {
        guard !nameIsEmpty else { errorMessage = t(ResearchProjectsKeys.errorNameEmpty); return }
        guard !pathIsEmpty else { errorMessage = t(ResearchProjectsKeys.errorPathEmpty); return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let dao = ResearchProjectDao(context: modelContext)
        if let found = try? dao.fetch(byName: trimmedName), found != nil {
            errorMessage = t(ResearchProjectsKeys.errorDuplicateName)
            return
        }
        let draft = ProjectDraft(
            name: trimmedName,
            projectDescription: projectDescription,
            inquiry: selectedInquiry,
            cgMultiplication: max(1, Int(cgMultiplicationText) ?? 1),
            baseFolder: selectedPath,
            selectedURL: selectedURL
        )
        activeSubscreen = .configProject(draft)
    }
}

// MARK: - Config screen (step 2)

struct ResearchProjectConfigScreen: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    let draft: ProjectDraft

    // Factors
    @State private var selectedFactors: Set<Factors> = []

    // House system (only for .factorsInHouses inquiry)
    @State private var selectedHouseSystem: HouseSystems = .placidus

    // Aspects (only for .aspects inquiry)
    @State private var selectedAspects: Set<Aspects> = []
    @State private var overrideOrb: Bool = false
    @State private var orbText: String = ""

    // Unaspected orb (only for .unaspect inquiry)
    @State private var overrideUnaspectOrb: Bool = false
    @State private var unaspectOrbText: String = ""

    // Harmonic number (only for .harmonics inquiry)
    @State private var harmonicNumberText: String = "5"
    @State private var harmonicNumberError: String = ""

    // Dial type (only for .midpoints inquiry)
    @State private var useDial360: Bool = true
    @State private var useDial90: Bool = true
    @State private var useDial45: Bool = false

    // Midpoint orbs per dial (only for .midpoints inquiry)
    @State private var orbMidpoint360Text: String = "1.50"
    @State private var orbMidpoint90Text: String = "1.00"
    @State private var orbMidpoint45Text: String = "0.50"

    @State private var errorMessage: String = ""
    @State private var initialized = false

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(ResearchProjectsKeys.configTitle))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                inquirySpecificSections

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                HStack {
                    Button(t(ResearchProjectsKeys.buttonCancel)) {
                        activeSubscreen = .newProject
                    }
                    Spacer()
                    Button(t(ResearchProjectsKeys.buttonSave)) {
                        save()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedFactors.isEmpty)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(ResearchProjectsKeys.configTitle))
        .onAppear { initializeFromConfig() }
    }

    // MARK: - Inquiry-specific section order

    @ViewBuilder
    private var inquirySpecificSections: some View {
        switch draft.inquiry {
        case .factorsInHouses:
            houseSystemSection
            factorsSection
        case .aspects:
            aspectsOrbSection
            aspectsSection
            factorsSection
        case .unaspect:
            unaspectOrbSection
            factorsSection
        case .midpoints:
            dialTypeSection
            midpointOrbSection
            factorsSection
        case .harmonics:
            harmonicNumberSection
            if let orbConfig = activeConfig?.orbConfig { predefinedOrbSection(orbConfig: orbConfig) }
            factorsSection
        case .parallels:
            if let orbConfig = activeConfig?.orbConfig { predefinedOrbSection(orbConfig: orbConfig) }
            factorsSection
        case .declMidpoints:
            if let orbConfig = activeConfig?.orbConfig { predefinedOrbSection(orbConfig: orbConfig) }
            factorsSection
        default:
            factorsSection
        }
    }

    // MARK: - Section views

    @ViewBuilder
    private var factorsSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionFactors)) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Factors.allCases, id: \.self) { factor in
                    Toggle(NSLocalizedString(FactorKeys.key(for: factor), bundle: .main, comment: ""),
                           isOn: toggleBinding(for: factor))
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var houseSystemSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionHouseSystem)) {
            Picker("", selection: $selectedHouseSystem) {
                ForEach(HouseSystems.allCases, id: \.self) { system in
                    Text(NSLocalizedString(system.localizedName, bundle: .main, comment: ""))
                        .tag(system)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .padding(4)
        }
    }

    @ViewBuilder
    private var aspectsSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionAspects)) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Aspects.allCases, id: \.self) { aspect in
                    Toggle(NSLocalizedString(AspectKeys.key(for: aspect), bundle: .main, comment: ""),
                           isOn: aspectToggleBinding(for: aspect))
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var aspectsOrbSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionOrb)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(t(ResearchProjectsKeys.configOrbFromConfig))
                    .foregroundStyle(.secondary)
                Toggle(t(ResearchProjectsKeys.configOrbOverride), isOn: $overrideOrb)
                if overrideOrb {
                    FieldBlock(t(ResearchProjectsKeys.configOrbValue)) {
                        TextField("", text: $orbText)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                    }
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var unaspectOrbSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionOrb)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(t(ResearchProjectsKeys.configOrbFromConfig))
                    .foregroundStyle(.secondary)
                Toggle(t(ResearchProjectsKeys.configOrbOverride), isOn: $overrideUnaspectOrb)
                if overrideUnaspectOrb {
                    FieldBlock(t(ResearchProjectsKeys.configOrbValue)) {
                        TextField("", text: $unaspectOrbText)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                    }
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private func predefinedOrbSection(orbConfig: OrbConfig) -> some View {
        GroupBox(t(ResearchProjectsKeys.configSectionOrb)) {
            VStack(alignment: .leading, spacing: 4) {
                switch draft.inquiry {
                case .harmonics:
                    Text("\(String(format: "%.2f", orbConfig.harmonicOrb))°")
                case .midpoints:
                    Text(t(ResearchProjectsKeys.configDial360) + ": \(String(format: "%.2f", orbConfig.midpoint360DialOrb))°")
                    Text(t(ResearchProjectsKeys.configDial90)  + ": \(String(format: "%.2f", orbConfig.midpoint90DialOrb))°")
                    Text(t(ResearchProjectsKeys.configDial45)  + ": \(String(format: "%.2f", orbConfig.midpoint45DialOrb))°")
                case .declMidpoints:
                    Text("\(String(format: "%.2f", orbConfig.declinationMidpointOrb))°")
                case .parallels:
                    Text("\(String(format: "%.2f", orbConfig.parallelOrb))°")
                default:
                    EmptyView()
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var harmonicNumberSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionHarmonics)) {
            VStack(alignment: .leading, spacing: 8) {
                FieldBlock(t(ResearchProjectsKeys.configHarmonicNumber)) {
                    TextField("", text: $harmonicNumberText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 80)
                        .onChange(of: harmonicNumberText) { _, newValue in
                            let filtered = newValue.filter(\.isNumber)
                            if filtered != newValue { harmonicNumberText = filtered }
                        }
                }
                if !harmonicNumberError.isEmpty {
                    Text(harmonicNumberError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var dialTypeSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionDial)) {
            VStack(alignment: .leading, spacing: 4) {
                Toggle(t(ResearchProjectsKeys.configDial360), isOn: $useDial360)
                Toggle(t(ResearchProjectsKeys.configDial90), isOn: $useDial90)
                Toggle(t(ResearchProjectsKeys.configDial45), isOn: $useDial45)
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var midpointOrbSection: some View {
        GroupBox(t(ResearchProjectsKeys.configSectionOrb)) {
            VStack(alignment: .leading, spacing: 8) {
                if useDial360 {
                    FieldBlock(t(ResearchProjectsKeys.configDial360)) {
                        TextField("", text: $orbMidpoint360Text)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                    }
                }
                if useDial90 {
                    FieldBlock(t(ResearchProjectsKeys.configDial90)) {
                        TextField("", text: $orbMidpoint90Text)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                    }
                }
                if useDial45 {
                    FieldBlock(t(ResearchProjectsKeys.configDial45)) {
                        TextField("", text: $orbMidpoint45Text)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                    }
                }
            }
            .padding(4)
        }
    }

    // MARK: - Bindings

    private func toggleBinding(for factor: Factors) -> Binding<Bool> {
        Binding(
            get: { selectedFactors.contains(factor) },
            set: { if $0 { selectedFactors.insert(factor) } else { selectedFactors.remove(factor) } }
        )
    }

    private func aspectToggleBinding(for aspect: Aspects) -> Binding<Bool> {
        Binding(
            get: { selectedAspects.contains(aspect) },
            set: { if $0 { selectedAspects.insert(aspect) } else { selectedAspects.remove(aspect) } }
        )
    }

    // MARK: - Init from active config

    private func initializeFromConfig() {
        guard !initialized else { return }
        initialized = true
        if let config = activeConfig {
            selectedFactors = Set(config.factorConfig.factorSettings.filter(\.isUsed).map(\.factor))
            selectedHouseSystem = config.calculationConfig.houseSystem
            if draft.inquiry == .aspects {
                selectedAspects = Set(config.aspectConfig.aspectSettings.filter(\.isUsed).map(\.aspect))
                orbText = String(format: "%.2f", config.orbConfig.aspectBaseOrb)
            }
            if draft.inquiry == .unaspect {
                unaspectOrbText = String(format: "%.2f", config.orbConfig.aspectBaseOrb)
            }
            if draft.inquiry == .midpoints {
                orbMidpoint360Text = String(format: "%.2f", config.orbConfig.midpoint360DialOrb)
                orbMidpoint90Text  = String(format: "%.2f", config.orbConfig.midpoint90DialOrb)
                orbMidpoint45Text  = String(format: "%.2f", config.orbConfig.midpoint45DialOrb)
            }
        }
    }

    // MARK: - Save

    private func save() {
        guard !selectedFactors.isEmpty else { return }

        // Validate harmonic number when applicable
        var resolvedHarmonicNumber: Int? = nil
        if draft.inquiry == .harmonics {
            harmonicNumberError = ""
            let parsed = Int(harmonicNumberText.trimmingCharacters(in: .whitespaces)) ?? 0
            if parsed < 2 {
                harmonicNumberError = t(ResearchProjectsKeys.configHarmonicNumberError)
                return
            }
            resolvedHarmonicNumber = parsed
        }

        var calculationConfigJson = "{}"
        if let calcConfig = activeConfig?.calculationConfig,
           let data = try? JSONEncoder().encode(calcConfig),
           let json = String(data: data, encoding: .utf8) {
            calculationConfigJson = json
        }

        var orbConfigJson = "{}"
        if var orb = activeConfig?.orbConfig {
            if draft.inquiry == .midpoints {
                let parse = { (text: String, fallback: Double) -> Double in
                    Double(text.replacingOccurrences(of: ",", with: ".")) ?? fallback
                }
                orb = OrbConfig(
                    orbSystem: orb.orbSystem,
                    aspectBaseOrb: orb.aspectBaseOrb,
                    midpoint360DialOrb: parse(orbMidpoint360Text, orb.midpoint360DialOrb),
                    midpoint90DialOrb:  parse(orbMidpoint90Text,  orb.midpoint90DialOrb),
                    midpoint45DialOrb:  parse(orbMidpoint45Text,  orb.midpoint45DialOrb),
                    harmonicOrb: orb.harmonicOrb,
                    parallelOrb: orb.parallelOrb,
                    declinationMidpointOrb: orb.declinationMidpointOrb
                )
            }
            if let data = try? JSONEncoder().encode(orb),
               let json = String(data: data, encoding: .utf8) {
                orbConfigJson = json
            }
        }

        let aspectOrbOverride: Double? = (draft.inquiry == .aspects && overrideOrb)
            ? Double(orbText.replacingOccurrences(of: ",", with: "."))
            : nil
        let unaspectOrbOverride: Double? = (draft.inquiry == .unaspect && overrideUnaspectOrb)
            ? Double(unaspectOrbText.replacingOccurrences(of: ",", with: "."))
            : nil

        let enabledAspectIds: [Int]? = (draft.inquiry == .aspects)
            ? selectedAspects.map(\.rawValue).sorted()
            : nil

        var enabledDialSizes: [Int]? = nil
        if draft.inquiry == .midpoints {
            var sizes: [Int] = []
            if useDial360 { sizes.append(360) }
            if useDial90  { sizes.append(90) }
            if useDial45  { sizes.append(45) }
            enabledDialSizes = sizes
        }

        let config = ResearchConfig(
            enabledFactorIds: selectedFactors.map(\.rawValue).sorted(),
            inquiryId: draft.inquiry.rawValue,
            houseSystemId: selectedHouseSystem.rawValue,
            calculationConfigJson: calculationConfigJson,
            orbConfigJson: orbConfigJson,
            enabledAspectIds: enabledAspectIds,
            aspectOrbOverride: aspectOrbOverride,
            unaspectOrbOverride: unaspectOrbOverride,
            enabledDialSizes: enabledDialSizes,
            harmonicNumber: resolvedHarmonicNumber
        )

        let service = ResearchProjectService(context: modelContext,
                                             pipelineOrchestrator: ResearchPipelineOrchestrator())
        do {
            let project = try service.createProject(
                name: draft.name,
                description: draft.projectDescription,
                inquiry: draft.inquiry,
                config: config,
                cgMultiplication: draft.cgMultiplication,
                baseFolder: draft.baseFolder
            )
            // Create a security-scoped bookmark for the project folder so that the sandbox
            // grants access again in future sessions without requiring a new NSOpenPanel prompt.
            let projectFolderURL = URL(fileURLWithPath: project.path, isDirectory: true)
            if let bookmarkData = try? projectFolderURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            ) {
                project.bookmark = bookmarkData
                try? modelContext.save()
            }
            activeSubscreen = .openProject(project)
        } catch {
            errorMessage = t(ResearchProjectsKeys.errorSave)
        }
    }
}

// MARK: - List / Search screen

enum ResearchProjectListMode {
    case all
    case search
}

struct ResearchProjectListScreen: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen
    @Environment(\.modelContext) private var modelContext

    let mode: ResearchProjectListMode

    @State private var projects: [ResearchProjectModel] = []
    @State private var query: String = ""
    @State private var showSearchPopup: Bool = false
    @State private var projectToDelete: ResearchProjectModel? = nil
    @State private var showDeleteConfirmation: Bool = false
    @State private var showDeleteError: Bool = false
    @State private var hasSearched: Bool = false

    private let nameWidth: CGFloat = 200
    private let descWidth: CGFloat = 280
    private let dateWidth: CGFloat = 160
    private let buttonWidth: CGFloat = 90

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(mode == .all ? ResearchProjectsKeys.listTitle : ResearchProjectsKeys.searchTitle))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showDeleteError {
                    Text(t(ResearchProjectsKeys.deleteFailed))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if !projects.isEmpty {
                    projectTable(projects)
                } else if mode == .search && hasSearched {
                    Text(t(ResearchProjectsKeys.searchNoResults))
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button(t(ResearchProjectsKeys.buttonCancel)) {
                        activeSubscreen = .overview
                    }
                    if mode == .search {
                        Spacer()
                        Button(t(ResearchProjectsKeys.searchButton)) {
                            showSearchPopup = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(mode == .all ? ResearchProjectsKeys.listTitle : ResearchProjectsKeys.searchTitle))
        .sheet(isPresented: $showSearchPopup) {
            searchPopup
        }
        .alert(t(ResearchProjectsKeys.deleteTitle),
               isPresented: $showDeleteConfirmation,
               presenting: projectToDelete) { project in
            Button(t(ResearchProjectsKeys.deleteConfirm), role: .destructive) {
                confirmDelete(project)
            }
            Button(t(ResearchProjectsKeys.deleteCancel), role: .cancel) {}
        } message: { project in
            Text(String(format: t(ResearchProjectsKeys.deleteMessage), project.name))
        }
        .onAppear {
            if mode == .all { loadAll() }
        }
    }

    // MARK: - Search popup

    private var searchPopup: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                FieldBlock(t(ResearchProjectsKeys.searchLabel)) {
                    TextField("", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 200, maxWidth: 400)
                        .onSubmit { performSearch() }
                }
                Button(t(ResearchProjectsKeys.searchButton)) {
                    performSearch()
                    showSearchPopup = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                Spacer()
            }
            .padding()
            .navigationTitle(t(ResearchProjectsKeys.searchPopupTitle))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t(ResearchProjectsKeys.searchPopupClose)) {
                        showSearchPopup = false
                    }
                }
            }
        }
        .frame(minWidth: 360, minHeight: 180)
    }

    // MARK: - Table

    @ViewBuilder
    private func projectTable(_ items: [ResearchProjectModel]) -> some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        Text(t(ResearchProjectsKeys.columnName))
                            .frame(width: nameWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.columnDescription))
                            .frame(width: descWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.columnDate))
                            .frame(width: dateWidth, alignment: .leading)
                        Spacer().frame(width: buttonWidth)
                        Spacer().frame(width: buttonWidth)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(items.enumerated()), id: \.element.id) { index, project in
                        HStack(spacing: 12) {
                            Text(project.name)
                                .frame(width: nameWidth, alignment: .leading)
                                .lineLimit(1)
                            Text(project.projectDescription)
                                .frame(width: descWidth, alignment: .leading)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Text(Self.dateFormatter.string(from: project.creationDate))
                                .frame(width: dateWidth, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Button(t(ResearchProjectsKeys.buttonOpen)) {
                                openProject(project)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .frame(width: buttonWidth)
                            Button(t(ResearchProjectsKeys.buttonDelete)) {
                                projectToDelete = project
                                showDeleteConfirmation = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .frame(width: buttonWidth)
                            .tint(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func loadAll() {
        let dao = ResearchProjectDao(context: modelContext)
        projects = (try? dao.fetchAll()) ?? []
    }

    private func performSearch() {
        hasSearched = true
        let term = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !term.isEmpty else { projects = []; return }
        let dao = ResearchProjectDao(context: modelContext)
        let all = (try? dao.fetchAll()) ?? []
        projects = all.filter { $0.name.lowercased().contains(term) }
    }

    private func openProject(_ project: ResearchProjectModel) {
        activeSubscreen = .openProject(project)
    }

    private func confirmDelete(_ project: ResearchProjectModel) {
        showDeleteError = false

        // Resolve the security-scoped bookmark so the sandbox grants access
        // to the project folder for the FileManager removal that follows.
        var scopedURL: URL? = nil
        if let data = project.bookmark, !data.isEmpty {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: data,
                                  options: .withSecurityScope,
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &isStale) {
                if url.startAccessingSecurityScopedResource() {
                    scopedURL = url
                }
            }
        }

        defer { scopedURL?.stopAccessingSecurityScopedResource() }

        let service = ResearchProjectService(context: modelContext,
                                             pipelineOrchestrator: ResearchPipelineOrchestrator())
        do {
            try service.deleteProject(project)
            projects.removeAll { $0.id == project.id }
        } catch {
            showDeleteError = true
        }
    }
}

// MARK: - Detail / open project screen

struct ResearchProjectDetailScreen: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen
    @Environment(\.modelContext) private var modelContext

    let project: ResearchProjectModel

    @State private var selectedFilePath: String = ""
    @State private var selectedFileType: DataFileType = .standardEnigma
    @State private var fileReadState: FileReadState = .none
    @State private var runState: RunState = .idle
    @StateObject private var pipelineOrchestrator = ResearchPipelineOrchestrator()
    /// Tracks the security-scoped URL and whether access was successfully started,
    /// so it can be released after the inquiry (import + pipeline + analysis) completes.
    @State private var scopedURL: URL? = nil
    @State private var didStartScopedAccess = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    /// Extra LabeledContent rows derived from the stored ResearchConfig,
    /// shown directly below the inquiry-type row in the project info GroupBox.
    @ViewBuilder
    private var configInfoRows: some View {
        if let config = try? ResearchConfig.from(json: project.config),
           let inquiry = project.inquiryType {
            switch inquiry {
            case .factorsInHouses:
                LabeledContent(t(ResearchProjectsKeys.detailLabelHouseSystem)) {
                    Text(NSLocalizedString(config.houseSystem.localizedName, bundle: .main, comment: ""))
                }
            case .aspects:
                LabeledContent(t(ResearchProjectsKeys.detailLabelOrb)) {
                    if let orb = config.aspectOrbOverride {
                        Text(String(format: "%.2f°", orb))
                    } else {
                        Text(t(ResearchProjectsKeys.detailOrbFromConfig))
                            .foregroundStyle(.secondary)
                    }
                }
            case .unaspect:
                LabeledContent(t(ResearchProjectsKeys.detailLabelOrb)) {
                    if let orb = config.unaspectOrbOverride {
                        Text(String(format: "%.2f°", orb))
                    } else {
                        Text(t(ResearchProjectsKeys.detailOrbFromConfig))
                            .foregroundStyle(.secondary)
                    }
                }
            case .midpoints:
                if let orbConfig = config.orbConfig, let dials = config.enabledDialSizes {
                    LabeledContent(t(ResearchProjectsKeys.detailLabelDial)) {
                        Text(dials.map { "\($0)°" }.joined(separator: ", "))
                    }
                    LabeledContent(t(ResearchProjectsKeys.detailLabelOrb)) {
                        let parts: [String] = dials.compactMap { size -> String? in
                            switch size {
                            case 360: return "360°: \(String(format: "%.2f°", orbConfig.midpoint360DialOrb))"
                            case 90:  return "90°: \(String(format: "%.2f°", orbConfig.midpoint90DialOrb))"
                            case 45:  return "45°: \(String(format: "%.2f°", orbConfig.midpoint45DialOrb))"
                            default:  return nil
                            }
                        }
                        Text(parts.joined(separator: "  "))
                    }
                }
            case .harmonics:
                LabeledContent(t(ResearchProjectsKeys.detailLabelHarmonicNr)) {
                    Text("\(config.harmonicNumber ?? 5)")
                }
                if let orb = config.orbConfig?.harmonicOrb {
                    LabeledContent(t(ResearchProjectsKeys.detailLabelOrb)) {
                        Text(String(format: "%.2f°", orb))
                    }
                }
            case .parallels:
                if let orb = config.orbConfig?.parallelOrb {
                    LabeledContent(t(ResearchProjectsKeys.detailLabelOrb)) {
                        Text(String(format: "%.2f°", orb))
                    }
                }
            case .declMidpoints:
                if let orb = config.orbConfig?.declinationMidpointOrb {
                    LabeledContent(t(ResearchProjectsKeys.detailLabelOrb)) {
                        Text(String(format: "%.2f°", orb))
                    }
                }
            default:
                EmptyView()
            }
        }
    }

    private var canStartInquiry: Bool {
        if case .ok = fileReadState, case .idle = runState { return true }
        return false
    }

    private var resultIsShowing: Bool {
        if case .done = runState { return true }
        return false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(ResearchProjectsKeys.detailTitle))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Project info
                GroupBox {
                    VStack(alignment: .leading, spacing: 6) {
                        LabeledContent(t(ResearchProjectsKeys.detailLabelName)) {
                            Text(project.name)
                        }
                        LabeledContent(t(ResearchProjectsKeys.detailLabelDescription)) {
                            Text(project.projectDescription.isEmpty ? "-" : project.projectDescription)
                                .foregroundStyle(project.projectDescription.isEmpty ? .secondary : .primary)
                        }
                        LabeledContent(t(ResearchProjectsKeys.detailLabelInquiry)) {
                            Text(project.inquiryType.map {
                                NSLocalizedString($0.rbKey, bundle: .main, comment: "")
                            } ?? "-")
                        }
                        configInfoRows
                        LabeledContent(t(ResearchProjectsKeys.detailLabelCgMult)) {
                            Text("\(project.cgMultiplication)")
                        }
                        LabeledContent(t(ResearchProjectsKeys.detailLabelPath)) {
                            Text(project.path)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        LabeledContent(t(ResearchProjectsKeys.detailLabelCreated)) {
                            Text(Self.dateFormatter.string(from: project.creationDate))
                        }
                    }
                    .padding(4)
                }

                // MARK: Data file selection
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        FieldBlock(t(ResearchProjectsKeys.detailLabelFileType)) {
                            Picker("", selection: $selectedFileType) {
                                ForEach(DataFileType.allCases, id: \.self) { type in
                                    Text(NSLocalizedString(type.rbKey, bundle: .main, comment: ""))
                                        .tag(type)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }

                        FieldBlock(t(ResearchProjectsKeys.detailLabelDataFile)) {
                            HStack {
                                Text(selectedFilePath.isEmpty ? "-" : selectedFilePath)
                                    .foregroundStyle(selectedFilePath.isEmpty ? .secondary : .primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(t(ResearchProjectsKeys.detailButtonSelectFile)) {
                                    selectFile()
                                }
                                .disabled(runState != .idle)
                            }
                        }

                        fileStatusView
                    }
                    .padding(4)
                }

                // MARK: Progress / result
                runStateView

                HStack {
                    Button(t(ResearchProjectsKeys.buttonCancel)) {
                        pipelineOrchestrator.cancel()
                        activeSubscreen = .overview
                    }
                    Spacer()
                    if case .pipeline = runState {
                        Button(t(ResearchProjectsKeys.detailButtonInterrupt)) {
                            pipelineOrchestrator.cancel()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    } else if case .done = runState {
                        Button(t(ResearchProjectsKeys.detailButtonClose)) {
                            activeSubscreen = .overview
                        }
                        .buttonStyle(.borderedProminent)
                    } else if case .ok = fileReadState, case .idle = runState {
                        // Only show Start once a data file has been read successfully,
                        // so the user has a deliberate moment to review before committing.
                        Button(t(ResearchProjectsKeys.detailButtonStart)) {
                            startInquiry()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: resultIsShowing ? 1000 : 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(ResearchProjectsKeys.detailTitle))
        .onReceive(pipelineOrchestrator.$progress) { progress in
            handleProgressUpdate(progress)
        }
    }

    // MARK: - File status view

    @ViewBuilder
    private var fileStatusView: some View {
        switch fileReadState {
        case .none:
            EmptyView()
        case .ok(let count):
            Text(String(format: t(ResearchProjectsKeys.detailFileReadOk), count))
                .font(.caption)
                .foregroundStyle(.green)
        case .error(let message):
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    // MARK: - Run state view

    @ViewBuilder
    private var runStateView: some View {
        switch runState {
        case .idle:
            EmptyView()
        case .importing:
            HStack(spacing: 8) {
                ProgressView()
                Text(t(ResearchProjectsKeys.detailRunImporting))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .pipeline(let progress):
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: progress.fraction)
                Text(progressLabel(for: progress))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .analysing:
            HStack(spacing: 8) {
                ProgressView()
                Text(t(ResearchProjectsKeys.detailRunAnalysing))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .done(let result):
            VStack(alignment: .leading, spacing: 12) {
                Text(t(ResearchProjectsKeys.detailRunDone))
                    .font(.caption)
                    .foregroundStyle(.green)
                InlineResultView(result: result, cgMultiplication: project.cgMultiplication)
            }
        case .failed(let message):
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    private func progressLabel(for progress: PipelineProgress) -> String {
        switch progress.phase {
        case .readingInput:
            return t(ResearchProjectsKeys.detailRunReading)
        case .calculating:
            return String(format: t(ResearchProjectsKeys.detailRunCalculating),
                          progress.recordsDone, progress.totalRecords)
        case .writingResults:
            return t(ResearchProjectsKeys.detailRunWriting)
        default:
            return ""
        }
    }

    // MARK: - Actions

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.prompt = t(ResearchProjectsKeys.detailButtonSelectFile)
        if panel.runModal() == .OK, let url = panel.url {
            selectedFilePath = url.path
            fileReadState = .none
            readFile(at: url.path)
        }
    }

    private func readFile(at path: String) {
        let importer = importerForType(selectedFileType)
        do {
            let records = try importer.parse(source: path, isData: true, startId: 1)
            fileReadState = .ok(records.count)
        } catch let error as DataImportError {
            fileReadState = .error(localizedMessage(for: error))
        } catch {
            fileReadState = .error(t(ResearchProjectsKeys.detailFileError))
        }
    }

    private func importerForType(_ type: DataFileType) -> DataImporter {
        switch type {
        case .standardEnigma: return EnigmaFormatImporter()
        case .gauquelin:      return CsvDataImporter()   // placeholder until GauquelinImporter exists
        case .quickChart:     return CsvDataImporter()   // placeholder until QuickChartImporter exists
        }
    }

    private func localizedMessage(for error: DataImportError) -> String {
        switch error {
        case .parseError(let line, let text):
            return String(format: t(ResearchProjectsKeys.detailFileErrorLine), line, text)
        case .valueOutOfRange(let line, let field, let value):
            return String(format: t(ResearchProjectsKeys.detailFileErrorRange), line, field, value)
        case .noData:
            return t(ResearchProjectsKeys.detailFileErrorNoData)
        case .sourceUnreadable(let path):
            return String(format: t(ResearchProjectsKeys.detailFileErrorUnreadable), path)
        }
    }

    private func startInquiry() {
        // Resolve the security-scoped bookmark so the sandbox allows read/write access
        // to the project folder across sessions. Without this, all file operations in
        // the project folder fail after an app relaunch (sandboxed app limitation).
        if let data = project.bookmark, !data.isEmpty {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: data,
                                  options: .withSecurityScope,
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &isStale) {
                scopedURL = url
                didStartScopedAccess = url.startAccessingSecurityScopedResource()
            }
        }

        runState = .importing
        let filePath = selectedFilePath
        let importer = importerForType(selectedFileType)
        let projectPath = project.path
        let projectCgMult = project.cgMultiplication

        Task {
            // 1. Import data off the main actor (parse + SQLite inserts — can be slow)
            let importResult = await Task.detached(priority: .userInitiated) {
                Result {
                    let orchestrator = ImportOrchestrator()
                    return try orchestrator.runWith(sourceFile: filePath, importer: importer,
                                                   projectPath: projectPath,
                                                   cgMultiplication: projectCgMult)
                }
            }.value

            switch importResult {
            case .failure(let error):
                // Unwrap ImportOrchestratorError to show the underlying cause.
                let detail: String
                switch error as? ImportOrchestratorError {
                case .parseFailed(let inner):
                    detail = "Parse: \(inner.localizedDescription)"
                case .databaseFailed(let inner):
                    detail = "Database: \(inner.localizedDescription)"
                case .noRecordsAfterImport:
                    detail = "No records found in the file."
                case .none:
                    detail = error.localizedDescription
                }
                releaseScopedAccess()
                runState = .failed(t(ResearchProjectsKeys.detailRunImportFailed) + "\n" + detail)
                return
            case .success:
                break
            }

            // 2. Start calculation pipeline — async internally, progress via onReceive
            runState = .pipeline(pipelineOrchestrator.progress)
            let service = ResearchProjectService(context: modelContext,
                                                 pipelineOrchestrator: pipelineOrchestrator)
            do {
                try service.runPipeline(for: project)
            } catch {
                releaseScopedAccess()
                runState = .failed(t(ResearchProjectsKeys.detailRunPipelineFailed)
                                   + "\n" + error.localizedDescription)
            }
            // Pipeline completion and analysis are handled in handleProgressUpdate()
        }
    }

    /// Releases the security-scoped resource access started in `startInquiry()`.
    /// Safe to call multiple times — only acts when access was actually started.
    private func releaseScopedAccess() {
        if didStartScopedAccess {
            scopedURL?.stopAccessingSecurityScopedResource()
            didStartScopedAccess = false
            scopedURL = nil
        }
    }

    private func handleProgressUpdate(_ progress: PipelineProgress) {
        switch progress.phase {
        case .completed:
            runState = .analysing
            // Extract only Sendable values from the SwiftData model before crossing actor boundary
            let projectPath   = project.path
            let projectConfig = project.config
            let projectEnquiry = project.enquiry
            Task {
                do {
                    let result = try await Task.detached(priority: .userInitiated) {
                        // Reconstruct a lightweight proxy so AnalysisOrchestrator can be called
                        try AnalysisOrchestrator().runWith(path: projectPath,
                                                           configJson: projectConfig,
                                                           inquiryId: projectEnquiry)
                    }.value
                    await MainActor.run {
                        releaseScopedAccess()
                        runState = .done(result)
                    }
                } catch {
                    await MainActor.run {
                        releaseScopedAccess()
                        runState = .failed(t(ResearchProjectsKeys.detailRunAnalysisFailed)
                                           + "\n" + error.localizedDescription)
                    }
                }
            }
        case .failed(let error):
            releaseScopedAccess()
            if let pe = error as? PipelineError, case .cancelled = pe {
                runState = .idle
            } else {
                runState = .failed(t(ResearchProjectsKeys.detailRunPipelineFailed)
                                   + "\n" + error.localizedDescription)
            }
        case .calculating, .readingInput, .writingResults:
            runState = .pipeline(progress)
        default:
            break
        }
    }
}

// MARK: - File read state

private enum FileReadState {
    case none
    case ok(Int)
    case error(String)
}

// MARK: - Inline result view (shown on the detail screen immediately after analysis)

private struct InlineResultView: View {
    let result: AnalysisResult
    let cgMultiplication: Int

    @State private var proportional: Bool = false
    @State private var exportMessage: String = ""
    @State private var exportIsError: Bool = false

    private var divisor: Int { proportional ? cgMultiplication : 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            resultContent

            if !exportMessage.isEmpty {
                Text(exportMessage)
                    .font(.caption)
                    .foregroundStyle(exportIsError ? .red : .green)
            }

            HStack(spacing: 12) {
                if cgMultiplication > 1 {
                    Button(proportional
                           ? t(ResearchProjectsKeys.resultButtonValues)
                           : t(ResearchProjectsKeys.resultButtonProportional)) {
                        proportional.toggle()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                Button(t(ResearchProjectsKeys.resultButtonExport)) {
                    exportResult()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        switch result {
        case .factorsInSigns(let r):    FactorsInSignsResultView(result: r, divisor: divisor)
        case .factorsInHouses(let r):   FactorsInHousesResultView(result: r, divisor: divisor)
        case .aspects(let r):           AspectsResultView(result: r, divisor: divisor)
        case .unaspect(let r):          UnaspectResultView(result: r, divisor: divisor)
        case .midpoints(let r):         MidpointsResultView(result: r, divisor: divisor)
        case .harmonics(let r):         HarmonicsResultView(result: r, divisor: divisor)
        case .parallels(let r):         ParallelsResultView(result: r, divisor: divisor)
        case .declMidpoints(let r):     DeclMidpointsResultView(result: r, divisor: divisor)
        case .oob(let r):               OobResultView(result: r, divisor: divisor)
        }
    }

    private func exportResult() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "results.csv"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try ResultsExporter().export(result, to: url.path, divisor: divisor)
            exportMessage = t(ResearchProjectsKeys.resultExportOk)
            exportIsError = false
        } catch {
            exportMessage = t(ResearchProjectsKeys.resultExportFailed)
            exportIsError = true
        }
    }
}

// MARK: - Results screen

struct ResearchResultScreen: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen
    let project: ResearchProjectModel
    let result: AnalysisResult

    @State private var proportional: Bool = false
    @State private var exportMessage: String = ""
    @State private var exportIsError: Bool = false

    private var divisor: Int { proportional ? project.cgMultiplication : 1 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(ResearchProjectsKeys.resultTitle))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                resultContent

                if !exportMessage.isEmpty {
                    Text(exportMessage)
                        .font(.caption)
                        .foregroundStyle(exportIsError ? .red : .green)
                }

                HStack {
                    Button(t(ResearchProjectsKeys.resultButtonBack)) {
                        activeSubscreen = .openProject(project)
                    }
                    Spacer()
                    if project.cgMultiplication > 1 {
                        Button(proportional
                               ? t(ResearchProjectsKeys.resultButtonValues)
                               : t(ResearchProjectsKeys.resultButtonProportional)) {
                            proportional.toggle()
                        }
                        .buttonStyle(.bordered)
                    }
                    Button(t(ResearchProjectsKeys.resultButtonExport)) {
                        exportResult()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(ResearchProjectsKeys.resultTitle))
    }

    // MARK: - Dispatched result view

    @ViewBuilder
    private var resultContent: some View {
        switch result {
        case .factorsInSigns(let r):
            FactorsInSignsResultView(result: r, divisor: divisor)
        case .factorsInHouses(let r):
            FactorsInHousesResultView(result: r, divisor: divisor)
        case .aspects(let r):
            AspectsResultView(result: r, divisor: divisor)
        case .unaspect(let r):
            UnaspectResultView(result: r, divisor: divisor)
        case .midpoints(let r):
            MidpointsResultView(result: r, divisor: divisor)
        case .harmonics(let r):
            HarmonicsResultView(result: r, divisor: divisor)
        case .parallels(let r):
            ParallelsResultView(result: r, divisor: divisor)
        case .declMidpoints(let r):
            DeclMidpointsResultView(result: r, divisor: divisor)
        case .oob(let r):
            OobResultView(result: r, divisor: divisor)
        }
    }

    // MARK: - Export

    private func exportResult() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "\(project.name).csv"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try ResultsExporter().export(result, to: url.path, divisor: divisor)
            exportMessage = t(ResearchProjectsKeys.resultExportOk)
            exportIsError = false
        } catch {
            exportMessage = t(ResearchProjectsKeys.resultExportFailed)
            exportIsError = true
        }
    }
}

// MARK: - Factors in Signs result view

private struct FactorsInSignsResultView: View {
    let result: FactorsInSignsResult
    let divisor: Int

    private let factorWidth: CGFloat = 140
    private let countWidth: CGFloat  = 50
    private let totalWidth: CGFloat  = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            signsTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            signsTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func signsTable(title: String, isData: Bool) -> some View {
        // Per-sign totals across all factors
        let signTotals: [Int] = (0..<12).map { si in
            result.distributions.reduce(0) { sum, dist in
                sum + (isData ? dist.signCounts[si].dataCount : dist.signCounts[si].controlCount)
            }
        }
        let grandTotal = signTotals.reduce(0, +)

        GroupBox(title) {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(Signs.allCases, id: \.self) { sign in
                            Text("\(sign)").frame(width: countWidth, alignment: .trailing)
                        }
                        Text("∑").frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.distributions.enumerated()), id: \.offset) { idx, dist in
                        HStack(spacing: 4) {
                            Text("\(dist.factor)").frame(width: factorWidth, alignment: .leading)
                            ForEach(dist.signCounts, id: \.sign) { sc in
                                Text(isData ? "\(sc.dataCount)" : controlText(sc.controlCount, divisor: divisor))
                                    .frame(width: countWidth, alignment: .trailing)
                            }
                            Text(isData ? "\(dist.totalData)" : controlText(dist.totalControl, divisor: divisor))
                                .frame(width: totalWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                    Divider()
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultRowTotal))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(Array(signTotals.enumerated()), id: \.offset) { _, count in
                            Text(isData ? "\(count)" : controlText(count, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                        }
                        Text(isData ? "\(grandTotal)" : controlText(grandTotal, divisor: divisor))
                            .frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                }
            }
        }
    }
}

// MARK: - Factors in Houses result view

private struct FactorsInHousesResultView: View {
    let result: FactorsInHousesResult
    let divisor: Int

    private let factorWidth: CGFloat = 140
    private let countWidth: CGFloat  = 44
    private let totalWidth: CGFloat  = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            housesTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            housesTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func housesTable(title: String, isData: Bool) -> some View {
        // Per-house totals across all factors
        let houseTotals: [Int] = (0..<result.nrOfHouses).map { hi in
            result.distributions.reduce(0) { sum, dist in
                sum + (isData ? dist.houseCounts[hi].dataCount : dist.houseCounts[hi].controlCount)
            }
        }
        let grandTotal = houseTotals.reduce(0, +)

        GroupBox(title) {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(1...result.nrOfHouses, id: \.self) { h in
                            Text("\(h)").frame(width: countWidth, alignment: .trailing)
                        }
                        Text("∑").frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.distributions.enumerated()), id: \.offset) { idx, dist in
                        HStack(spacing: 4) {
                            Text("\(dist.factor)").frame(width: factorWidth, alignment: .leading)
                            ForEach(dist.houseCounts, id: \.houseNr) { hc in
                                Text(isData ? "\(hc.dataCount)" : controlText(hc.controlCount, divisor: divisor))
                                    .frame(width: countWidth, alignment: .trailing)
                            }
                            Text(isData ? "\(dist.totalData)" : controlText(dist.totalControl, divisor: divisor))
                                .frame(width: totalWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                    Divider()
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultRowTotal))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(Array(houseTotals.enumerated()), id: \.offset) { _, count in
                            Text(isData ? "\(count)" : controlText(count, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                        }
                        Text(isData ? "\(grandTotal)" : controlText(grandTotal, divisor: divisor))
                            .frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                }
            }
        }
    }
}

// MARK: - Aspects result view

private struct AspectsResultView: View {
    let result: AspectsResult
    let divisor: Int

    private let factorWidth: CGFloat = 120
    private let angleWidth: CGFloat  = 55
    private let totalWidth: CGFloat  = 70

    /// Aspect angles present in the result, sorted ascending.
    private var aspectAngles: [Double] {
        Array(Set(result.counts.map(\.aspectAngle))).sorted()
    }

    /// Unique (factor1, factor2) pairs in their original result order.
    private var factorPairs: [(Factors, Factors)] {
        var seen = Set<String>()
        var pairs: [(Factors, Factors)] = []
        for c in result.counts {
            let key = "\(c.factor1.rawValue)-\(c.factor2.rawValue)"
            if seen.insert(key).inserted { pairs.append((c.factor1, c.factor2)) }
        }
        return pairs
    }

    private func count(f1: Factors, f2: Factors, angle: Double, isData: Bool) -> Int {
        result.counts.first { $0.factor1 == f1 && $0.factor2 == f2 && $0.aspectAngle == angle }
            .map { isData ? $0.dataCount : $0.controlCount } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            aspectsMatrix(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            aspectsMatrix(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func aspectsMatrix(title: String, isData: Bool) -> some View {
        let angles = aspectAngles
        let pairs  = factorPairs
        let angleTotals: [Int] = angles.map { angle in
            result.counts.filter { $0.aspectAngle == angle }
                .reduce(0) { $0 + (isData ? $1.dataCount : $1.controlCount) }
        }
        let grandTotal = angleTotals.reduce(0, +)

        GroupBox(title) {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor1))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnFactor2))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(angles, id: \.self) { angle in
                            Text(String(format: "%.5g°", angle))
                                .frame(width: angleWidth, alignment: .trailing)
                        }
                        Text("∑").frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    // One row per factor pair
                    ForEach(Array(pairs.enumerated()), id: \.offset) { idx, pair in
                        let rowTotal = angles.reduce(0) {
                            $0 + count(f1: pair.0, f2: pair.1, angle: $1, isData: isData)
                        }
                        HStack(spacing: 4) {
                            Text("\(pair.0)").frame(width: factorWidth, alignment: .leading)
                            Text("\(pair.1)").frame(width: factorWidth, alignment: .leading)
                            ForEach(angles, id: \.self) { angle in
                                let c = count(f1: pair.0, f2: pair.1, angle: angle, isData: isData)
                                Text(isData ? "\(c)" : controlText(c, divisor: divisor))
                                    .frame(width: angleWidth, alignment: .trailing)
                            }
                            Text(isData ? "\(rowTotal)" : controlText(rowTotal, divisor: divisor))
                                .frame(width: totalWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                    Divider()
                    // Totals row
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultRowTotal))
                            .frame(width: factorWidth, alignment: .leading)
                        Spacer().frame(width: factorWidth)
                        ForEach(Array(angleTotals.enumerated()), id: \.offset) { _, total in
                            Text(isData ? "\(total)" : controlText(total, divisor: divisor))
                                .frame(width: angleWidth, alignment: .trailing)
                        }
                        Text(isData ? "\(grandTotal)" : controlText(grandTotal, divisor: divisor))
                            .frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                }
            }
        }
    }
}

// MARK: - Unaspect result view

private struct UnaspectResultView: View {
    let result: UnaspectResult
    let divisor: Int

    private let factorWidth: CGFloat = 160
    private let countWidth: CGFloat  = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            unaspectTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            unaspectTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func unaspectTable(title: String, isData: Bool) -> some View {
        GroupBox(title) {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text(t(ResearchProjectsKeys.resultColumnFactor))
                        .frame(width: factorWidth, alignment: .leading)
                    Text("∑").frame(width: countWidth, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8).padding(.vertical, 4)
                Divider()
                ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                    HStack(spacing: 4) {
                        Text("\(c.factor)").frame(width: factorWidth, alignment: .leading)
                        Text(isData ? "\(c.dataCount)" : controlText(c.controlCount, divisor: divisor))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
    }
}

// MARK: - Midpoints result view

private struct MidpointsResultView: View {
    let result: MidpointsResult
    let divisor: Int

    private let factorWidth: CGFloat = 110
    private let dialWidth: CGFloat   = 60
    private let countWidth: CGFloat  = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            midpointsTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            midpointsTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func midpointsTable(title: String, isData: Bool) -> some View {
        GroupBox(title) {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactorA))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnFactorB))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnOccupant))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnDial))
                            .frame(width: dialWidth, alignment: .trailing)
                        Text("∑").frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                        HStack(spacing: 4) {
                            Text("\(c.factorA)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.factorB)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.occupant)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.dialSize)").frame(width: dialWidth, alignment: .trailing)
                            Text(isData ? "\(c.dataCount)" : controlText(c.controlCount, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
    }
}

// MARK: - Harmonics result view

private struct HarmonicsResultView: View {
    let result: HarmonicsResult
    let divisor: Int

    private let factorWidth: CGFloat = 140
    private let countWidth: CGFloat  = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: t(ResearchProjectsKeys.resultHarmonicNumber), result.harmonicNumber))
                .font(.caption)
                .foregroundStyle(.secondary)
            harmonicsTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            harmonicsTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func harmonicsTable(title: String, isData: Bool) -> some View {
        GroupBox(title) {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text(t(ResearchProjectsKeys.resultColumnHarmonic))
                        .frame(width: factorWidth, alignment: .leading)
                    Text(t(ResearchProjectsKeys.resultColumnRadix))
                        .frame(width: factorWidth, alignment: .leading)
                    Text("∑").frame(width: countWidth, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8).padding(.vertical, 4)
                Divider()
                ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                    HStack(spacing: 4) {
                        Text("\(c.harmonicFactor)").frame(width: factorWidth, alignment: .leading)
                        Text("\(c.radixFactor)").frame(width: factorWidth, alignment: .leading)
                        Text(isData ? "\(c.dataCount)" : controlText(c.controlCount, divisor: divisor))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
    }
}

// MARK: - Parallels result view

private struct ParallelsResultView: View {
    let result: ParallelsResult
    let divisor: Int

    private let factorWidth: CGFloat = 120
    private let countWidth: CGFloat  = 90

    /// Unique (factor1, factor2) pairs in sorted order.
    private var factorPairs: [(Factors, Factors)] {
        var seen = Set<String>()
        var pairs: [(Factors, Factors)] = []
        for c in result.counts {
            let key = "\(c.factor1.rawValue)-\(c.factor2.rawValue)"
            if seen.insert(key).inserted { pairs.append((c.factor1, c.factor2)) }
        }
        return pairs.sorted {
            if $0.0.rawValue != $1.0.rawValue { return $0.0.rawValue < $1.0.rawValue }
            return $0.1.rawValue < $1.1.rawValue
        }
    }

    private func count(f1: Factors, f2: Factors, isContra: Bool, isData: Bool) -> Int {
        result.counts.first { $0.factor1 == f1 && $0.factor2 == f2 && $0.isContraParallel == isContra }
            .map { isData ? $0.dataCount : $0.controlCount } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            parallelsMatrix(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            parallelsMatrix(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func parallelsMatrix(title: String, isData: Bool) -> some View {
        let pairs = factorPairs
        let totalP = pairs.reduce(0) { $0 + count(f1: $1.0, f2: $1.1, isContra: false, isData: isData) }
        let totalC = pairs.reduce(0) { $0 + count(f1: $1.0, f2: $1.1, isContra: true,  isData: isData) }

        GroupBox(title) {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor1))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnFactor2))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultTypeParallel))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultTypeContra))
                            .frame(width: countWidth, alignment: .trailing)
                        Text("∑").frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    // One row per factor pair
                    ForEach(Array(pairs.enumerated()), id: \.offset) { idx, pair in
                        let p = count(f1: pair.0, f2: pair.1, isContra: false, isData: isData)
                        let c = count(f1: pair.0, f2: pair.1, isContra: true,  isData: isData)
                        HStack(spacing: 4) {
                            Text("\(pair.0)").frame(width: factorWidth, alignment: .leading)
                            Text("\(pair.1)").frame(width: factorWidth, alignment: .leading)
                            Text(isData ? "\(p)" : controlText(p, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                            Text(isData ? "\(c)" : controlText(c, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                            Text(isData ? "\(p + c)" : controlText(p + c, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                    Divider()
                    // Totals row
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultRowTotal))
                            .frame(width: factorWidth, alignment: .leading)
                        Spacer().frame(width: factorWidth)
                        Text(isData ? "\(totalP)" : controlText(totalP, divisor: divisor))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(isData ? "\(totalC)" : controlText(totalC, divisor: divisor))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(isData ? "\(totalP + totalC)" : controlText(totalP + totalC, divisor: divisor))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                }
            }
        }
    }
}

// MARK: - Declination midpoints result view

private struct DeclMidpointsResultView: View {
    let result: DeclMidpointsResult
    let divisor: Int

    private let factorWidth: CGFloat = 120
    private let countWidth: CGFloat  = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            declMidpointsTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            declMidpointsTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func declMidpointsTable(title: String, isData: Bool) -> some View {
        GroupBox(title) {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactorA))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnFactorB))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnOccupant))
                            .frame(width: factorWidth, alignment: .leading)
                        Text("∑").frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                        HStack(spacing: 4) {
                            Text("\(c.factorA)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.factorB)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.occupant)").frame(width: factorWidth, alignment: .leading)
                            Text(isData ? "\(c.dataCount)" : controlText(c.controlCount, divisor: divisor))
                                .frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
    }
}

// MARK: - OOB result view

private struct OobResultView: View {
    let result: OobResult
    let divisor: Int

    private let factorWidth: CGFloat = 160
    private let countWidth: CGFloat  = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: t(ResearchProjectsKeys.resultObliquity), result.obliquity))
                .font(.caption)
                .foregroundStyle(.secondary)
            oobTable(title: t(ResearchProjectsKeys.resultColumnData), isData: true)
            oobTable(title: t(ResearchProjectsKeys.resultColumnControl), isData: false)
            skippedView(result.skippedRecords)
        }
    }

    @ViewBuilder
    private func oobTable(title: String, isData: Bool) -> some View {
        GroupBox(title) {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text(t(ResearchProjectsKeys.resultColumnFactor))
                        .frame(width: factorWidth, alignment: .leading)
                    Text("∑").frame(width: countWidth, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8).padding(.vertical, 4)
                Divider()
                ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                    HStack(spacing: 4) {
                        Text("\(c.factor)").frame(width: factorWidth, alignment: .leading)
                        Text(isData ? "\(c.dataCount)" : controlText(c.controlCount, divisor: divisor))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
    }
}

// MARK: - Shared helpers

/// Formats a control-group count. When divisor > 1 the value is scaled down
/// to match the size of the data group, and shown with one decimal place.
private func controlText(_ count: Int, divisor: Int) -> String {
    divisor > 1 ? String(format: "%.1f", Double(count) / Double(divisor)) : "\(count)"
}

@ViewBuilder
private func skippedView(_ count: Int) -> some View {
    if count > 0 {
        Text(String(format: t(ResearchProjectsKeys.resultSkipped), count))
            .font(.caption)
            .foregroundStyle(.orange)
    }
}

// MARK: - Run state

private enum RunState: Equatable {
    case idle
    case importing
    case pipeline(PipelineProgress)
    case analysing
    case done(AnalysisResult)
    case failed(String)

    static func == (lhs: RunState, rhs: RunState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.importing, .importing), (.analysing, .analysing): return true
        case (.pipeline, .pipeline): return true
        case (.done, .done): return true
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}
