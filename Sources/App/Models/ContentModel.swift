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
    var title: String?
    @OptionalField(key: "videoURL")
    var videoURL: URL?
    @OptionalField(key: "nativeLanguage")
    var imageURL: URL?
    @Field(key: "likes")
    var likes: [String]
    @Field(key: "approved")
    var approved: Bool

    init() {

    }
}
