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
                //emailVerificationRoutes.post("", use: sendEmailVerification)
                emailVerificationRoutes.get("", use: verifyEmail)
            }

            auth.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("", use: resetPassword)
                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
            }
            //auth.post("recover", use: recoverAccount)

            auth.post("accessToken", use: refreshAccessToken)

            // Authentication required
//            auth.group(UserAuthenticator()) { authenticated in
//                authenticated.get("me", use: getCurrentUser)
//            }
        }
    }

    private func register(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(UserModel.self)
//        let token = try user.generateToken()
//        try await token.save(on: req.db)
//        return token

        //try RegisterRequest.validate(req)
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }
//        guard registerRequest.password == registerRequest.confirmPassword else {
//            throw AuthenticationError.passwordsDontMatch
//        }
        var user = try User(jsonString: content)

        let hash = try req.password
            .hash(user.password)
        user.password = hash

        let createdUser = try await req.students
            .create(user.viewModel)

        //try req.emailVerifier.verify(for: createdUser)

        return .created
    }

    private func login(_ req: Request) async throws -> Proto {
        //try LoginRequest.validate(req)
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let loginRequest = try LoginRequest(jsonString: content)
        guard let user = try await req.students
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
        response.user = try user.requestUser()
        response.accessToken = try req.jwt.sign(SessionJWTToken(user: user))
        response.refreshToken = token
        return Proto(from: try Google_Protobuf_Any(message: response))

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
            guard let user = try await req.students.find(id: refreshToken.$user.id) else {
                throw AuthenticationError.refreshTokenOrUserNotFound
            }
            let token = req.random.generate(bits: 256)
            let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())

            let payload = try SessionJWTToken(user: user)
            let accessToken = try req.jwt.sign(payload)

            var response = Protobuf.LoginResponse()
            response.refreshToken = token
            response.accessToken = accessToken
            response.user = try user.requestUser()
            return Proto(from: try Google_Protobuf_Any(message: response))
        } else {
            throw AuthenticationError.refreshTokenHasExpired
        }
    }

//    private func getCurrentUser(_ req: Request) throws -> EventLoopFuture<UserDTO> {
//        let payload = try req.auth.require(Payload.self)
//
//        return req.users
//            .find(id: payload.userID)
//            .unwrap(or: AuthenticationError.userNotFound)
//            .map { UserDTO(from: $0) }
//    }

    private func verifyEmail(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.query.get(String.self, at: "token")

        let hashedToken = SHA256.hash(token)

        return req.emailTokens
            .find(token: hashedToken)
            .unwrap(or: AuthenticationError.emailTokenNotFound)
            .flatMap({ token -> EventLoopFuture<EmailToken> in req.emailTokens.delete(token).transform(to: token) })
            .guard({ (emailToken: EmailToken) -> Bool in emailToken.expiresAt > Date() },
                   else: AuthenticationError.emailTokenHasExpired)
            .flatMapThrowing {
                req.students.set(\.$isEmailVerified, to: true, for: $0.$user.id)
        }
        .transform(to: .ok)
    }

    private func resetPassword(_ req: Request) async throws -> HTTPStatus {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let resetPasswordRequest = try ResetPasswordRequest(jsonString: content)

        if let user = try await req.students
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
//    private func sendEmailVerification(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        let content = try req.content.decode(SendEmailVerificationRequest.self)
//
//        return req.users
//            .find(email: content.email)
//            .flatMap {
//                guard let user = $0, !user.isEmailVerified else {
//                    return req.eventLoop.makeSucceededFuture(.noContent)
//                }
//
//                return req.emailVerifier
//                    .verify(for: user)
//                    .transform(to: .noContent)
//        }
//    }
}
