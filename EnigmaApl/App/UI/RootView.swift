//
//  RootView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine


struct RootView: View {
    @EnvironmentObject private var composition: AppComposition
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var preferTwoColumns: Bool { hSizeClass == .compact }

    var body: some View {
        let app = composition.app

        NavigationSplitView {
            SidebarView()
        } content: {
            ContentColumn()
        } detail: {
            if preferTwoColumns {
                TwoColumnDetailPlaceholder()
            } else {
                DetailColumn()
            }
        }
        // Inject the actual singletons
        .environmentObject(app)
        .environmentObject(composition.radixNav)
        .environmentObject(composition.researchNav)
        .environmentObject(composition.cyclesNav)
        .onAppear { app.ensureDefaultSelection() }
        .sheet(isPresented: Binding(
            get: { preferTwoColumns && app.ui.showInspectorSheet },
            set: { app.ui.showInspectorSheet = $0 }
        )) {
            NavigationStack {
                DetailColumn()
                    .navigationTitle("Details")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Sluiten") { app.ui.showInspectorSheet = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
