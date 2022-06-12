import Fluent
import Vapor
import SwiftProtobuf
import Protobuf

struct StudentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(":x", use: index)
        users.post(use: create)
        users.group(":userID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> Proto {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await StudentModel.find(id, on: req.db)?.requestStudent() else {
            throw Abort(.notFound)
        }
        return Proto(from: try Google_Protobuf_Any(message: user))
    }

    func create(req: Request) async throws -> StudentModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let userVM = try Student(jsonString: content).viewModel
        try await userVM.save(on: req.db)
        return userVM
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await UserModel.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .ok
    }
}

extension StudentModel {
    func requestStudent() throws -> Student {
        var user = Student()
        if let id = self.id?.uuidString {
            user.id = id
            user.firstName = self.user.firstName ?? ""
            user.lastName = self.user.lastName ?? ""
            user.email = self.user.email ?? ""
            return user
        } else {
            throw AuthenticationError.userNotFound
        }
    }
}

extension Student {
    var viewModel: StudentModel {
        let student = StudentModel()
        let user = UserModel(firstName: self.firstName,
                             lastName: self.lastName,
                             email: self.email,
                             password: self.password)
        student.user = user
        return student
    }
}
