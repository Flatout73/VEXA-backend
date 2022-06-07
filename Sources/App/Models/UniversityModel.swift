//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.06.2022.
//

import Fluent
import Vapor
import Foundation

final class UniversityModel: Model, Vapor.Content {
    static let schema = "universities"
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String?

    @Field(key: "tags")
    var tags: [String]

    @Children(for: \.$university)
    var ambassadors: [AmbassadorModel]
}
