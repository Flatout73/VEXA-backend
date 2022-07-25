//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 22.07.2022.
//

import Fluent
import JWT
import Vapor
import Protobuf

struct SIWAAPIController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("apple") { apple in
            apple.post(use: authHandler)
        }
    }

    func authHandler(req: Request) async throws -> Proto {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let request = try SIWARequest(jsonString: content)

        let appleIdentityToken = try await req.jwt.apple.verify(request.appleIdentityToken,
                                                                applicationIdentifier: AppConfig.environment.applicationIdentifier)

        let user: UserModel = try await {
            if let user = try await req.application.repositories
                .users.findByAppleIdentifier(appleIdentityToken.subject.value) {
                print("user", user)

                return user
            } else {
                // TODO: Handle empy name and email
                let createdUser = UserModel(firstName: request.firstName ?? "John",
                                            lastName: request.lastName ?? "Doe",
                                            email: request.email,
                                            imageURL: nil,
                                            password: nil)
                try await req.users
                    .create(createdUser)

                createdUser.isEmailVerified = true

                try await createdUser.$student.create(StudentModel(), on: req.db)

                return createdUser
            }
        }()

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

//  static func signUp(
//    appleIdentityToken: AppleIdentityToken,
//    firstName: String? = nil,
//    lastName: String? = nil,
//    req: Request
//  ) -> EventLoopFuture<UserResponse> {
//    guard let email = appleIdentityToken.email else {
//      return req.eventLoop.makeFailedFuture(UserError.siwaEmailMissing)
//    }
//    return User.assertUniqueEmail(email, req: req).flatMap {
//      let user = User(
//        email: email,
//        firstName: firstName,
//        lastName: lastName,
//        appleUserIdentifier: appleIdentityToken.subject.value
//      )
//      return user.save(on: req.db)
//        .flatMap {
//          guard let accessToken = try? user.createAccessToken(req: req) else {
//            return req.eventLoop.future(error: Abort(.internalServerError))
//          }
//          return accessToken.save(on: req.db)
//            .flatMapThrowing { try .init(accessToken: accessToken, user: user) }
//      }
//    }
//  }
//
//  static func signIn(
//    appleIdentityToken: AppleIdentityToken,
//    firstName: String? = nil,
//    lastName: String? = nil,
//    req: Request
//  ) -> EventLoopFuture<UserResponse> {
//    User.findByAppleIdentifier(appleIdentityToken.subject.value, req: req)
//      .unwrap(or: Abort(.notFound))
//      .flatMap { user -> EventLoopFuture<User> in
//        if let email = appleIdentityToken.email {
//          user.email = email
//          user.firstName = firstName
//          user.lastName = lastName
//          return user.update(on: req.db).transform(to: user)
//        } else {
//          return req.eventLoop.future(user)
//        }
//      }
//      .flatMap { user in
//        guard let accessToken = try? user.createAccessToken(req: req) else {
//          return req.eventLoop.future(error: Abort(.internalServerError))
//        }
//        return accessToken.save(on: req.db)
//          .flatMapThrowing { try .init(accessToken: accessToken, user: user) }
//    }
//  }
}
