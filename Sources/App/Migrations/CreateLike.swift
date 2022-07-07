//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.07.2022.
//

import Foundation
import Fluent

struct CreateLike: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("content+like")
            .id()
            .field("contentID", .uuid, .references("contents", "id"))
            .field("studentID", .uuid, .references("students", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("content+like").delete()
    }
}
