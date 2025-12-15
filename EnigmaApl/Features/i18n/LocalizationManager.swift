//
//  LocalizationManager.swift
//  internationalization
//
//  Created by Jan Kampherbeek on 12/07/2025.
//

import Foundation

enum SupportedLanguage: String, CaseIterable {
    case english = "en"
    case dutch = "nl"
    case french = "fr"
    case german = "de"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .dutch: return "Nederlands"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
}

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private var currentLanguage: SupportedLanguage = .english
    private var translations: [SupportedLanguage: [String: String]] = [:]
    
    private init() {
        setupTranslations()
        setupLocalization()
    }
    
    private func setupTranslations() {
        // English translations (base)
        translations[.english] = [
            "hello": "Hello",
            "goodbye": "Goodbye",
            "welcome": "Welcome",
            "save": "Save",
            "cancel": "Cancel",
            "delete": "Delete",
            "edit": "Edit",
            "loading": "Loading...",
            "error": "Error",
            "success": "Success",
            "please_wait": "Please wait...",
            "today": "Today",
            "yesterday": "Yesterday",
            "tomorrow": "Tomorrow"
        ]
        
        // Dutch translations
        translations[.dutch] = [
            "hello": "Hallo",
            "goodbye": "Tot ziens",
            "welcome": "Welkom",
            "save": "Opslaan",
            "cancel": "Annuleren",
            "delete": "Verwijderen",
            "edit": "Bewerken",
            "loading": "Laden...",
            "error": "Fout",
            "success": "Succes",
            "please_wait": "Even geduld...",
            "today": "Vandaag",
            "yesterday": "Gisteren",
            "tomorrow": "Morgen"
        ]
        
        // French translations
        translations[.french] = [
            "hello": "Bonjour",
            "goodbye": "Au revoir",
            "welcome": "Bienvenue",
            "save": "Enregistrer",
            "cancel": "Annuler",
            "delete": "Supprimer",
            "edit": "Modifier",
            "loading": "Chargement...",
            "error": "Erreur",
            "success": "Succès",
            "please_wait": "Veuillez patienter...",
            "today": "Aujourd'hui",
            "yesterday": "Hier",
            "tomorrow": "Demain"
        ]
        
        // German translations
        translations[.german] = [
            "hello": "Hallo",
            "goodbye": "Auf Wiedersehen",
            "welcome": "Willkommen",
            "save": "Speichern",
            "cancel": "Abbrechen",
            "delete": "Löschen",
            "edit": "Bearbeiten",
            "loading": "Laden...",
            "error": "Fehler",
            "success": "Erfolg",
            "please_wait": "Bitte warten...",
            "today": "Heute",
            "yesterday": "Gestern",
            "tomorrow": "Morgen"
        ]
    }
    
    private func setupLocalization() {
        // Try to get the user's preferred language
        let preferredLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Check if we support the preferred language
        if let supportedLanguage = SupportedLanguage.allCases.first(where: { $0.rawValue == preferredLanguage }) {
            setLanguage(supportedLanguage)
        } else {
            // Default to English
            setLanguage(.english)
        }
    }
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
    }
    
    func localizedString(for key: String) -> String {
        return translations[currentLanguage]?[key] ?? translations[.english]?[key] ?? key
    }
    
    func localizedString(for key: String, arguments: [CVarArg]) -> String {
        let format = localizedString(for: key)
        return String(format: format, arguments: arguments)
    }
    
    var currentLanguageCode: String {
        return currentLanguage.rawValue
    }
    
    var currentLanguageDisplayName: String {
        return currentLanguage.displayName
    }
    
    var availableLanguages: [SupportedLanguage] {
        return SupportedLanguage.allCases
    }
}

// MARK: - Convenience Extensions
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return LocalizationManager.shared.localizedString(for: self, arguments: arguments)
    }
} 
