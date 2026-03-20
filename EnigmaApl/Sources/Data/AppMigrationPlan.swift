//
//  AppMigrationPlan.swift
//  EnigmaApl
//
//  Defines versioned schemas and migration stages for Swift Data.
//  When changing the data model in a future release:
//    1. Add a new SchemaV(n) enum with the updated model types
//    2. Add it to AppMigrationPlan.schemas
//    3. Add a MigrationStage to AppMigrationPlan.stages
//

import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [
        HoroscopeModel.self,
        HoroscopeDateTimeModel.self,
        EventModel.self
    ]
}

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [SchemaV1.self]
    static var stages: [MigrationStage] = []
}
