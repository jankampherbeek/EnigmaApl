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
        if panel.runModal() == .OK {
            selectedPath = panel.url?.path ?? ""
        }
    }

    private func proceed() {
        guard !nameIsEmpty else { errorMessage = t(ResearchProjectsKeys.errorNameEmpty); return }
        guard !pathIsEmpty else { errorMessage = t(ResearchProjectsKeys.errorPathEmpty); return }
        let draft = ProjectDraft(
            name: name.trimmingCharacters(in: .whitespaces),
            projectDescription: projectDescription,
            inquiry: selectedInquiry,
            cgMultiplication: max(1, Int(cgMultiplicationText) ?? 1),
            baseFolder: selectedPath
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

    // Harmonic number (only for .harmonics inquiry)
    @State private var harmonicNumberText: String = "5"
    @State private var harmonicNumberError: String = ""

    // Dial type (only for .midpoints inquiry)
    @State private var useDial360: Bool = true
    @State private var useDial90: Bool = true
    @State private var useDial45: Bool = false

    @State private var errorMessage: String = ""
    @State private var initialized = false

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(ResearchProjectsKeys.configTitle))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Factors
                GroupBox(t(ResearchProjectsKeys.configSectionFactors)) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Factors.allCases, id: \.self) { factor in
                            Toggle(NSLocalizedString(FactorKeys.key(for: factor), bundle: .main, comment: ""),
                                   isOn: toggleBinding(for: factor))
                        }
                    }
                    .padding(4)
                }

                // MARK: House system (only for .factorsInHouses)
                if draft.inquiry == .factorsInHouses {
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

                // MARK: Aspects section (only for .aspects)
                if draft.inquiry == .aspects {
                    GroupBox(t(ResearchProjectsKeys.configSectionAspects)) {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Aspects.allCases, id: \.self) { aspect in
                                Toggle(NSLocalizedString(AspectKeys.key(for: aspect), bundle: .main, comment: ""),
                                       isOn: aspectToggleBinding(for: aspect))
                            }
                        }
                        .padding(4)
                    }

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

                // MARK: Orb display for inquiry types that have a predefined orb
                let inquiriesWithOrb: Set<Inquiries> = [.harmonics, .midpoints, .declMidpoints, .parallels]
                if inquiriesWithOrb.contains(draft.inquiry), let orbConfig = activeConfig?.orbConfig {
                    GroupBox(t(ResearchProjectsKeys.configSectionOrb)) {
                        VStack(alignment: .leading, spacing: 4) {
                            orbRow(for: draft.inquiry, orbConfig: orbConfig)
                        }
                        .padding(4)
                    }
                }

                // MARK: Harmonic number (only for .harmonics)
                if draft.inquiry == .harmonics {
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

                // MARK: Dial type (only for .midpoints)
                if draft.inquiry == .midpoints {
                    GroupBox(t(ResearchProjectsKeys.configSectionDial)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle(t(ResearchProjectsKeys.configDial360), isOn: $useDial360)
                            Toggle(t(ResearchProjectsKeys.configDial90), isOn: $useDial90)
                            Toggle(t(ResearchProjectsKeys.configDial45), isOn: $useDial45)
                        }
                        .padding(4)
                    }
                }

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

    // MARK: - Orb info row per inquiry type

    @ViewBuilder
    private func orbRow(for inquiry: Inquiries, orbConfig: OrbConfig) -> some View {
        switch inquiry {
        case .harmonics:
            Text("\(String(format: "%.2f", orbConfig.harmonicOrb))°")
        case .midpoints:
            VStack(alignment: .leading, spacing: 2) {
                Text(t(ResearchProjectsKeys.configDial360) + ": \(String(format: "%.2f", orbConfig.midpoint360DialOrb))°")
                Text(t(ResearchProjectsKeys.configDial90)  + ": \(String(format: "%.2f", orbConfig.midpoint90DialOrb))°")
                Text(t(ResearchProjectsKeys.configDial45)  + ": \(String(format: "%.2f", orbConfig.midpoint45DialOrb))°")
            }
        case .declMidpoints:
            Text("\(String(format: "%.2f", orbConfig.declinationMidpointOrb))°")
        case .parallels:
            Text("\(String(format: "%.2f", orbConfig.parallelOrb))°")
        default:
            EmptyView()
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
        if let orb = activeConfig?.orbConfig,
           let data = try? JSONEncoder().encode(orb),
           let json = String(data: data, encoding: .utf8) {
            orbConfigJson = json
        }

        let aspectOrbOverride: Double? = (draft.inquiry == .aspects && overrideOrb)
            ? Double(orbText.replacingOccurrences(of: ",", with: "."))
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
    @State private var pipelineOrchestrator = ResearchPipelineOrchestrator()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private var canStartInquiry: Bool {
        if case .ok = fileReadState, case .idle = runState { return true }
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
                    Button(t(ResearchProjectsKeys.detailButtonStart)) {
                        startInquiry()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canStartInquiry)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(ResearchProjectsKeys.detailTitle))
        .onChange(of: pipelineOrchestrator.progress) { _, progress in
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
            VStack(alignment: .leading, spacing: 4) {
                Text(t(ResearchProjectsKeys.detailRunDone))
                    .font(.caption)
                    .foregroundStyle(.green)
                Button(t(ResearchProjectsKeys.detailButtonShowResults)) {
                    activeSubscreen = .showResult(project, result)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
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
        runState = .importing
        let filePath = selectedFilePath
        let importer = importerForType(selectedFileType)
        let service = ResearchProjectService(context: modelContext,
                                             pipelineOrchestrator: pipelineOrchestrator)
        Task {
            // 1. Import data file + generate control group
            do {
                try await Task.detached(priority: .userInitiated) {
                    try service.importData(from: filePath, using: importer, into: project)
                }.value
            } catch {
                await MainActor.run {
                    runState = .failed(t(ResearchProjectsKeys.detailRunImportFailed)
                                       + "\n" + error.localizedDescription)
                }
                return
            }

            // 2. Run calculation pipeline (progress updates arrive via onChange)
            await MainActor.run {
                runState = .pipeline(pipelineOrchestrator.progress)
                do {
                    try service.runPipeline(for: project)
                } catch {
                    runState = .failed(t(ResearchProjectsKeys.detailRunPipelineFailed)
                                       + "\n" + error.localizedDescription)
                }
            }
            // Pipeline completion is handled in handleProgressUpdate()
        }
    }

    private func handleProgressUpdate(_ progress: PipelineProgress) {
        switch progress.phase {
        case .completed:
            runState = .analysing
            let service = ResearchProjectService(context: modelContext,
                                                 pipelineOrchestrator: pipelineOrchestrator)
            Task {
                do {
                    let result = try await Task.detached(priority: .userInitiated) {
                        try service.runAnalysis(for: project)
                    }.value
                    await MainActor.run { runState = .done(result) }
                } catch {
                    await MainActor.run {
                        runState = .failed(t(ResearchProjectsKeys.detailRunAnalysisFailed)
                                           + "\n" + error.localizedDescription)
                    }
                }
            }
        case .failed(let error):
            runState = .failed(t(ResearchProjectsKeys.detailRunPipelineFailed)
                               + "\n" + error.localizedDescription)
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

// MARK: - Results screen

struct ResearchResultScreen: View {
    @Binding var activeSubscreen: ResearchProjectSubscreen
    let project: ResearchProjectModel
    let result: AnalysisResult

    @State private var exportMessage: String = ""
    @State private var exportIsError: Bool = false

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
            FactorsInSignsResultView(result: r)
        case .factorsInHouses(let r):
            FactorsInHousesResultView(result: r)
        case .aspects(let r):
            AspectsResultView(result: r)
        case .unaspect(let r):
            UnaspectResultView(result: r)
        case .midpoints(let r):
            MidpointsResultView(result: r)
        case .harmonics(let r):
            HarmonicsResultView(result: r)
        case .parallels(let r):
            ParallelsResultView(result: r)
        case .declMidpoints(let r):
            DeclMidpointsResultView(result: r)
        case .oob(let r):
            OobResultView(result: r)
        }
    }

    // MARK: - Export

    private func exportResult() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "\(project.name).csv"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try ResultsExporter().export(result, to: url.path)
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

    private let factorWidth: CGFloat  = 140
    private let countWidth: CGFloat   = 50
    private let totalWidth: CGFloat   = 70

    var body: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(Signs.allCases, id: \.self) { sign in
                            Text("\(sign)").frame(width: countWidth, alignment: .trailing)
                        }
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: totalWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.distributions.enumerated()), id: \.offset) { idx, dist in
                        VStack(spacing: 0) {
                            // Data row
                            HStack(spacing: 4) {
                                Text("\(dist.factor)").frame(width: factorWidth, alignment: .leading)
                                ForEach(dist.signCounts, id: \.sign) { sc in
                                    Text("\(sc.dataCount)").frame(width: countWidth, alignment: .trailing)
                                }
                                Text("\(dist.totalData)").frame(width: totalWidth, alignment: .trailing)
                                Text("\(dist.totalControl)").frame(width: totalWidth, alignment: .trailing)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.04))
                            // Control row
                            HStack(spacing: 4) {
                                Text("\(dist.factor) ©").frame(width: factorWidth, alignment: .leading)
                                ForEach(dist.signCounts, id: \.sign) { sc in
                                    Text("\(sc.controlCount)").frame(width: countWidth, alignment: .trailing)
                                }
                                Text("\(dist.totalData)").frame(width: totalWidth, alignment: .trailing)
                                Text("\(dist.totalControl)").frame(width: totalWidth, alignment: .trailing)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .foregroundStyle(.secondary)
                            .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.04))
                        }
                    }
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - Factors in Houses result view

private struct FactorsInHousesResultView: View {
    let result: FactorsInHousesResult

    private let factorWidth: CGFloat = 140
    private let countWidth: CGFloat  = 44
    private let totalWidth: CGFloat  = 70

    var body: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor))
                            .frame(width: factorWidth, alignment: .leading)
                        ForEach(1...result.nrOfHouses, id: \.self) { h in
                            Text("\(h)").frame(width: countWidth, alignment: .trailing)
                        }
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: totalWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: totalWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.distributions.enumerated()), id: \.offset) { idx, dist in
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                Text("\(dist.factor)").frame(width: factorWidth, alignment: .leading)
                                ForEach(dist.houseCounts, id: \.houseNr) { hc in
                                    Text("\(hc.dataCount)").frame(width: countWidth, alignment: .trailing)
                                }
                                Text("\(dist.totalData)").frame(width: totalWidth, alignment: .trailing)
                                Text("\(dist.totalControl)").frame(width: totalWidth, alignment: .trailing)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.04))
                            HStack(spacing: 4) {
                                Text("\(dist.factor) ©").frame(width: factorWidth, alignment: .leading)
                                ForEach(dist.houseCounts, id: \.houseNr) { hc in
                                    Text("\(hc.controlCount)").frame(width: countWidth, alignment: .trailing)
                                }
                                Text("\(dist.totalData)").frame(width: totalWidth, alignment: .trailing)
                                Text("\(dist.totalControl)").frame(width: totalWidth, alignment: .trailing)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .foregroundStyle(.secondary)
                            .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.04))
                        }
                    }
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - Aspects result view

private struct AspectsResultView: View {
    let result: AspectsResult

    private let factorWidth: CGFloat = 120
    private let angleWidth: CGFloat  = 80
    private let countWidth: CGFloat  = 70

    var body: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor1))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnFactor2))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnAspect))
                            .frame(width: angleWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                        HStack(spacing: 4) {
                            Text("\(c.factor1)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.factor2)").frame(width: factorWidth, alignment: .leading)
                            Text(String(format: "%.5g", c.aspectAngle))
                                .frame(width: angleWidth, alignment: .trailing)
                            Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                            Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - Unaspect result view

private struct UnaspectResultView: View {
    let result: UnaspectResult

    private let factorWidth: CGFloat = 160
    private let countWidth: CGFloat  = 80

    var body: some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text(t(ResearchProjectsKeys.resultColumnFactor))
                        .frame(width: factorWidth, alignment: .leading)
                    Text(t(ResearchProjectsKeys.resultColumnData))
                        .frame(width: countWidth, alignment: .trailing)
                    Text(t(ResearchProjectsKeys.resultColumnControl))
                        .frame(width: countWidth, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8).padding(.vertical, 4)
                Divider()
                ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                    HStack(spacing: 4) {
                        Text("\(c.factor)").frame(width: factorWidth, alignment: .leading)
                        Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                        Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - Midpoints result view

private struct MidpointsResultView: View {
    let result: MidpointsResult

    private let factorWidth: CGFloat = 110
    private let dialWidth: CGFloat   = 60
    private let countWidth: CGFloat  = 70

    var body: some View {
        GroupBox {
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
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: countWidth, alignment: .trailing)
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
                            Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                            Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - Harmonics result view

private struct HarmonicsResultView: View {
    let result: HarmonicsResult

    private let factorWidth: CGFloat = 140
    private let countWidth: CGFloat  = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: t(ResearchProjectsKeys.resultHarmonicNumber), result.harmonicNumber))
                .font(.caption)
                .foregroundStyle(.secondary)
            GroupBox {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnHarmonic))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnRadix))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                        HStack(spacing: 4) {
                            Text("\(c.harmonicFactor)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.radixFactor)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                            Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
            skippedView(result.skippedRecords)
        }
    }
}

// MARK: - Parallels result view

private struct ParallelsResultView: View {
    let result: ParallelsResult

    private let factorWidth: CGFloat = 120
    private let typeWidth: CGFloat   = 140
    private let countWidth: CGFloat  = 70

    var body: some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text(t(ResearchProjectsKeys.resultColumnFactor1))
                        .frame(width: factorWidth, alignment: .leading)
                    Text(t(ResearchProjectsKeys.resultColumnFactor2))
                        .frame(width: factorWidth, alignment: .leading)
                    Text(t(ResearchProjectsKeys.resultColumnType))
                        .frame(width: typeWidth, alignment: .leading)
                    Text(t(ResearchProjectsKeys.resultColumnData))
                        .frame(width: countWidth, alignment: .trailing)
                    Text(t(ResearchProjectsKeys.resultColumnControl))
                        .frame(width: countWidth, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8).padding(.vertical, 4)
                Divider()
                ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                    HStack(spacing: 4) {
                        Text("\(c.factor1)").frame(width: factorWidth, alignment: .leading)
                        Text("\(c.factor2)").frame(width: factorWidth, alignment: .leading)
                        Text(c.isContraParallel
                             ? t(ResearchProjectsKeys.resultTypeContra)
                             : t(ResearchProjectsKeys.resultTypeParallel))
                            .frame(width: typeWidth, alignment: .leading)
                        Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                        Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - Declination midpoints result view

private struct DeclMidpointsResultView: View {
    let result: DeclMidpointsResult

    private let factorWidth: CGFloat = 120
    private let countWidth: CGFloat  = 70

    var body: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactorA))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnFactorB))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnOccupant))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: countWidth, alignment: .trailing)
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
                            Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                            Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
        skippedView(result.skippedRecords)
    }
}

// MARK: - OOB result view

private struct OobResultView: View {
    let result: OobResult

    private let factorWidth: CGFloat = 160
    private let countWidth: CGFloat  = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: t(ResearchProjectsKeys.resultObliquity), result.obliquity))
                .font(.caption)
                .foregroundStyle(.secondary)
            GroupBox {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(ResearchProjectsKeys.resultColumnFactor))
                            .frame(width: factorWidth, alignment: .leading)
                        Text(t(ResearchProjectsKeys.resultColumnData))
                            .frame(width: countWidth, alignment: .trailing)
                        Text(t(ResearchProjectsKeys.resultColumnControl))
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    Divider()
                    ForEach(Array(result.counts.enumerated()), id: \.offset) { idx, c in
                        HStack(spacing: 4) {
                            Text("\(c.factor)").frame(width: factorWidth, alignment: .leading)
                            Text("\(c.dataCount)").frame(width: countWidth, alignment: .trailing)
                            Text("\(c.controlCount)").frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(idx.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
            skippedView(result.skippedRecords)
        }
    }
}

// MARK: - Shared helper

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
