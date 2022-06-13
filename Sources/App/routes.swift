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

        try api.register(collection: ContentController())
    }


    try app.register(collection: StudentController())
}
