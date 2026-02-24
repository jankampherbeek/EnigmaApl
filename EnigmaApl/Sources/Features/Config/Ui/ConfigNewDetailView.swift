//
//  ConfigNewDetailView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import SwiftUI

/// Right pane: live detail preview of the form input.
struct ConfigNewDetailView: View {
    @ObservedObject var view: ConfigNewModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Details")
                .font(.title2)
                .bold()

            GroupBox("Conclusion") {
                Text(view.compilation)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 4)
            }

            GroupBox("Remarks") {
                Text(view.remarks.isEmpty ? "(no remarks)" : view.remarks)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 4)
            }

            Spacer()

            Button("Close", action: onClose)
                .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

