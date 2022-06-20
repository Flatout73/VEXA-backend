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
        contents.post(use: create)
        contents.group(":contentID") { todo in
            todo.delete(use: delete)
        }
    }

    func fetchAll(req: Request) async throws -> Proto {
        let contents = try await ContentModel.query(on: req.db).all()
            .compactMap { try? $0.requestContent() }
            .compactMap {
                try? Google_Protobuf_Any(message: $0)
            }
        var array = ArrayResponse()
        array.content = contents
        return Proto(from: array)
    }

    func create(req: Request) async throws -> ContentModel {
        guard let contentString = req.body.string else {
            throw Abort(.badRequest)
        }
        let content = try Protobuf.Content(jsonString: contentString, options: protoConfig)
        let vm = try await content.viewModel(for: req.db)
        try await vm.save(on: req.db)
        return vm
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let content = try await ContentModel.find(req.parameters.get("contentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await content.delete(on: req.db)
        return .ok
    }
}

extension ContentModel {
    func requestContent() throws -> Protobuf.Content {
        var content = Content()
        content.id = id?.uuidString ?? ""
        content.title = title ?? ""
        content.imageURL = imageURL ?? ""
        content.videoURL = videoURL ?? ""
        content.likes = likes
        var ambassador = Ambassador()
        ambassador.id = self.$ambassador.value?.id?.uuidString ?? ""
        //ambassador.user = try self.ambassador.user.$id.requestUser()
        content.ambassador = ambassador
        return content
    }
}

extension Protobuf.Content {
    func viewModel(for db: Database) async throws -> ContentModel {
        let content = ContentModel()
        content.id = UUID(uuidString: id)
        content.imageURL = imageURL
        content.videoURL = videoURL
        content.title = title
        content.likes = likes
        //try await content.save(on: db)
        let user = self.ambassador.user.viewModel
        try await user.save(on: db)
        let ambassador = AmbassadorModel()
        ambassador.$user.id = user.id!
        try await ambassador.save(on: db)
        try await ambassador.$contents.create(content, on: db)
//        let uni = UniversityModel()
//        uni.name = self.ambassador.university.name
//        try await uni.$ambassadors.create(ambassador, on: db)

        return content
    }
}
