//
//  ContentColumn.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine


struct ContentColumn: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var preferTwoColumns: Bool { hSizeClass == .compact }

    var body: some View {
        Text("Content (\(app.nav.mode.rawValue))")
            .navigationTitle(app.nav.mode.rawValue)
            .toolbar {
                if preferTwoColumns {
                    ToolbarItem(placement: .automatic) {
                        Button { app.ui.showInspectorSheet = true } label: {
                            Label("Details", systemImage: "sidebar.right")
                        }
                    }
                }
            }
    }
}

