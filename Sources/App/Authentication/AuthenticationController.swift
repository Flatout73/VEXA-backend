//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Protobuf
import Fluent
import SwiftProtobuf

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { auth in
            auth.post("register", use: register)
            auth.post("login", use: login)

            auth.group("email-verification") { emailVerificationRoutes in
                emailVerificationRoutes.post(use: sendEmailVerification)
                emailVerificationRoutes.get(use: verifyEmail)
            }

            auth.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("", use: resetPassword)
                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
            }
            //auth.post("recover", use: recoverAccount)

            auth.post("accessToken", use: refreshAccessToken)
        }
    }

    private func register(_ req: Request) async throws -> UserModel {
//        let user = try req.auth.require(UserModel.self)
//        let token = try user.generateToken()
//        try await token.save(on: req.db)
//        return token

        //try RegisterRequest.validate(req)
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }
        
        var user = try User(jsonString: content)

        let hash = try req.password
            .hash(user.password)
        user.password = hash

        let createdUser = try await user.model(for: req.db)
        try await req.users
            .create(createdUser)

        try await req.emailVerifier.verify(for: createdUser)

        try await createdUser.$student.create(StudentModel(), on: req.db)

        return createdUser
    }

    private func login(_ req: Request) async throws -> Proto {
        //try LoginRequest.validate(req)
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let loginRequest = try LoginRequest(jsonString: content)
        guard let user = try await req.users
            .find(email: loginRequest.email) else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        guard user.isEmailVerified else {
            throw AuthenticationError.emailIsNotVerified
        }

        guard try req.password.verify(loginRequest.password, created: user.password ?? "") else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        try await req.refreshTokens.delete(for: user.requireID())

        let token = req.random.generate(bits: 256)
        let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())

        try await req.refreshTokens
            .create(refreshToken)

        var response = Protobuf.LoginResponse()
        response.user = try await user.requestUser(for: req.db)
        response.accessToken = try req.jwt.sign(SessionJWTToken(user: user))
        response.refreshToken = token
        return Proto(from: response)

    }

    private func refreshAccessToken(_ req: Request) async throws -> Proto {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let accessTokenRequest = try AccessTokenRequest(jsonString: content)
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)

        guard let refreshToken = try await req.refreshTokens
            .find(token: hashedRefreshToken) else {
            throw AuthenticationError.refreshTokenOrUserNotFound
        }
        try await req.refreshTokens
            .delete(refreshToken)

        if refreshToken.expiresAt > Date() {
            guard let user = try await req.users.find(id: refreshToken.$user.id) else {
                throw AuthenticationError.refreshTokenOrUserNotFound
            }
            let token = req.random.generate(bits: 256)
            let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
            try await req.refreshTokens.create(refreshToken)

            let payload = try SessionJWTToken(user: user)
            let accessToken = try req.jwt.sign(payload)

            var response = Protobuf.LoginResponse()
            response.refreshToken = token
            response.accessToken = accessToken
            response.user = try await user.requestUser(for: req.db)
            return Proto(from: response)
        } else {
            throw AuthenticationError.refreshTokenHasExpired
        }
    }

    private func verifyEmail(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let hashedToken = try req.query.get(String.self, at: "token")

        return req.emailTokens
            .find(token: hashedToken)
            .unwrap(or: AuthenticationError.emailTokenNotFound)
            .flatMap({ token -> EventLoopFuture<EmailToken> in req.emailTokens.delete(token).transform(to: token) })
            .guard({ (emailToken: EmailToken) -> Bool in emailToken.expiresAt > Date() },
                   else: AuthenticationError.emailTokenHasExpired)
            .flatMapThrowing {
                req.users.set(\.$isEmailVerified, to: true, for: $0.$user.id)
        }
        .transform(to: .ok)
    }

    private func resetPassword(_ req: Request) async throws -> HTTPStatus {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let resetPasswordRequest = try ResetPasswordRequest(jsonString: content)

        if let user = try await req.users
            .find(email: resetPasswordRequest.email){
            return .ok
        } else {
            throw AuthenticationError.userNotFound
        }
    }

    private func verifyResetPasswordToken(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.query.get(String.self, at: "token")

        let hashedToken = SHA256.hash(token)

        return req.passwordTokens
            .find(token: hashedToken)
            .unwrap(or: AuthenticationError.invalidPasswordToken)
            .flatMap { passwordToken in
                guard passwordToken.expiresAt > Date() else {
                    return req.passwordTokens
                        .delete(passwordToken)
                        .transform(to: req.eventLoop
                            .makeFailedFuture(AuthenticationError.passwordTokenHasExpired)
                    )
                }

                return req.eventLoop.makeSucceededFuture(.noContent)
        }
    }

//    private func recoverAccount(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        try RecoverAccountRequest.validate(req)
//        let content = try req.content.decode(RecoverAccountRequest.self)
//
//        guard content.password == content.confirmPassword else {
//            throw AuthenticationError.passwordsDontMatch
//        }
//
//        let hashedToken = SHA256.hash(content.token)
//
//        return req.passwordTokens
//            .find(token: hashedToken)
//            .unwrap(or: AuthenticationError.invalidPasswordToken)
//            .flatMap { passwordToken -> EventLoopFuture<Void> in
//                guard passwordToken.expiresAt > Date() else {
//                    return req.passwordTokens
//                        .delete(passwordToken)
//                        .transform(to: req.eventLoop
//                            .makeFailedFuture(AuthenticationError.passwordTokenHasExpired)
//                    )
//                }
//
//                return req.password
//                    .async
//                    .hash(content.password)
//                    .flatMap { digest in
//                        req.users.set(\.$passwordHash, to: digest, for: passwordToken.$user.id)
//                }
//                .flatMap { req.passwordTokens.delete(for: passwordToken.$user.id) }
//        }
//        .transform(to: .noContent)
//    }
//
    private func sendEmailVerification(_ req: Request) async throws -> EmailToken {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let emailRequest = try EmailVerificationRequest(jsonString: content)

        guard let user = try await req.users
            .find(email: emailRequest.email) else {
            throw AuthenticationError.userNotFound
        }

        guard !user.isEmailVerified else {
            throw AuthenticationError.userNotFound
        }

        return try await req.emailVerifier
            .verify(for: user)
    }
}
