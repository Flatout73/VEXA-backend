//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor
import Fluent

protocol StudentRepository: Repository {
    func create(_ user: StudentModel) async throws
    func delete(id: UUID) -> EventLoopFuture<Void>
    func all() -> EventLoopFuture<[StudentModel]>
    func find(id: UUID?) -> EventLoopFuture<StudentModel?>
    func find(email: String) -> EventLoopFuture<StudentModel?>
    func set<Field>(_ field: KeyPath<StudentModel, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void> where Field: QueryableProperty, Field.Model == StudentModel
    func count() -> EventLoopFuture<Int>
}

struct DatabaseUserRepository: StudentRepository, DatabaseRepository {
    let database: Database

    func create(_ user: StudentModel) async throws {
        return try await user.create(on: database)
    }

    func delete(id: UUID) -> EventLoopFuture<Void> {
        return StudentModel.query(on: database)
            .filter(\.$id == id)
            .delete()
    }

    func all() -> EventLoopFuture<[StudentModel]> {
        return StudentModel.query(on: database).all()
    }

    func find(id: UUID?) -> EventLoopFuture<StudentModel?> {
        return StudentModel.find(id, on: database)
    }

    func find(email: String) -> EventLoopFuture<StudentModel?> {
        return StudentModel.query(on: database)
            .filter(\.user.$email == email)
            .first()
    }

    func set<Field>(_ field: KeyPath<StudentModel, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void>
        where Field: QueryableProperty, Field.Model == StudentModel
    {
        return StudentModel.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }

    func count() -> EventLoopFuture<Int> {
        return StudentModel.query(on: database).count()
    }
}

extension Application.Repositories {
    var users: StudentRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }

        return storage(app)
    }

    func use(_ make: @escaping (Application) -> (StudentRepository)) {
        storage.makeUserRepository = make
    }
}
