//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.06.2022.
//

import Fluent
import Vapor
import Foundation

final class UniversityModel: Model {
    static let schema = "universities"
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "tags")
    var tags: [String]

    @Children(for: \.$university)
    var ambassadors: [AmbassadorModel]

    @Field(key: .photos)
    var photos: [String]
    @Field(key: "applyLink")
    var applyLink: String
    @Field(key: "studentsCount")
    var studentsCount: Int
    @Field(key: "gpa")
    var gpa: Double
    @Field(key: "exams")
    var exams: String
    @OptionalField(key: "requirementsDescription")
    var requirementsDescription: String?
    @OptionalField(key: "facties")
    var facties: String?
    @Field(key: "latitude")
    var latitude: Double
    @Field(key: "longitude")
    var longitude: Double
    @Field(key: "phone")
    var phone: String
    @Field(key: "address")
    var address: String

    init() {
        tags = []
        photos = []
    }
}

extension UniversityModel: Vapor.Content {
    
}

extension FieldKey {
    static let photos: FieldKey = "photos"
}
