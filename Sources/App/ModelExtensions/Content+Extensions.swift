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
    func requestContent(on database: Database, for student: StudentModel?) async throws -> Protobuf.Content {
        var content = Content()
        content.id = id?.uuidString ?? ""
        content.title = title ?? ""
        content.imageURL = imageURL ?? ""
        content.videoURL = videoURL ?? ""
        content.description_p = description
        content.category = category.rawValue
        try await self.$likes.load(on: database)
        content.likesCount = Int32(likes.count)
        if let student = student {
            content.isLikedByMe = try await self.$likes.isAttached(to: student, on: database)
        } else {
            content.isLikedByMe = false
        }
        try await self.$ambassador.load(on: database)
        try await self.ambassador.$user.load(on: database)
        content.ambassador = try await self.$ambassador.wrappedValue.requestAmbassador(for: database)
        return content
    }
}

extension Protobuf.CreateContentRequest {
    func viewModel(for db: Database, ambassador: AmbassadorModel?) async throws -> ContentModel {
        let content = ContentModel()
        content.imageURL = imageURL
        content.videoURL = videoURL
        content.title = title
        content.description = description_p
        content.category = Category(rawValue: category) ?? .other
        try await ambassador?.$contents.create(content, on: db)

        return content
    }
}
