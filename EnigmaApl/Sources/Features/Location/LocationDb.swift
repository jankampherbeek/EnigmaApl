// LocationDb.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SQLite3

/// Low-level access to enigma.db.  All methods are synchronous and intentionally free of business logic.
final class LocationDb {

    private let db: OpaquePointer

    /// Opens the bundled enigma.db.  Throws if the file is missing or cannot be opened.
    init() throws {
        guard let url = Bundle.main.url(forResource: "enigma", withExtension: "db") else {
            throw LocationDbError.databaseNotFound
        }
        var handle: OpaquePointer?
        guard sqlite3_open_v2(url.path, &handle, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let handle else {
            throw LocationDbError.cannotOpen(url.path)
        }
        db = handle
    }

    deinit { sqlite3_close(db) }

    // MARK: - Country

    /// Returns all countries sorted by localised name for the given language code.
    /// Falls back to English if the requested language has no entries.
    func allCountries(lang: String) throws -> [LocationCountry] {
        let sql = """
            SELECT cn.country_code, cn.name, c.continent
            FROM CountryName cn
            JOIN Country c ON cn.country_code = c.country_code
            WHERE cn.lang = ?
            ORDER BY cn.name COLLATE NOCASE
            """
        let results = try query(sql, params: [lang]) { stmt in
            LocationCountry(code: string(stmt, 0), name: string(stmt, 1), continent: string(stmt, 2))
        }
        if !results.isEmpty || lang == "en" { return results }
        return try allCountries(lang: "en")
    }

    /// Returns countries whose localised name matches the given pattern, for the given language.
    func countries(lang: String, pattern: String) throws -> [LocationCountry] {
        let likePattern = sqlLikePattern(from: pattern.lowercased())
        let sql = """
            SELECT cn.country_code, cn.name, c.continent
            FROM CountryName cn
            JOIN Country c ON cn.country_code = c.country_code
            WHERE cn.lang = ?
              AND lower(cn.name) LIKE ? ESCAPE '\\'
            ORDER BY cn.name COLLATE NOCASE
            LIMIT 50
            """
        return try query(sql, params: [lang, likePattern]) { stmt in
            LocationCountry(code: string(stmt, 0), name: string(stmt, 1), continent: string(stmt, 2))
        }
    }

    // MARK: - City

    /// Returns cities for one country.  The `pattern` supports `*` as a wildcard (any number of characters).
    /// An empty / `*`-only pattern returns all cities for that country.
    func cities(countryCode: String, pattern: String = "*") throws -> [LocationCity] {
        let likePattern = sqlLikePattern(from: pattern.lowercased())
        let sql = """
            SELECT c.id, c.country_code, c.name, c.latitude, c.longitude,
                   c.region_code, c.elevation, c.timezone_id, t.name
            FROM City c
            JOIN Timezone t ON c.timezone_id = t.id
            WHERE c.country_code = ?
              AND lower(c.name) LIKE ? ESCAPE '\\'
            ORDER BY c.name COLLATE NOCASE
            LIMIT 50
            """
        return try query(sql, params: [countryCode, likePattern]) { stmt in
            LocationCity(
                id:           Int(sqlite3_column_int(stmt, 0)),
                countryCode:  string(stmt, 1),
                name:         string(stmt, 2),
                latitude:     sqlite3_column_double(stmt, 3),
                longitude:    sqlite3_column_double(stmt, 4),
                regionCode:   optionalString(stmt, 5),
                elevation:    optionalInt(stmt, 6),
                timezoneId:   Int(sqlite3_column_int(stmt, 7)),
                timezoneName: string(stmt, 8)
            )
        }
    }

    // MARK: - TzData

    /// Returns all TzData rows for the given IANA zone name, in insertion order.
    func tzDataRows(zoneName: String) throws -> [TzDataRow] {
        let sql = """
            SELECT t.name, td.offset_h, td.offset_m, td.offset_s,
                   td.rule, td.format, td.until_year, td.until_month, td.until_day,
                   td.at_h, td.at_m, td.at_s
            FROM TzData td
            JOIN Timezone t ON td.id_zone = t.id
            WHERE t.name = ?
            ORDER BY td.id
            """
        return try query(sql, params: [zoneName]) { stmt in
            TzDataRow(
                zoneName:    string(stmt, 0),
                offsetH:     Int(sqlite3_column_int(stmt, 1)),
                offsetM:     Int(sqlite3_column_int(stmt, 2)),
                offsetS:     Int(sqlite3_column_int(stmt, 3)),
                rule:        string(stmt, 4),
                format:      string(stmt, 5),
                untilYear:   Int(sqlite3_column_int(stmt, 6)),
                untilMonth:  Int(sqlite3_column_int(stmt, 7)),
                untilDay:    string(stmt, 8),
                atH:         Int(sqlite3_column_int(stmt, 9)),
                atM:         Int(sqlite3_column_int(stmt, 10)),
                atS:         Int(sqlite3_column_int(stmt, 11))
            )
        }
    }

    // MARK: - DstData

    /// Returns all DstData rows for the given rule name, in insertion order.
    func dstDataRows(ruleName: String) throws -> [DstDataRow] {
        let sql = """
            SELECT rule_name, from_year, to_year, month, day,
                   at_h, at_m, at_s, use_ut, save_h, save_m, save_s, letter
            FROM DstData
            WHERE rule_name = ?
            ORDER BY id
            """
        return try query(sql, params: [ruleName]) { stmt in
            DstDataRow(
                ruleName: string(stmt, 0),
                fromYear: Int(sqlite3_column_int(stmt, 1)),
                toYear:   string(stmt, 2),
                month:    Int(sqlite3_column_int(stmt, 3)),
                day:      string(stmt, 4),
                atH:      Int(sqlite3_column_int(stmt, 5)),
                atM:      Int(sqlite3_column_int(stmt, 6)),
                atS:      Int(sqlite3_column_int(stmt, 7)),
                useUt:    string(stmt, 8),
                saveH:    Int(sqlite3_column_int(stmt, 9)),
                saveM:    Int(sqlite3_column_int(stmt, 10)),
                saveS:    Int(sqlite3_column_int(stmt, 11)),
                letter:   string(stmt, 12)
            )
        }
    }

    // MARK: - Helpers

    private func query<T>(_ sql: String, params: [Any], map: (OpaquePointer) -> T) throws -> [T] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK, let stmt else {
            throw LocationDbError.prepareFailed(sql)
        }
        defer { sqlite3_finalize(stmt) }

        for (i, param) in params.enumerated() {
            let col = Int32(i + 1)
            switch param {
            case let s as String:
                sqlite3_bind_text(stmt, col, (s as NSString).utf8String, -1, nil)
            case let n as Int:
                sqlite3_bind_int64(stmt, col, Int64(n))
            default:
                break
            }
        }

        var results: [T] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(map(stmt))
        }
        return results
    }

    private func string(_ stmt: OpaquePointer, _ col: Int32) -> String {
        guard let ptr = sqlite3_column_text(stmt, col) else { return "" }
        return String(cString: ptr)
    }

    private func optionalString(_ stmt: OpaquePointer, _ col: Int32) -> String? {
        guard sqlite3_column_type(stmt, col) != SQLITE_NULL,
              let ptr = sqlite3_column_text(stmt, col) else { return nil }
        return String(cString: ptr)
    }

    private func optionalInt(_ stmt: OpaquePointer, _ col: Int32) -> Int? {
        guard sqlite3_column_type(stmt, col) != SQLITE_NULL else { return nil }
        return Int(sqlite3_column_int(stmt, col))
    }

    /// Converts a user-facing wildcard pattern (only `*`) to a SQL LIKE pattern.
    /// Existing `%` and `_` are escaped so they are treated as literals.
    private func sqlLikePattern(from pattern: String) -> String {
        var result = pattern
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
            .replacingOccurrences(of: "*", with: "%")
        // Bare "*" or empty → match everything
        if result.isEmpty || result == "%" {
            return "%"
        }
        // If the user didn't supply a leading wildcard, append % for prefix search
        if !result.hasPrefix("%") {
            result += "%"
        }
        return result
    }
}

// MARK: - Errors

enum LocationDbError: LocalizedError {
    case databaseNotFound
    case cannotOpen(String)
    case prepareFailed(String)

    var errorDescription: String? {
        switch self {
        case .databaseNotFound:      return "enigma.db not found in app bundle."
        case .cannotOpen(let path):  return "Cannot open database at \(path)."
        case .prepareFailed(let sql): return "Failed to prepare SQL: \(sql)"
        }
    }
}
