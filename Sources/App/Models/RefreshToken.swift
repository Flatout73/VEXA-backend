//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Fluent


final class RefreshToken: Model {
    static let schema = "user_refresh_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Parent(key: "userID")
    var user: UserModel

    @Field(key: "expiresAt")
    var expiresAt: Date

    @Field(key: "issuedAt")
    var issuedAt: Date

    init() {}

    init(id: UUID? = nil, token: String, userID: UUID, expiresAt: Date = Date().addingTimeInterval(Constants.REFRESH_TOKEN_LIFETIME), issuedAt: Date = Date()) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.issuedAt = issuedAt
    }
}
