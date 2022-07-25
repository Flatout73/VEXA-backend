//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Fluent

protocol UserRepository: Repository {
    func create(_ user: UserModel) async throws
    func delete(id: UUID) async throws
    func all() async throws -> [UserModel]
    func find(id: UUID?) async throws -> UserModel?
    func find(email: String) async throws -> UserModel?
    func findByAppleIdentifier(_ identifier: String) async throws -> UserModel?
    func setAsync<Field>(_ field: KeyPath<UserModel, Field>, to value: Field.Value, for userID: UUID) async throws where Field: QueryableProperty, Field.Model == UserModel
    func set<Field>(_ field: KeyPath<UserModel, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void> where Field: QueryableProperty, Field.Model == UserModel
    func count() async throws -> Int
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
    let database: Database

    func create(_ user: UserModel) async throws {
        try await user.create(on: database)
    }

    func delete(id: UUID) async throws {
        return try await UserModel.query(on: database)
            .filter(\.$id == id)
            .delete()
    }

    func all() async throws -> [UserModel] {
        return try await UserModel.query(on: database).all()
    }

    func find(id: UUID?) async throws -> UserModel? {
        return try await UserModel.find(id, on: database)
    }

    func find(email: String) async throws -> UserModel? {
        return try await UserModel.query(on: database)
            .filter(\.$email == email)
            .first()
    }

    func findByAppleIdentifier(_ identifier: String) async throws -> UserModel? {
        return try await UserModel.query(on: database)
            .filter(\.$appleIdentifier == identifier)
            .first()
    }

    func setAsync<Field>(_ field: KeyPath<UserModel, Field>, to value: Field.Value, for userID: UUID) async throws
        where Field: QueryableProperty, Field.Model == UserModel
    {
        return try await UserModel.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }

    func set<Field>(_ field: KeyPath<UserModel, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void>
        where Field: QueryableProperty, Field.Model == UserModel
    {
        return UserModel.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }

    func count() async throws -> Int {
        return try await UserModel.query(on: database).count()
    }
}

extension Application.Repositories {
    var users: UserRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }

        return storage(app)
    }

    func use(_ make: @escaping (Application) -> (UserRepository)) {
        storage.makeUserRepository = make
    }
}
