import Fluent
import Vapor
import Protobuf

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index.leaf", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: ContentController())
    try app.register(collection: StudentController())
}


struct Proto: AsyncResponseEncodable {
    let response: GeneralResponse

    func encodeResponse(for request: Request) async throws -> Response {
        return .init(status: .ok, body: .init(string: try response.jsonString()))
    }
}
