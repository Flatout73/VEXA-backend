import Fluent
import Vapor
import Protobuf
import JWT

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index.leaf", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

//    let passwordProtected = app.grouped(UserModel.authenticator(), UserModel.guardMiddleware())
//    passwordProtected.post("login") { req -> ClientTokenReponse in
//        let user = try req.auth.require(UserModel.self)
//        let payload = try SessionJWTToken(with: user)
//        return ClientTokenReponse(token: try req.jwt.sign(payload))
//    }

    try app.group("api") { api in
        // Authentication
        try api.register(collection: AuthenticationController())

        try api.register(collection: VideoController())
        try api.register(collection: ImageController())

        try api.register(collection: ContentController())
        try api.register(collection: StudentController())
        try api.register(collection: UniversityController())

        try api.register(collection: AdminController())
        try api.register(collection: AmbassadorController())

        try api.register(collection: OAuthController())
    }

    let chatSystem = ChatSystem(eventLoop: app.eventLoopGroup.next())
    app.webSocket("chat") { req, ws in
        chatSystem.connect(ws, database: req.db)
    }
}
