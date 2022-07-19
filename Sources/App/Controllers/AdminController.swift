//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Vapor
import Fluent
import Protobuf

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let admin = routes.grouped("users")

        // Authentication required
        admin.group(UserAuthenticator()) { authenticated in
            authenticated.get("me", use: getCurrentUser)

            authenticated.get(":x", use: index)

            // Only for resting purpose
            //authenticated.post(use: create)

            authenticated.group(":userID") { todo in
                todo.delete(use: delete)
            }
        }
    }

    func index(req: Request) async throws -> Proto {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let user = try await UserModel.find(id, on: req.db)?.requestUser(for: req.db) else {
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

        return Proto(from: try await user.requestUser(for: req.db))
    }

    func create(req: Request) async throws -> UserModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let userVM = try await User(jsonString: content).model(for: req.db)
        userVM.userType = .admin
        try await userVM.save(on: req.db)
        return userVM
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await UserModel.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .ok
    }
}
