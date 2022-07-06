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
    @OptionalField(key: "enrollmentYear")
    var enrollmentYear: Int32?
    @OptionalField(key: "bio")
    var bio: String?

    @Timestamp(key: "dateOfBirthday", on: .none)
    var dateOfBirthday: Date?

    init() {

    }
}
