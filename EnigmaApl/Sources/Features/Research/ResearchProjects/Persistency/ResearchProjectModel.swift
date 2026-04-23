// ResearchProjectModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Persistent model for a research project.
@Model
final class ResearchProjectModel {
    var id: Int
    var name: String
    var projectDescription: String
    /// Raw value of the Inquiries enum.
    var enquiry: Int
    /// JSON-encoded configuration string.
    var config: String
    var cgMultiplication: Int
    var path: String
    var creationDate: Date

    init(
        id: Int,
        name: String,
        projectDescription: String,
        enquiry: Inquiries,
        config: String,
        cgMultiplication: Int,
        path: String,
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.projectDescription = projectDescription
        self.enquiry = enquiry.rawValue
        self.config = config
        self.cgMultiplication = cgMultiplication
        self.path = path
        self.creationDate = creationDate
    }

    /// Convenience accessor that returns the enquiry as an Inquiries enum value.
    var inquiryType: Inquiries? {
        Inquiries(rawValue: enquiry)
    }
}
