//
//  AppBootstrap.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Central place to wire app-level dependencies.
enum AppBootstrap {
    static func makeShellModel() -> AppShellModel {
        let appCoordinator = AppCoordinator(
            featureCoordinators: [
                ConfigCoordinator(),
                RadixCoordinator(),
//                ProgressiefCoordinator()
            ]
        )

        return AppShellModel(appCoordinator: appCoordinator)
    }
}

extension AppShellModel {
    static var preview: AppShellModel {
        AppBootstrap.makeShellModel()
    }
}

