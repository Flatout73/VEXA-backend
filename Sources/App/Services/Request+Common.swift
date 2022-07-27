//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 08.07.2022.
//

import Vapor
import Fluent
import Protobuf

extension Request {
    func fetchStudent() async -> StudentModel? {
        do {
            let payload = try auth.require(SessionJWTToken.self)

            guard let user = try await users
                .find(id: payload.userID) else {
                throw AuthenticationError.userNotFound
            }

            try await user.$student.load(on: db)
            return user.student
        } catch {
            return nil
        }
    }

    func createRefreshToken(for user: UserModel) async throws -> Protobuf.LoginResponse {
        let req = self
        try await req.refreshTokens.delete(for: user.requireID())

        let token = req.random.generate(bits: 256)
        let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())

        try await req.refreshTokens
            .create(refreshToken)


        let streamToken = try req.stream.createToken(id: try user.requireID().uuidString)

        var response = Protobuf.LoginResponse()
        response.user = try await user.requestUser(for: req.db)
        response.accessToken = try req.jwt.sign(SessionJWTToken(user: user))
        response.refreshToken = token
        response.streamToken = streamToken.jwt

        return response
    }
}
