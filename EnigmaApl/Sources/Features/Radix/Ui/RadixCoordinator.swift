//
//  RadixCoordinator.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Coordinator that encapsulates internal navigation logic for the Radix feature.
final class RadixCoordinator: FeatureCoordinating {
    private let viewModel = RadixViewModel()

    let descriptor = FeatureDescriptor(id: "radix", title: "Radix")

    func start() -> FeatureSession {
        viewModel.close()
        return FeatureSession(
            actions: viewModel.actions,
            openAction: { [weak self] actionID, onClose in
                self?.viewModel.openAction(actionID, onClose: onClose) ?? .welcome
            },
            close: { [weak self] in
                self?.viewModel.close()
            }
        )
    }
}

