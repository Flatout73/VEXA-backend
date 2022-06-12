//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Protobuf
import Fluent

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { auth in
            auth.post("register", use: register)
            auth.post("login", use: login)

            auth.group("email-verification") { emailVerificationRoutes in
                emailVerificationRoutes.post("", use: sendEmailVerification)
                emailVerificationRoutes.get("", use: verifyEmail)
            }

            auth.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("", use: resetPassword)
                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
            }
            auth.post("recover", use: recoverAccount)

            auth.post("accessToken", use: refreshAccessToken)

            // Authentication required
//            auth.group(UserAuthenticator()) { authenticated in
//                authenticated.get("me", use: getCurrentUser)
//            }
        }
    }

    private func register(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
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
        var student = try Protobuf.Student(jsonString: content)

        return req.password
            .async
            .hash(student.password)
            .flatMapThrowing { hash in
                student.password = hash
                return student.viewModel
            }
            .flatMap { user in
                req.students
                    .create(user)
                    .flatMapErrorThrowing {
                        if let dbError = $0 as? DatabaseError, dbError.isConstraintFailure {
                            throw AuthenticationError.emailAlreadyExists
                        }
                        throw $0
                }
                //.flatMap { req.emailVerifier.verify(for: user) }
        }
        .transform(to: .created)
    }

    private func login(_ req: Request) async throws -> Proto {
        //try LoginRequest.validate(req)
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let loginRequest = try LoginRequest(jsonString: content)
        return await req.students
            .find(email: loginRequest.email)
            .unwrap(or: AuthenticationError.invalidEmailOrPassword)
            .guard({ $0.user.isEmailVerified }, else: AuthenticationError.emailIsNotVerified)
            .flatMap { student -> EventLoopFuture<StudentModel> in
                return req.password
                    .async
                    .verify(loginRequest.password, created: student.user.password ?? "")
                    .guard({ $0 == true }, else: AuthenticationError.invalidEmailOrPassword)
                    .transform(to: student)
        }
        .flatMap { user -> EventLoopFuture<StudentModel> in
            do {
                return try req.refreshTokens.delete(for: user.requireID()).transform(to: user)
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
        .flatMap { user in
            do {
                let token = req.random.generate(bits: 256)
                let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())

                return req.refreshTokens
                    .create(refreshToken)
                    .flatMapThrowing {
                        var response = Protobuf.LoginResponse()
                        response.student = try user.requestStudent()
                        response.accessToken = try req.jwt.sign(SessionJWTToken(user: user.user))
                        response.refreshToken = token
                        return Proto(from: response)
                }
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }

    private func refreshAccessToken(_ req: Request) throws -> EventLoopFuture<Proto> {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let accessTokenRequest = try AccessTokenRequest(jsonString: content)
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)

        return req.refreshTokens
            .find(token: hashedRefreshToken)
            .unwrap(or: AuthenticationError.refreshTokenOrUserNotFound)
            .flatMap { req.refreshTokens.delete($0).transform(to: $0) }
            .guard({ $0.expiresAt > Date() }, else: AuthenticationError.refreshTokenHasExpired)
            .flatMap { req.students.find(id: $0.$user.id) }
            .unwrap(or: AuthenticationError.refreshTokenOrUserNotFound)
            .flatMap { user in
                do {
                    let token = req.random.generate(bits: 256)
                    let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())

                    let payload = try SessionJWTToken(with: user.user)
                    let accessToken = try req.jwt.sign(payload)

                    return req.refreshTokens
                        .create(refreshToken)
                        .transform(to: (token, accessToken, user))
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
        }
        .map {
            var response = Protobuf.LoginResponse()
            response.refreshToken = $0
            response.accessToken = $1
            response.student = $2
            return Proto(from: response)
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
            .flatMap { req.emailTokens.delete($0).transform(to: $0) }
            .guard({ $0.expiresAt > Date() },
                   else: AuthenticationError.emailTokenHasExpired)
            .flatMap {
                req.students.set(\.$isEmailVerified, to: true, for: $0.$user.id)
        }
        .transform(to: .ok)
    }

    private func resetPassword(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let resetPasswordRequest = try req.content.decode(ResetPasswordRequest.self)

        return req.students
            .find(email: resetPasswordRequest.email)
            .flatMap {
                if let user = $0 {
                    return req.passwordResetter
                        .reset(for: user)
                        .transform(to: .noContent)
                } else {
                    return req.eventLoop.makeSucceededFuture(.noContent)
                }
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

    private func recoverAccount(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try RecoverAccountRequest.validate(req)
        let content = try req.content.decode(RecoverAccountRequest.self)

        guard content.password == content.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }

        let hashedToken = SHA256.hash(content.token)

        return req.passwordTokens
            .find(token: hashedToken)
            .unwrap(or: AuthenticationError.invalidPasswordToken)
            .flatMap { passwordToken -> EventLoopFuture<Void> in
                guard passwordToken.expiresAt > Date() else {
                    return req.passwordTokens
                        .delete(passwordToken)
                        .transform(to: req.eventLoop
                            .makeFailedFuture(AuthenticationError.passwordTokenHasExpired)
                    )
                }

                return req.password
                    .async
                    .hash(content.password)
                    .flatMap { digest in
                        req.users.set(\.$passwordHash, to: digest, for: passwordToken.$user.id)
                }
                .flatMap { req.passwordTokens.delete(for: passwordToken.$user.id) }
        }
        .transform(to: .noContent)
    }

    private func sendEmailVerification(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let content = try req.content.decode(SendEmailVerificationRequest.self)

        return req.users
            .find(email: content.email)
            .flatMap {
                guard let user = $0, !user.isEmailVerified else {
                    return req.eventLoop.makeSucceededFuture(.noContent)
                }

                return req.emailVerifier
                    .verify(for: user)
                    .transform(to: .noContent)
        }
    }
}
