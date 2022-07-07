//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 20.06.2022.
//

import Foundation
import Fluent

struct CreateUniversity: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("universities")
            .id()
            .field("name", .string, .required)
            .field("tags", .array(of: .string))
            .field(.photos, .array(of: .string), .required)
            .field("applyLink", .string, .required)
            .field("studentsCount", .int32, .required)
            .field("gpa", .double)
            .field("exams", .string)
            .field("requirementsDescription", .string)
            .field("facties", .string)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("phone", .string, .required)
            .field("address", .string, .required)
            .field("price", .int32)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("universities").delete()
    }
}
