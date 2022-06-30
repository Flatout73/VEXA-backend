import Fluent
import Vapor
import SwiftProtobuf
import Protobuf

struct StudentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("students")
        users.get(":x", use: index)

//        users.group(":userID") { todo in
//            todo.delete(use: delete)
//        }

        users.group(UserAuthenticator()) { authenticated in
            authenticated.get("me", use: getCurrentUser)
        }
    }

    func index(req: Request) async throws -> Proto {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await StudentModel.find(id, on: req.db)?.requestStudent(for: req.db) else {
            throw Abort(.notFound)
        }
        return Proto(from: user)
    }

    private func getCurrentUser(_ req: Request) async throws -> Proto {
        let payload = try req.auth.require(SessionJWTToken.self)

        guard let user = try await req.users
            .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }

        try await user.$student.load(on: req.db)

        guard let student = try await user.student?.requestStudent(for: req.db) else {
            throw AuthenticationError.userNotFound
        }

        return Proto(from: student)
    }
    
//    func delete(req: Request) async throws -> HTTPStatus {
//        guard let user = try await UserModel.find(req.parameters.get("userID"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        try await user.delete(on: req.db)
//        return .ok
//    }
}
