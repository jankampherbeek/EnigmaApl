// SEWrapperTestCoordinator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
@testable import EnigmaApl

/// Coordinator for managing a single SEWrapper instance across all tests
/// This ensures thread-safety by preventing multiple simultaneous accesses
/// to the Swiss Ephemeris C library, which is not thread-safe.
///
/// **IMPORTANT**: Tests using this coordinator must run sequentially, not in parallel.
/// The Swiss Ephemeris C library is single-threaded and cannot handle concurrent access.
/// 
/// To run tests sequentially in Xcode:
/// - Edit Scheme → Test → Options → Check "Execute in random order" (unchecked) 
/// - Or use: xcodebuild test -parallel-testing-enabled NO
///
/// **Usage**:
/// ```swift
/// let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
/// let calc = LotsCalc(seWrapper: seWrapper)
/// ```
public final class SEWrapperTestCoordinator {
    
    /// Shared singleton instance
    public static let shared = SEWrapperTestCoordinator()
    
    /// The single SEWrapper instance shared across all tests
    private var _seWrapper: SEWrapper?
    
    /// Lock to ensure thread-safe access
    private let lock = NSLock()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Get or create the SEWrapper instance
    /// This method is thread-safe and ensures only one instance exists
    public func getSEWrapper() -> SEWrapper {
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = _seWrapper {
            return existing
        }
        
        let newWrapper = SEWrapper()
        _seWrapper = newWrapper
        return newWrapper
    }
    
    /// Reset the coordinator (useful for test teardown or between test runs)
    /// This will cause the SEWrapper to be deallocated, which will close the SE library
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        _seWrapper = nil
    }
    
    /// Ensure the wrapper is initialized
    public func ensureInitialized() {
        _ = getSEWrapper()
    }
}
