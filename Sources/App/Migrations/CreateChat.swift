//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Foundation
import FluentKit

struct CreateChat: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("messages")
            .id()
            .field("text", .string)
            .field("user", .uuid, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("messages").delete()
    }
}
