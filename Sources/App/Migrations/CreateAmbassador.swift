//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Fluent
import Foundation

struct CreateAmbassador: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("ambassadors")
            .id()
            .field("user", .uuid, .references("users", "id", onDelete: .cascade))
            //.field("contents", .array(of: .uuid))
            .field("university", .uuid, .references("universities", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("ambassadors").delete()
    }
}
