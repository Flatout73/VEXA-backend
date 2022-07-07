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
        contents.group(UserAuthenticator()) { auth in
            auth.post(use: create)
            auth.post([":contentID", "like"], use: like)
            auth.group(":contentID") { todo in
                todo.delete(use: delete)
            }
        }
    }

    func fetchAll(req: Request) async throws -> Proto {
        let student: StudentModel? = await fetchStudent(for: req)

        var array = ArrayResponse()
        for content in try await ContentModel.query(on: req.db).all() {
            let vm = try await content.requestContent(on: req.db, for: student)
            array.content.append(try Google_Protobuf_Any(message: vm))
        }
        return Proto(from: array)
    }

    func create(req: Request) async throws -> ContentModel {
        guard let contentString = req.body.string else {
            throw Abort(.badRequest)
        }

        let payload = try req.auth.require(SessionJWTToken.self)

        guard let user = try await req.users
            .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }

        try await user.$ambassador.load(on: req.db)
        let ambassador: AmbassadorModel? = user.ambassador

        let content = try Protobuf.CreateContentRequest(jsonString: contentString, options: protoConfig)
        let vm = try await content.viewModel(for: req.db, ambassador: ambassador)
        try await vm.save(on: req.db)
        return vm
    }

    func like(req: Request) async throws -> HTTPStatus {
        guard let content = try await ContentModel.find(req.parameters.get("contentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let payload = try req.auth.require(SessionJWTToken.self)

        guard let user = try await req.users
            .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }

        try await user.$student.load(on: req.db)

        guard let student = user.student else {
            throw AuthenticationError.userNotFound
        }

        try await content.$likes.load(on: req.db)

        if try await content.$likes.isAttached(to: student, on: req.db) {
            try await content.$likes.detach(student, on: req.db)
        } else {
            try await content.$likes.attach(student, on: req.db)
        }

        try await content.save(on: req.db)

        return .ok
    }

    func search(req: Request) async throws -> Proto {
        let query = try req.query.get(String.self, at: "query")

        let student: StudentModel? = await fetchStudent(for: req)

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
            let vm = try await content.requestContent(on: req.db, for: student)
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

    private func fetchStudent(for req: Request) async -> StudentModel? {
        do {
            let payload = try req.auth.require(SessionJWTToken.self)

            guard let user = try await req.users
                .find(id: payload.userID) else {
                throw AuthenticationError.userNotFound
            }

            try await user.$student.load(on: req.db)
            return user.student
        } catch {
            return nil
        }
    }
}
