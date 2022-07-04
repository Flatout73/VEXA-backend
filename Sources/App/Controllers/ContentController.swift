//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.06.2022.
//

import Fluent
import Vapor
import Protobuf
import SwiftProtobuf

struct ContentController: RouteCollection {
    var protoConfig = JSONDecodingOptions()

    init() {
        protoConfig.ignoreUnknownFields = true
    }

    func boot(routes: RoutesBuilder) throws {
        let contents = routes.grouped("discovery")
        contents.get(use: fetchAll)
        contents.get("search", use: search)
        contents.post(use: create)
        contents.post([":contentID", "like"], use: like)
        contents.group(":contentID") { todo in
            todo.delete(use: delete)
        }
    }

    func fetchAll(req: Request) async throws -> Proto {
        var array = ArrayResponse()
        for content in try await ContentModel.query(on: req.db).all() {
            let vm = try await content.requestContent(on: req.db)
            array.content.append(try Google_Protobuf_Any(message: vm))
        }
        return Proto(from: array)
    }

    func create(req: Request) async throws -> ContentModel {
        guard let contentString = req.body.string else {
            throw Abort(.badRequest)
        }
        let content = try Protobuf.CreateContent(jsonString: contentString, options: protoConfig)
        let vm = try await content.viewModel(for: req.db)
        try await vm.save(on: req.db)
        return vm
    }

    func like(req: Request) async throws -> HTTPStatus {
        guard let content = try await ContentModel.find(req.parameters.get("contentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let payload = try req.auth.require(SessionJWTToken.self)

        guard let userID = try await req.users
            .find(id: payload.userID)?.id?.uuidString else {
            throw AuthenticationError.userNotFound
        }

        if let index = content.likes.firstIndex(of: userID) {
            content.likes.remove(at: index)
        } else {
            content.likes.append(userID)
        }
        try await content.save(on: req.db)

        return .ok
    }

    func search(req: Request) async throws -> Proto {
         let query = try req.query.get(String.self, at: "query")

        var array = ArrayResponse()
        for content in try await ContentModel.query(on: req.db)
            .join(AmbassadorModel.self, on: \ContentModel.$ambassador.$id == \AmbassadorModel.$id)
            .join(UserModel.self, on: \AmbassadorModel.$user.$id == \UserModel.$id)
            .group(.or, { group in
            group.filter(\ContentModel.$title ~~ query)
                .filter(\ContentModel.$description ~~ query)
                .filter(UserModel.self, \UserModel.$firstName ~~ query)
        })
            .all()
        {
            let vm = try await content.requestContent(on: req.db)
            array.content.append(try Google_Protobuf_Any(message: vm))
        }
        return Proto(from: array)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let content = try await ContentModel.find(req.parameters.get("contentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await content.delete(on: req.db)
        return .ok
    }
}
