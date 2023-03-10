//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Fluent

struct CreateContent: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("contents")
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("videoURL", .string)
            .field("imageURL", .string)
            .field("approved", .bool, .required)
            .field("ambassador", .uuid, .references("ambassadors", "id", onDelete: .cascade))
            .field("category", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("contents").delete()
    }
}
