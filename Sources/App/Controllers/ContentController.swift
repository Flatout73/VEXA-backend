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
    func boot(routes: RoutesBuilder) throws {
        let contents = routes.grouped("discovery")
        contents.get(use: fetchAll)
        contents.post(use: create)
        contents.group(":contentID") { todo in
            todo.delete(use: delete)
        }
    }

    func fetchAll(req: Request) async throws -> Proto {
        var response = GeneralResponse()
        let contents = try await ContentModel.query(on: req.db).all()
            .compactMap { $0.requestContent }
            .compactMap {
                try? Google_Protobuf_Any(message: $0)
            }
        var array = ArrayResponse()
        array.content = contents
        response.arrayContent = array
        return Proto(response: response)
    }

    func create(req: Request) async throws -> ContentModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let userVM = try Protobuf.Content(jsonString: content).viewModel
        try await userVM.save(on: req.db)
        return userVM
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
    var requestContent: Protobuf.Content? {
        var content = Content()
        if let id = self.id?.uuidString {
            content.id = id
            content.title = title ?? ""
            content.imageURL = imageURL?.path ?? ""
            content.videoURL = videoURL?.path ?? ""
            content.likes = likes
            var ambassador = Ambassador()
            ambassador.id = self.ambassador.id?.uuidString ?? ""
            ambassador.email = self.ambassador.user.email ?? ""
            ambassador.firstName = self.ambassador.user.firstName ?? ""
            ambassador.lastName = self.ambassador.user.lastName ?? ""
            content.ambassador = ambassador
            return content
        }

        return nil
    }
}

extension Protobuf.Content {
    var viewModel: ContentModel {
        let content = ContentModel()
        content.id = UUID(uuidString: id)
        content.imageURL = URL(string: imageURL)
        content.videoURL = URL(string: videoURL)
        let ambassador = AmbassadorModel()
        ambassador.id = UUID(uuidString: self.ambassador.id)
        ambassador.user.firstName = self.ambassador.firstName
        content.ambassador = ambassador
        return content
    }
}
