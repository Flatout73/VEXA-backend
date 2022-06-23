//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 23.06.2022.
//

import Protobuf
import SwiftProtobuf
import Fluent
import Foundation

extension ContentModel {
    func requestContent(on database: Database) async throws -> Protobuf.Content {
        var content = Content()
        content.id = id?.uuidString ?? ""
        content.title = title ?? ""
        content.imageURL = imageURL ?? ""
        content.videoURL = videoURL ?? ""
        content.likes = likes
        try await self.$ambassador.load(on: database)
        try await self.ambassador.$user.load(on: database)
        content.ambassador = try self.$ambassador.wrappedValue.requestAmbassador()
        return content
    }
}

extension Protobuf.CreateContent {
    func viewModel(for db: Database) async throws -> ContentModel {
        let content = ContentModel()
        content.imageURL = imageURL
        content.videoURL = videoURL
        content.title = title
        let ambassador = try await AmbassadorModel.find(UUID(self.ambassadorID), on: db)
//            content.$ambassador.id = ambassadorID
//        }
        //try await content.save(on: db)
//        let user = self.ambassador.user.viewModel
//        try await user.save(on: db)
//        let ambassador = AmbassadorModel()
//        ambassador.$user.id = user.id!
//        try await ambassador.save(on: db)

        try await ambassador?.$contents.create(content, on: db)

//        let uni = UniversityModel()
//        uni.name = self.ambassador.university.name
//        try await uni.$ambassadors.create(ambassador, on: db)

        return content
    }
}
