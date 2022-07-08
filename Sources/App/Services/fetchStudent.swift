//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 08.07.2022.
//

import Vapor
import Fluent

func fetchStudent(for req: Request) async -> StudentModel? {
    do {
        let payload = try req.auth.require(SessionJWTToken.self)

        guard let user = try await req.users
            .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }

        try await user.$student.load(on: req.db)
        return user.student
    } catch {
        return nil
    }
}
