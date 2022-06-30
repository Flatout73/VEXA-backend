//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Fluent

struct CreateRefreshToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_refresh_tokens")
            .id()
            .field("token", .string)
            .field("userID", .uuid, .references("users", "id", onDelete: .cascade))
            .field("expiresAt", .datetime)
            .field("issuedAt", .datetime)
            .unique(on: "token")
            .unique(on: "userID")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_refresh_tokens").delete()
    }
}
