// ProjectsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import AppKit
import SwiftUI
import SwiftData

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
}

/// Collects all data from the input screen to pass to the config screen.
struct ProjectDraft {
    let name: String
    let projectDescription: String
    let inquiry: Inquiries
    let cgMultiplication: Int
    let useEcliptical: Bool
    let useEquatorial: Bool
    let useHorizontal: Bool
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
    @State private var useEcliptical: Bool = true
    @State private var useEquatorial: Bool = false
    @State private var useHorizontal: Bool = false
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

                VStack(alignment: .leading, spacing: 6) {
                    Toggle(t(ResearchProjectsKeys.labelEcliptical), isOn: $useEcliptical)
                    Toggle(t(ResearchProjectsKeys.labelEquatorial), isOn: $useEquatorial)
                    Toggle(t(ResearchProjectsKeys.labelHorizontal), isOn: $useHorizontal)
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
            useEcliptical: useEcliptical,
            useEquatorial: useEquatorial,
            useHorizontal: useHorizontal,
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

    // Aspects (only for .aspects inquiry)
    @State private var selectedAspects: Set<Aspects> = []
    @State private var overrideOrb: Bool = false
    @State private var orbText: String = ""

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
            if draft.inquiry == .aspects {
                selectedAspects = Set(config.aspectConfig.aspectSettings.filter(\.isUsed).map(\.aspect))
                orbText = String(format: "%.2f", config.orbConfig.aspectBaseOrb)
            }
        }
    }

    // MARK: - Save

    private func save() {
        guard !selectedFactors.isEmpty else { return }

        var calculationConfigJson = "{}"
        if let calcConfig = activeConfig?.calculationConfig,
           let data = try? JSONEncoder().encode(calcConfig),
           let json = String(data: data, encoding: .utf8) {
            calculationConfigJson = json
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
            useEcliptical: draft.useEcliptical,
            useEquatorial: draft.useEquatorial,
            useHorizontal: draft.useHorizontal,
            calculationConfigJson: calculationConfigJson,
            enabledAspectIds: enabledAspectIds,
            aspectOrbOverride: aspectOrbOverride,
            enabledDialSizes: enabledDialSizes
        )

        let service = ResearchProjectService(context: modelContext,
                                             pipelineOrchestrator: ResearchPipelineOrchestrator())
        do {
            try service.createProject(
                name: draft.name,
                description: draft.projectDescription,
                inquiry: draft.inquiry,
                config: config,
                cgMultiplication: draft.cgMultiplication,
                baseFolder: draft.baseFolder
            )
            activeSubscreen = .overview
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
        // placeholder – to be implemented when project detail screen exists
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
