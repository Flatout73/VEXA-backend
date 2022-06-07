//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.06.2022.
//

import Fluent
import Vapor
import Foundation

final class StudentModel: Model, Vapor.Content {
    static let schema = "students"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user")
    var user: UserModel

    @OptionalField(key: "currentCountry")
    var currentCountry: String?
    @OptionalField(key: "nativeLanguage")
    var nativeLanguage: String?
    @OptionalField(key: "otherLanguages")
    var otherLanguages: [String]?
    @OptionalField(key: "enrolmentYear")
    var enrolmentYear: Int?
    @OptionalField(key: "bio")
    var bio: String?

    init() {

    }
}
