//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.07.2022.
//

import Fluent
import Vapor
import Foundation

final class LikeModel: Model {
    static let schema = "content+like"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "contentID")
    var content: ContentModel

    @Parent(key: "studentID")
    var student: StudentModel

    init() { }

    init(id: UUID? = nil, content: ContentModel, student: StudentModel) throws {
        self.id = id
        self.$content.id = try content.requireID()
        self.$student.id = try student.requireID()
    }
}
