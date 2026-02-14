//
//  ConfigCoordinator.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Coordinator that encapsulates internal navigation logic for the Config feature.
final class ConfigCoordinator: FeatureCoordinating {
    private let viewModel = ConfigViewModel()

    let descriptor = FeatureDescriptor(id: "configuration", title: "Configuration")

    func start() -> FeatureSession {
        viewModel.close()
        return FeatureSession(
            actions: viewModel.actions,
            openAction: { [weak self] actionID, onClose in
                guard let self else { return .welcome }
                return self.viewModel.openAction(actionID, onClose: onClose)
            },
            close: { [weak self] in
                self?.viewModel.close()
            }
        )
    }
}

