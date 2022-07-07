import Vapor

func migrations(_ app: Application) throws {
    // Initial Migrations
    app.migrations.add([CreateUniversity(), CreateUser(), CreateAmbassador(),
                        CreateStudent(), CreateContent(), CreateChat(), CreateDevice(),
                        CreateLike(), CreateFollow()])
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateEmailToken())
    app.migrations.add(CreatePasswordToken())
}
