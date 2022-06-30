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
        universities.post(use: create)
        universities.group(":uniID") { todo in
            todo.delete(use: delete)
        }

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
}

