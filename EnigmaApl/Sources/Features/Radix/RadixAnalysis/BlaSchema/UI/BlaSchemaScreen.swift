// BlaSchemaScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// The 6 sub-screens the BLA schema is split into (the Windows version is one ~900-line
/// window; this splits it so it fits an iPhone/iPad screen).
enum BlaSchemaSection: CaseIterable, Identifiable {
    case configPositions, counts, dispositors, detailsCycles, reinforcements, receptions
    var id: Self { self }

    var titleKey: String {
        switch self {
        case .configPositions: return BlaSchemaKeys.sectionConfigPositions
        case .counts: return BlaSchemaKeys.sectionCounts
        case .dispositors: return BlaSchemaKeys.sectionDispositors
        case .detailsCycles: return BlaSchemaKeys.sectionDetailsCycles
        case .reinforcements: return BlaSchemaKeys.sectionReinforcements
        case .receptions: return BlaSchemaKeys.sectionReceptions
        }
    }
}

struct BlaSchemaScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @StateObject private var model = BlaSchemaModel()
    @State private var selectedSection: BlaSchemaSection = .configPositions
    @State private var showHelp = false

    private static let compactWidthThreshold: CGFloat = 700

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    private struct RecalcTrigger: Equatable {
        let chartId: UUID?
        let chartVersion: UUID?
        let houseSystem: HouseSystems
        let useChiron: Bool
        let useCeres: Bool
        let useDecanates: Bool
        let blackMoonCorrectionType: BlackMoonCorrectionType
    }

    private var trigger: RecalcTrigger {
        RecalcTrigger(
            chartId: chartSession.selected?.id, chartVersion: chartSession.selected?.version,
            houseSystem: model.houseSystem, useChiron: model.useChiron, useCeres: model.useCeres,
            useDecanates: model.useDecanates, blackMoonCorrectionType: model.blackMoonCorrectionType
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < Self.compactWidthThreshold
            Group {
                if chartSession.selected != nil, model.hasChart {
                    if isCompact {
                        VStack(spacing: 0) {
                            headerTitle
                            sectionPicker
                            ScrollView(.vertical) {
                                sectionContent
                                    .padding()
                            }
                        }
                    } else {
                        VStack(spacing: 0) {
                            headerTitle
                                .padding(.top)
                            sectionPicker
                                .padding(.top)
                            ScrollView(.vertical) {
                                sectionContent
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .padding()
                            }
                        }
                    }
                } else {
                    Text(t(BlaSchemaKeys.noChart))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showHelp = true } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("Help")
                }
            }
            .sheet(isPresented: $showHelp) {
                NavigationStack {
                    ScrollView {
                        Text(t(BlaSchemaKeys.help))
                            .padding()
                    }
                    .navigationTitle(t(BlaSchemaKeys.title))
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("OK") { showHelp = false }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .task(id: trigger) {
            guard let named = chartSession.selected else {
                model.clear()
                return
            }
            model.recalculate(baseRequest: named.baseRequest, chartName: named.name)
        }
    }

    private var headerTitle: some View {
        Text(String(format: t(BlaSchemaKeys.headerTitleFormat), model.chartName))
            .font(.headline)
            .padding(.horizontal)
    }

    private var sectionPicker: some View {
        Picker("", selection: $selectedSection) {
            ForEach(BlaSchemaSection.allCases) { section in
                Text(t(section.titleKey)).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch selectedSection {
        case .configPositions:
            BlaConfigPositionsView(model: model)
        case .counts:
            BlaCountsView(model: model)
        case .dispositors:
            BlaDispositorsView(model: model)
        case .detailsCycles:
            BlaDetailsCyclesView(model: model)
        case .reinforcements:
            BlaReinforcementsView(model: model)
        case .receptions:
            BlaReceptionsView(model: model)
        }
    }
}
