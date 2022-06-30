//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import JWT

struct SessionJWTToken: JWTPayload, Authenticatable {
    // Constants
    let expirationTime: TimeInterval = 60 * 15

    // Token Data
    var expiration: ExpirationClaim

    var userID: UUID
    //var email: String

    init(userId: UUID) {
        self.userID = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    init(user: UserModel) throws {
        self.userID = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
