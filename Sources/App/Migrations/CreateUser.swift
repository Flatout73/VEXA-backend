import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("firstName", .string, .required)
            .field("lastName", .string, .required)
            .field("email", .string, .required)
            .field("password", .string)
            .field("isAdmin", .bool)
            .field("isEmailVerified", .bool)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
