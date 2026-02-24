//
//  ConfigCoordinator.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Coordinator that encapsulates internal navigation logic for the Config feature.
final class ConfigCoordinator: FeatureCoordinating {
    private let model = ConfigModel()

    let descriptor = FeatureDescriptor(id: "configuration", title: "Configuration")

    func start() -> FeatureSession {
        model.close()
        return FeatureSession(
            actions: model.actions,
            openAction: { [weak self] actionID, onClose in
                guard let self else { return .welcome }
                return self.model.openAction(actionID, onClose: onClose)
            },
            close: { [weak self] in
                self?.model.close()
            }
        )
    }
}

