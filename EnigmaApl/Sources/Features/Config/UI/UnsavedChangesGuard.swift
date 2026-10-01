// UnsavedChangesGuard.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

/// Keeps track of configuration screens with unsaved changes and holds back navigation that
/// would leave them until the user chooses to save, discard or stay.
/// Held by AppComposition, injected as EnvironmentObject. The alert is shown by RootView.
@MainActor
final class UnsavedChangesGuard: ObservableObject {

    private struct Entry {
        let save: () -> Void
        let discard: () -> Void
    }

    private var dirtyScreens: [UUID: Entry] = [:]
    /// Screens that are affected by the pending navigation.
    private var pendingScope: [UUID] = []

    /// Navigation waiting for the user's decision; the alert is shown while this is set.
    @Published private(set) var pendingAction: (() -> Void)?

    var hasUnsavedChanges: Bool { !dirtyScreens.isEmpty }

    /// Registers or clears the unsaved state of a screen.
    func update(_ id: UUID, isDirty: Bool, save: @escaping () -> Void, discard: @escaping () -> Void) {
        if isDirty {
            dirtyScreens[id] = Entry(save: save, discard: discard)
        } else {
            dirtyScreens[id] = nil
        }
    }

    func remove(_ id: UUID) {
        dirtyScreens[id] = nil
    }

    /// Runs `action` immediately when there are no unsaved changes; otherwise asks the user first.
    /// - Parameter screen: only consider this screen (e.g. when leaving just that screen);
    ///   nil considers all screens with unsaved changes.
    func perform(screen: UUID? = nil, _ action: @escaping () -> Void) {
        let scope = screen.map { dirtyScreens[$0] == nil ? [] : [$0] } ?? Array(dirtyScreens.keys)
        guard !scope.isEmpty else { action(); return }
        pendingScope = scope
        pendingAction = action
    }

    func saveAndContinue() {
        for id in pendingScope { dirtyScreens[id]?.save() }
        finish(continuing: true)
    }

    func discardAndContinue() {
        for id in pendingScope { dirtyScreens[id]?.discard() }
        finish(continuing: true)
    }

    func cancel() {
        finish(continuing: false)
    }

    private func finish(continuing: Bool) {
        let action = pendingAction
        for id in pendingScope { dirtyScreens[id] = nil }
        pendingScope = []
        pendingAction = nil
        if continuing { action?() }
    }
}

// MARK: - Screen registration

extension View {
    /// Registers the unsaved state of a configuration screen with the `UnsavedChangesGuard`.
    /// When `backTitle` is given, the standard back button is replaced by one that warns
    /// about unsaved changes before leaving the screen.
    func guardsUnsavedChanges(isDirty: Bool, save: @escaping () -> Void, discard: @escaping () -> Void,
                              backTitle: String? = nil) -> some View {
        modifier(UnsavedChangesModifier(isDirty: isDirty, save: save, discard: discard, backTitle: backTitle))
    }

    /// Shows the warning for unsaved configuration changes. Attach once, at the root view.
    func unsavedChangesAlert(_ unsavedChanges: UnsavedChangesGuard) -> some View {
        modifier(UnsavedChangesAlertModifier(unsavedChanges: unsavedChanges))
    }
}

/// Observes the guard, so the alert appears as soon as a navigation is held back.
private struct UnsavedChangesAlertModifier: ViewModifier {
    @ObservedObject var unsavedChanges: UnsavedChangesGuard

    func body(content: Content) -> some View {
        content
            .alert(t(ConfigEditKeys.unsavedTitle),
                   isPresented: Binding(
                    get: { unsavedChanges.pendingAction != nil },
                    set: { if !$0 && unsavedChanges.pendingAction != nil { unsavedChanges.cancel() } }
                   )) {
                Button(t(ConfigEditKeys.editSave)) { unsavedChanges.saveAndContinue() }
                Button(t(ConfigEditKeys.unsavedDiscard), role: .destructive) { unsavedChanges.discardAndContinue() }
                Button(t(ConfigEditKeys.cancel), role: .cancel) { unsavedChanges.cancel() }
            } message: {
                Text(t(ConfigEditKeys.unsavedMessage))
            }
    }
}

private struct UnsavedChangesModifier: ViewModifier {
    let isDirty: Bool
    let save: () -> Void
    let discard: () -> Void
    let backTitle: String?

    @EnvironmentObject private var unsavedChanges: UnsavedChangesGuard
    @Environment(\.dismiss) private var dismiss
    @State private var id = UUID()

    func body(content: Content) -> some View {
        content
            .onAppear { register() }
            .onChange(of: isDirty) { register() }
            .onDisappear { unsavedChanges.remove(id) }
            .navigationBarBackButtonHidden(backTitle != nil)
            .toolbar {
                if let backTitle {
                    ToolbarItem(placement: .navigation) {
                        Button(backTitle) { unsavedChanges.perform(screen: id) { dismiss() } }
                    }
                }
            }
    }

    private func register() {
        unsavedChanges.update(id, isDirty: isDirty, save: save, discard: discard)
    }
}

// MARK: - Localization helper

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ConfigEdit", bundle: .main, comment: "")
}
