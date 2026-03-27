// MidpointsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct MidpointsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var activeTab: MidpointsTab = .all
    @State private var dialType: MidpointDialType = .dial360

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Midpoints", bundle: .main, comment: "")
    }

    /// Derives the initial dial from the drawing type stored in DisplayConfig.
    private var defaultDial: MidpointDialType {
        switch activeConfigs.first?.displayConfig.drawingType {
        case .dial90:  return .dial90
        case .dial45:  return .dial45
        default:       return .dial360
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(MidpointsKeys.title),
                    systemImage: "circle.dashed",
                    description: Text(t(MidpointsKeys.noChart))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            Divider()

            bottomBar
                .padding(.horizontal)
                .padding(.vertical, 10)
        }
        .onAppear { dialType = defaultDial }
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .all:
            AllMidpointsView()
        case .occupied:
            OccupiedMidpointsView(dialType: dialType)
        }
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        HStack(spacing: 12) {
            // Tab buttons
            tabButton(.all,      label: t(MidpointsKeys.btnAllMidpoints))
            tabButton(.occupied, label: t(MidpointsKeys.btnOccupiedMidpoints))

            Spacer()

            // Dial buttons — only relevant for occupied midpoints
            if activeTab == .occupied {
                dialButton(.dial360, label: t(MidpointsKeys.dial360))
                dialButton(.dial90,  label: t(MidpointsKeys.dial90))
                dialButton(.dial45,  label: t(MidpointsKeys.dial45))
            }
        }
    }

    // MARK: - Button helpers

    @ViewBuilder
    private func tabButton(_ tab: MidpointsTab, label: String) -> some View {
        Button(label) { activeTab = tab }
            .buttonStyle(.bordered)
            .tint(activeTab == tab ? .accentColor : nil)
    }

    @ViewBuilder
    private func dialButton(_ dial: MidpointDialType, label: String) -> some View {
        Button(label) { dialType = dial }
            .buttonStyle(.bordered)
            .tint(dialType == dial ? .accentColor : nil)
    }
}

// MARK: - Supporting enums

private enum MidpointsTab {
    case all
    case occupied
}
