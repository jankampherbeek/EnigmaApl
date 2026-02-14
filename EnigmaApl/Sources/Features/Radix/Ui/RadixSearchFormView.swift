//
//  RadixSearchFormView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import SwiftUI

/// Left pane for search/filter input.
struct RadixSearchFormView: View {
    @ObservedObject var viewModel: RadixSearchViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Searchterm")
                    .font(.headline)

                TextField("E.g. Alpha", text: $viewModel.searchterm)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.searchterm) { _, _ in
                        viewModel.selectFirstIfNeeded()
                    }
            }

            Toggle("Only score >= 75", isOn: $viewModel.onlyHighScore)
                .onChange(of: viewModel.onlyHighScore) { _, _ in
                    viewModel.selectFirstIfNeeded()
                }

            Text("Number of results: \(viewModel.results.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)

                Button("Close", action: onClose)
                    .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

