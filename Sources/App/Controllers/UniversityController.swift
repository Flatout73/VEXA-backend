//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 20.06.2022.
//

import Fluent
import Vapor
import SwiftProtobuf
import Protobuf

struct UniversityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let universities = routes.grouped("universities")
        universities.get(use: fetchAll)
        universities.get(":x", use: index)
        universities.get("search", use: search)
        universities.post(use: create)

        universities.group(UserAuthenticator(), configure: { group in
            group.post([":uniID", "follow"], use: follow)
            group.delete(":uniID", use: delete)
        })

        universities.put([":x", "addImages"], use: addImages)
    }

    func fetchAll(req: Request) async throws -> Proto {
        let unis = try await UniversityModel.query(on: req.db).all()
        let contents = unis
            .compactMap { try? $0.requestUni() }
            .compactMap {
                try? Google_Protobuf_Any(message: $0)
            }
        var array = ArrayResponse()
        array.content = contents
        return Proto(from: array)
    }

    func index(req: Request) async throws -> Proto {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let uni = try await UniversityModel.find(id, on: req.db)?.requestUni() else {
            throw Abort(.notFound)
        }
        return Proto(from: try Google_Protobuf_Any(message: uni))
    }

    func create(req: Request) async throws -> UniversityModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let uniVM = try University(jsonString: content).viewModel
        try await uniVM.save(on: req.db)
        return uniVM
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let uni = try await UniversityModel.find(req.parameters.get("uniID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await uni.delete(on: req.db)
        return .ok
    }

    func addImages(req: Request) async throws -> UniversityModel {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let uni = try await UniversityModel.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        let files = try req.content.decode([String].self)

        let prefix = fileFormatter.string(from: .init())

        for file in files {
            uni.photos.append(file)
        }

        try await uni.update(on: req.db)

        return uni
    }

    func follow(req: Request) async throws -> HTTPStatus {
        guard let uni = try await UniversityModel.find(req.parameters.get("uniID"), on: req.db) else {
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

        try await uni.$studentsFollowed.load(on: req.db)

        if try await uni.$studentsFollowed.isAttached(to: student, on: req.db) {
            try await uni.$studentsFollowed.detach(student, on: req.db)
        } else {
            try await uni.$studentsFollowed.attach(student, on: req.db)
        }

        try await uni.save(on: req.db)

        return .ok
    }

    func search(req: Request) async throws -> Proto {
        let query = try req.query.get(String.self, at: "query")

        var array = ArrayResponse()
        for uni in try await UniversityModel.query(on: req.db)
            //.join(AmbassadorModel.self, on: \UniversityModel.$ambassadors.idValue == \AmbassadorModel.$id)
            //.join(UserModel.self, on: \AmbassadorModel.$user.$id == \UserModel.$id)
            //.join(ContentModel.self, on: \AmbassadorModel.$contents.$id == \ContentModel.$id)
            .group(.or, { group in
            group.filter(\UniversityModel.$name ~~ query)
                    //.filter("tags", .subset(inverse: true), query)
                    .filter(DatabaseQuery.Field.path(["tags"], schema: "universities"), .custom("&&"), DatabaseQuery.Value.custom("'{\"\(query)\"}'"))
                    //.filter(.custom("SELECT * FROM universities WHERE tags = ANY(\(query);"))
                    .filter(\UniversityModel.$exams ~~ query)
                    .filter(\UniversityModel.$requirementsDescription ~~ query)
               // .filter(UserModel.self, \UserModel.$firstName ~~ query)
               // .filter(UserModel.self, \UserModel.$lastName ~~ query)
               // .filter(ContentModel.self, \ContentModel.$title ~~ query)
        })
            .all()
        {
            let vm = try await uni.requestUni()
            array.content.append(try Google_Protobuf_Any(message: vm))
        }
        return Proto(from: array)
    }
}

