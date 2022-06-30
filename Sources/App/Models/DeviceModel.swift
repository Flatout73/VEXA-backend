//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Foundation
import Fluent
import Vapor

final class DeviceModel: Content, Model {
    static let schema = "devices"

    @ID(key: .id)
    var id: UUID?

    @OptionalField(key: "pushToken")
    var pushToken: String?

    @Parent(key: "user")
    var user: UserModel

    init() {

    }
}
