import Vapor

func migrations(_ app: Application) throws {
    // Initial Migrations
    app.migrations.add([CreateUniversity(), CreateUser(), CreateAmbassador(), CreateContent(), CreateChat(), CreateDevice()])
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateEmailToken())
    app.migrations.add(CreatePasswordToken())
}
