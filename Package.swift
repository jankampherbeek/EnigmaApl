//  Package.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 16/12/2025.
//

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EnigmaApl",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "EnigmaApl",
            targets: ["YourSwiftTarget"]),
    ],
    targets: [
        .target(
            name: "YourSwiftTarget",
            dependencies: ["CSwissEphemeris"]),

        .target(
            name: "CSwissEphemeris",
            path: "CSwissEphemeris",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ],
            linkerSettings: [
                .linkedLibrary("swe_device", .when(platforms: [.iOS], configuration: .release)),
                .linkedLibrary("swe_simulator", .when(platforms: [.iOS], configuration: .debug)),
                .linkedLibrary("swe_mac", .when(platforms: [.macOS]))
            ]
        )
    ]
)
