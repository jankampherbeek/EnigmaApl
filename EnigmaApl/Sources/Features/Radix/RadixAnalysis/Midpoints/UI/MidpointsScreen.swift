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
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(MidpointsKeys.title),
                    systemImage: "circle.dashed",
                    description: Text(t(MidpointsKeys.noChart))
                )
            } else {
                tabContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("", selection: $activeTab) {
                    Text(t(MidpointsKeys.btnAllMidpoints)).tag(MidpointsTab.all)
                    Text(t(MidpointsKeys.btnOccupiedMidpoints)).tag(MidpointsTab.occupied)
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
            if activeTab == .occupied {
                ToolbarItem(placement: .automatic) {
                    Picker("", selection: $dialType) {
                        Text(t(MidpointsKeys.dial360)).tag(MidpointDialType.dial360)
                        Text(t(MidpointsKeys.dial90)).tag(MidpointDialType.dial90)
                        Text(t(MidpointsKeys.dial45)).tag(MidpointDialType.dial45)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
            }
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
}

// MARK: - Supporting enums

private enum MidpointsTab {
    case all
    case occupied
}
