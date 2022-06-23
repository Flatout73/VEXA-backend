import Fluent
import Vapor
import SwiftProtobuf
import Protobuf

struct AmbassadorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("ambassadors")
        users.get(":x", use: index)
        users.post(use: create)
//        users.group(":userID") { todo in
//            todo.delete(use: delete)
//        }
    }

    func index(req: Request) async throws -> Proto {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let user = try await AmbassadorModel.find(id, on: req.db)?.requestAmbassador() else {
            throw Abort(.notFound)
        }
        return Proto(from: try Google_Protobuf_Any(message: user))
    }

    func create(req: Request) async throws -> AmbassadorModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let userVM = try await CreateAmbassadorRequest(jsonString: content).model(for: req.db)
        try await userVM.save(on: req.db)
        return userVM
    }

//    func delete(req: Request) async throws -> HTTPStatus {
//        guard let user = try await UserModel.find(req.parameters.get("userID"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        try await user.delete(on: req.db)
//        return .ok
//    }
}
