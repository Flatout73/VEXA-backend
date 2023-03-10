//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 07.06.2022.
//

import Vapor
import Fluent

final class AmbassadorModel: Model {
    static let schema = "ambassadors"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user")
    var user: UserModel

    @Parent(key: "university")
    var university: UniversityModel

    @Children(for: \.$ambassador)
    var contents: [ContentModel]
}

extension AmbassadorModel: Vapor.Content {

}
