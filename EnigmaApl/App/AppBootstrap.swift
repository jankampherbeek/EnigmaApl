//
//  AppBootstrap.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//
import Foundation

/// Central place to wire app-level dependencies.
enum AppBootstrap {
    static func makeShellViewModel() -> AppShellViewModel {
        let appCoordinator = AppCoordinator(
            featureCoordinators: [
                ConfigCoordinator(),
                RadixCoordinator(),
//                ProgressiefCoordinator()
            ]
        )

        return AppShellViewModel(appCoordinator: appCoordinator)
    }
}

extension AppShellViewModel {
    static var preview: AppShellViewModel {
        AppBootstrap.makeShellViewModel()
    }
}

