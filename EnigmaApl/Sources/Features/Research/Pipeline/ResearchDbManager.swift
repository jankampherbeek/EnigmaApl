// ResearchDbManager.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SQLite3

/// Errors thrown by ResearchDbManager.
public enum ResearchDbError: Error {
    case cannotOpenDatabase(String)
    case prepareFailed(String)
    case stepFailed(String)
    case schemaCreationFailed(String)
}

/// Opens and manages `horoscope_data.db` in the project folder.
/// Provides CRUD for the `horoscope_data` table (input records only).
/// All methods are synchronous; call from a background context as needed.
public final class ResearchDbManager {

    private var db: OpaquePointer?

    // MARK: - Lifecycle

    /// Opens (or creates) the database at the given folder path.
    /// - Parameter folderPath: Directory where `horoscope_data.db` lives.
    public init(folderPath: String) throws {
        let url = URL(fileURLWithPath: folderPath, isDirectory: true)
            .appendingPathComponent("horoscope_data.db")
        let path = url.path
        guard sqlite3_open(path, &db) == SQLITE_OK else {
            let msg = db.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            throw ResearchDbError.cannotOpenDatabase(msg)
        }
        try createTableIfNeeded()
    }

    deinit {
        sqlite3_close(db)
    }

    // MARK: - Schema

    private func createTableIfNeeded() throws {
        let sql = """
        CREATE TABLE IF NOT EXISTS horoscope_data (
            id      INTEGER PRIMARY KEY,
            data    INTEGER NOT NULL,
            geoLat  REAL    NOT NULL,
            geoLon  REAL    NOT NULL,
            year    INTEGER NOT NULL,
            month   INTEGER NOT NULL,
            day     INTEGER NOT NULL,
            hour    INTEGER NOT NULL,
            minute  INTEGER NOT NULL,
            second  INTEGER NOT NULL,
            offset  REAL    NOT NULL
        );
        """
        var errMsg: UnsafeMutablePointer<CChar>?
        guard sqlite3_exec(db, sql, nil, nil, &errMsg) == SQLITE_OK else {
            let msg = errMsg.map { String(cString: $0) } ?? "unknown"
            sqlite3_free(errMsg)
            throw ResearchDbError.schemaCreationFailed(msg)
        }
    }

    // MARK: - Read

    /// Returns all rows ordered by id.
    public func fetchAll() throws -> [ResearchInputRecord] {
        let sql = """
        SELECT id, data, geoLat, geoLon, year, month, day, hour, minute, second, offset
        FROM horoscope_data ORDER BY id;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw ResearchDbError.prepareFailed(dbErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }

        var records: [ResearchInputRecord] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            records.append(rowToRecord(stmt!))
        }
        return records
    }

    /// Returns only the real-data rows (`data = 1`).
    public func fetchRealData() throws -> [ResearchInputRecord] {
        try fetchWhere(isData: true)
    }

    /// Returns only the control-group rows (`data = 0`).
    public func fetchControlGroup() throws -> [ResearchInputRecord] {
        try fetchWhere(isData: false)
    }

    /// Total number of records in the table.
    public func count() throws -> Int {
        let sql = "SELECT COUNT(*) FROM horoscope_data;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw ResearchDbError.prepareFailed(dbErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int64(stmt, 0))
    }

    // MARK: - Write

    /// Inserts a single record. Replaces on id conflict.
    public func insert(_ record: ResearchInputRecord) throws {
        let sql = """
        INSERT OR REPLACE INTO horoscope_data
            (id, data, geoLat, geoLon, year, month, day, hour, minute, second, offset)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw ResearchDbError.prepareFailed(dbErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }
        bindRecord(stmt!, record)
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw ResearchDbError.stepFailed(dbErrorMessage())
        }
    }

    /// Bulk-inserts records inside a single transaction for performance.
    public func insertAll(_ records: [ResearchInputRecord]) throws {
        let beginSql = "BEGIN TRANSACTION;"
        let commitSql = "COMMIT;"
        sqlite3_exec(db, beginSql, nil, nil, nil)
        for record in records {
            try insert(record)
        }
        sqlite3_exec(db, commitSql, nil, nil, nil)
    }

    /// Deletes the record with the given id.
    public func delete(id: Int) throws {
        let sql = "DELETE FROM horoscope_data WHERE id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw ResearchDbError.prepareFailed(dbErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int64(stmt, 1, Int64(id))
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw ResearchDbError.stepFailed(dbErrorMessage())
        }
    }

    /// Deletes all rows from the table.
    public func deleteAll() throws {
        let sql = "DELETE FROM horoscope_data;"
        var errMsg: UnsafeMutablePointer<CChar>?
        guard sqlite3_exec(db, sql, nil, nil, &errMsg) == SQLITE_OK else {
            let msg = errMsg.map { String(cString: $0) } ?? "unknown"
            sqlite3_free(errMsg)
            throw ResearchDbError.stepFailed(msg)
        }
    }

    // MARK: - Helpers

    private func fetchWhere(isData: Bool) throws -> [ResearchInputRecord] {
        let flag: Int32 = isData ? 1 : 0
        let sql = """
        SELECT id, data, geoLat, geoLon, year, month, day, hour, minute, second, offset
        FROM horoscope_data WHERE data = ? ORDER BY id;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw ResearchDbError.prepareFailed(dbErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int(stmt, 1, flag)

        var records: [ResearchInputRecord] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            records.append(rowToRecord(stmt!))
        }
        return records
    }

    private func rowToRecord(_ stmt: OpaquePointer) -> ResearchInputRecord {
        ResearchInputRecord(
            id: Int(sqlite3_column_int64(stmt, 0)),
            isData: sqlite3_column_int(stmt, 1) != 0,
            geoLat: sqlite3_column_double(stmt, 2),
            geoLon: sqlite3_column_double(stmt, 3),
            year: Int(sqlite3_column_int(stmt, 4)),
            month: Int(sqlite3_column_int(stmt, 5)),
            day: Int(sqlite3_column_int(stmt, 6)),
            hour: Int(sqlite3_column_int(stmt, 7)),
            minute: Int(sqlite3_column_int(stmt, 8)),
            second: Int(sqlite3_column_int(stmt, 9)),
            offset: sqlite3_column_double(stmt, 10)
        )
    }

    private func bindRecord(_ stmt: OpaquePointer, _ r: ResearchInputRecord) {
        sqlite3_bind_int64(stmt, 1, Int64(r.id))
        sqlite3_bind_int(stmt, 2, r.isData ? 1 : 0)
        sqlite3_bind_double(stmt, 3, r.geoLat)
        sqlite3_bind_double(stmt, 4, r.geoLon)
        sqlite3_bind_int(stmt, 5, Int32(r.year))
        sqlite3_bind_int(stmt, 6, Int32(r.month))
        sqlite3_bind_int(stmt, 7, Int32(r.day))
        sqlite3_bind_int(stmt, 8, Int32(r.hour))
        sqlite3_bind_int(stmt, 9, Int32(r.minute))
        sqlite3_bind_int(stmt, 10, Int32(r.second))
        sqlite3_bind_double(stmt, 11, r.offset)
    }

    private func dbErrorMessage() -> String {
        db.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown SQLite error"
    }
}
