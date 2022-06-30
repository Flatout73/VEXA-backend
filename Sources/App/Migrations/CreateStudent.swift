import Fluent

struct CreateStudent: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("students")
            .id()
            .field("currentCountry", .string)
            .field("nativeLanguage", .string)
            .field("otherLanguages", .array(of: .string))
            .field("enrollmentYear", .int32)
            .field("bio", .string)
            .field("user", .uuid, .references("users", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("students").delete()
    }
}
