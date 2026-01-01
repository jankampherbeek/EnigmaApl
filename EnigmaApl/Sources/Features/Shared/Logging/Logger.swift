//
//  Logger.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/12/2025.
//

import Foundation
import SwiftyBeaver

/// Centralized logging configuration using SwiftyBeaver
public struct Logger {
    /// Shared SwiftyBeaver logger instance
    private static let swiftyBeaver = SwiftyBeaver.self
    
    /// Configure and initialize SwiftyBeaver logging
    /// Call this once at app startup
    public static func configure() {
        // Console destination for Xcode console
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        console.logPrintWay = .print
        
        // File destination for persistent logging
        let file = FileDestination()
        file.format = "$DHH:mm:ss.SSS$d $L $N.$F:$l - $M"
        
        // Set log file path to Documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileURL = documentsPath.appendingPathComponent("EnigmaApl.log")
            file.logFileURL = logFileURL
            
            // Log the file location
            print("📝 Log file location: \(logFileURL.path)")
        }
        
        // Add destinations
        swiftyBeaver.addDestination(console)
        swiftyBeaver.addDestination(file)
        
        swiftyBeaver.info("Logger initialized")
    }
    
    /// Get the path to the log file
    public static var logFilePath: String? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsPath.appendingPathComponent("EnigmaApl.log").path
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

