//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 08.07.2022.
//

import Foundation
import Fluent

struct CreateFollow: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("student+follow")
            .id()
            .field("uniID", .uuid, .references("universities", "id"))
            .field("studentID", .uuid, .references("students", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("student+follow").delete()
    }
}
