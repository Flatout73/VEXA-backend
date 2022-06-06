import Fluent
import Vapor
import SwiftProtobuf

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index.leaf", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    app.get("users", ":x") { req -> Proto in
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        var response = GeneralResponse()
        guard let user = try await UserViewModel.find(id, on: req.db)?.requestUser else {
            throw Abort(.notFound)
        }
        response.content = try Google_Protobuf_Any(message: user)
        return Proto(response: response)
    }

    try app.register(collection: UserController())
}


struct Proto: AsyncResponseEncodable {
    let response: GeneralResponse

    func encodeResponse(for request: Request) async throws -> Response {
        return .init(status: .ok, body: .init(string: try response.jsonString()))
    }
}
