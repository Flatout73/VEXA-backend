import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.routes.defaultMaxBodySize = "10mb"

    if let databaseURL = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: databaseURL) {
        postgresConfig.tlsConfiguration = .makeClientConfiguration()
        postgresConfig.tlsConfiguration?.certificateVerification = .none
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vexa",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_vexa_password",
            database: Environment.get("DATABASE_NAME") ?? "vexa"
        ), as: .psql)
    }

    app.views.use(.leaf)

    // MARK: Mailgun
//    app.mailgun.configuration = .environment
//    app.mailgun.defaultDomain = .sandbox

    // MARK: App Config
    app.config = .environment

    try services(app)
    app.jwt.signers.use(.hs256(key: "VEXA"))

    // register routes
    try routes(app)
    try migrations(app)
    // try queues(app)

    if app.environment == .development {
        try app.autoMigrate().wait()
        //try app.queues.startInProcessJobs()
    }
}
