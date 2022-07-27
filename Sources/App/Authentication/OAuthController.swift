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

struct OAuthController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("oauth") { oauth in
            oauth.post("apple", use: authHandler)
            oauth.post("google", use: authHandler)
        }
    }

    func authHandler(req: Request) async throws -> Proto {
        guard let content = req.body.string else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let loginRequest = try LoginRequest(jsonString: content)

        let user: UserModel = try await {
            switch loginRequest.token {
            case .siwa(let request):
                let appleIdentityToken = try await req.jwt.apple.verify(request.appleIdentityToken,
                                                                        applicationIdentifier: AppConfig.environment.applicationIdentifier)
                return try await handleSiwa(appleIdentityToken: appleIdentityToken, req: req, firstName: request.firstName,
                                            lastName: request.lastName, email: loginRequest.email)
            case .google(let request):
                let googleIDToken = try await req.jwt.google.verify(request.idToken)
                return try await handleGoogle(googleToken: googleIDToken, req: req, email: googleIDToken.email ?? loginRequest.email)
            default:
                throw AuthenticationError.invalidPasswordToken
            }
        }()
        
        return Proto(from: try await req.createRefreshToken(for: user))
  }

    func handleSiwa(appleIdentityToken: AppleIdentityToken, req: Request,
                    firstName: String, lastName: String, email: String) async throws -> UserModel {
        if let user = try await req.application.repositories
            .users.findByAppleIdentifier(appleIdentityToken.subject.value) {
            print("user", user)

            return user
        } else {
            // TODO: Handle empy name and email
            let createdUser = UserModel(firstName: firstName ?? "John",
                                        lastName: lastName ?? "Doe",
                                        email: email,
                                        imageURL: nil,
                                        password: nil)
            createdUser.appleIdentifier = appleIdentityToken.subject.value
            createdUser.emailVerified = .apple

            try await req.users
                .create(createdUser)

            try await createdUser.$student.create(StudentModel(), on: req.db)

            return createdUser
        }
    }

    func handleGoogle(googleToken: GoogleIdentityToken, req: Request, email: String) async throws -> UserModel {
        if let user = try await req.application.repositories
            .users.find(email: email) {
            print("user", user)
            return user
        } else {
            // TODO: Handle empy name and email
            let createdUser = UserModel(firstName: googleToken.givenName ?? "John",
                                        lastName: googleToken.familyName ?? "Doe",
                                        email: email,
                                        imageURL: googleToken.picture,
                                        password: nil)
            createdUser.emailVerified = .google

            try await req.users
                .create(createdUser)

            try await createdUser.$student.create(StudentModel(), on: req.db)

            return createdUser
        }
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
