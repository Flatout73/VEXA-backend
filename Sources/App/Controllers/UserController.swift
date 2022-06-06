import Fluent
import Vapor
import SwiftProtobuf

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        //users.get(use: index)
        users.post(use: create)
        users.group(":userID") { todo in
            todo.delete(use: delete)
        }
    }

//    func index(req: Request) async throws -> GeneralResponse {
//        let usersVM = try await UserViewModel.query(on: req.db).all()
//        let users = usersVM.compactMap({ $0.requestUser })
//        let reponse = GeneralResponse()
//        reponse.content = users
//    }

    func create(req: Request) async throws -> UserViewModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let userVM = try User(jsonString: content).viewModel
        try await userVM.save(on: req.db)
        return userVM
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await UserViewModel.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .ok
    }
}

extension UserViewModel {
    var requestUser: User? {
        var user = User()
        if let id = self.id?.uuidString {
            user.id = id
            user.firstName = self.firstName ?? ""
            user.lastName = self.lastName ?? ""
            user.email = self.email ?? ""
            user.password = self.password ?? ""
            return user
        }

        return nil
    }
}

extension User {
    var viewModel: UserViewModel {
        return UserViewModel(firstName: self.firstName,
                             lastName: self.lastName,
                             email: self.email,
                             password: self.password)
    }
}
