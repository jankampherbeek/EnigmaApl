//
//  RootView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

// App container, builds a NavigationSplitView with 3 column:
// SidebarView (left navigation), ContentColumn (middle) and DetailColumn (right)

import SwiftUI
import Combine


struct RootView: View {
    @EnvironmentObject private var composition: AppComposition
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var preferTwoColumns: Bool { hSizeClass == .compact }

    var body: some View {
        let app = composition.app

        // Main layout
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
        // Inject the actual singletons so that they can be used by lower views
        .environmentObject(app)
        .environmentObject(composition.radixNav)
        .environmentObject(composition.researchNav)
        .environmentObject(composition.cyclesNav)
        .onAppear {
            DispatchQueue.main.async {
                app.ensureDefaultSelection()
            }
        }
        // when using compact layouts
        .sheet(isPresented: Binding(
            get: { preferTwoColumns && app.ui.showInspectorSheet },
            set: { app.setInspectorSheet($0) }
        )) {
            NavigationStack {
                DetailColumn()
                    .navigationTitle("Details")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Sluiten") { app.setInspectorSheet(false) }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
