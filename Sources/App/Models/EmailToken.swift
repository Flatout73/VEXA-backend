//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Fluent

final class EmailToken: Model, Content {
    static let schema = "user_email_tokens"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: UserModel

    @Field(key: "token")
    var token: String

    @Field(key: "expires_at")
    var expiresAt: Date

    init() {}

    init(
        id: UUID? = nil,
        userID: UUID,
        token: String,
        expiresAt: Date = Date().addingTimeInterval(Constants.EMAIL_TOKEN_LIFETIME)
    ) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
}
