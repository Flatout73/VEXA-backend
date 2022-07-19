import Vapor
import Fluent

func migrations(_ app: Application) throws {
    // Initial Migrations
    app.migrations.add([CreateUniversity(), CreateUser(), CreateAmbassador(),
                        CreateStudent(), CreateContent(), CreateChat(), CreateDevice(),
                        CreateLike(), CreateFollow()])
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateEmailToken())
    app.migrations.add(CreatePasswordToken())

    let pass = try app.password.hash("!vexa!")
    let user = UserModel(userID: UUID(uuidString: "669C7011-E716-492D-80AF-ADBECDAADBA1"),
                         firstName: "Test",
                         lastName: "User",
                         email: "leonid173m@gmail.com",
                         imageURL: nil,
                         password: pass,
                         userType: .admin,
                         isEmailVerified: true)

    Task {
        try await user.save(on: app.db)
    }
}
