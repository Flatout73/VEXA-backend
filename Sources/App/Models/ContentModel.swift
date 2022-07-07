//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.06.2022.
//

import Fluent
import Vapor

final class ContentModel: Model, Vapor.Content {
    static let schema = "contents"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "ambassador")
    var ambassador: AmbassadorModel

    @Field(key: "title")
    var title: String
    @OptionalField(key: "description")
    var description: String?
    @OptionalField(key: "videoURL")
    var videoURL: String?
    @OptionalField(key: "imageURL")
    var imageURL: String?
    @Field(key: "approved")
    var approved: Bool

    @Siblings(through: LikeModel.self, from: \.$content, to: \.$student)
    var likes: [StudentModel]

    init() {
        self.approved = false
    }
}
