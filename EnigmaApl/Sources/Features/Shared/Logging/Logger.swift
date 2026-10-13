// Logger.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftyBeaver

/// Centralized logging configuration using SwiftyBeaver
public struct Logger {
    /// Shared SwiftyBeaver logger instance
    private static let swiftyBeaver = SwiftyBeaver.self
    
    /// Configure and initialize SwiftyBeaver logging
    /// Call this once at app startup
    public static func configure() {
        // Console destination for Xcode console — warning and above only to avoid performance issues
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        console.logPrintWay = .print
        console.minLevel = .warning
        
        // File destination for persistent logging — warnings and above only.
        // verbose/debug/info are for development; setting them to file causes quarantine
        // during research runs (42k+ log entries per run).
        let file = FileDestination()
        file.format = "$DHH:mm:ss.SSS$d $L $N.$F:$l - $M"
        file.minLevel = .warning
        // Rotate at 5 MB, keeping the current file and two older ones (EnigmaApl.1.log, EnigmaApl.2.log).
        file.logFileMaxSize = 5 * 1024 * 1024
        file.logFileAmount = 3

        // Set log file path to Documents directory
        if let logFileURL {
            file.logFileURL = logFileURL

            // Log the file location
            print("📝 Log file location: \(logFileURL.path)")
        }
        
        // Add destinations
        swiftyBeaver.addDestination(console)
        swiftyBeaver.addDestination(file)
        
        swiftyBeaver.info("Logger initialized")
    }
    
    /// URL of the log file, in the Documents directory of the app container.
    public static var logFileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("EnigmaApl.log")
    }

    /// Get the path to the log file
    public static var logFilePath: String? {
        logFileURL?.path
    }
    
    /// Logging interface that wraps SwiftyBeaver
    public struct log {
        public static func verbose(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
            swiftyBeaver.verbose(message(), file: file, function: function, line: line, context: context)
        }
        
        public static func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
            swiftyBeaver.debug(message(), file: file, function: function, line: line, context: context)
        }
        
        public static func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
            swiftyBeaver.info(message(), file: file, function: function, line: line, context: context)
        }
        
        public static func warning(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
            swiftyBeaver.warning(message(), file: file, function: function, line: line, context: context)
        }
        
        public static func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
            swiftyBeaver.error(message(), file: file, function: function, line: line, context: context)
        }
    }
}

