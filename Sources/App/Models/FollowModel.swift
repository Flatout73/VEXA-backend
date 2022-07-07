//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.07.2022.
//

import Foundation
import Fluent

final class FollowModel: Model {
    static let schema = "student+follow"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "uniID")
    var uni: UniversityModel

    @Parent(key: "studentID")
    var student: StudentModel

    init() { }

    init(id: UUID? = nil, uni: UniversityModel, student: StudentModel) throws {
        self.id = id
        self.$uni.id = try uni.requireID()
        self.$student.id = try student.requireID()
    }
}
