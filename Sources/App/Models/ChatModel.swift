//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Foundation
import Fluent
import Vapor

final class ChatModel: Model, Vapor.Content {
    static let schema = "chatMessages"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user")
    var user: UserModel

    @OptionalField(key: "text")
    var text: String?

    init() {

    }
}
