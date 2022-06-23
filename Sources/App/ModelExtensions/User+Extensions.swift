//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 23.06.2022.
//

import Fluent
import Vapor
import SwiftProtobuf
import Protobuf


extension UserModel {
    func requestUser() throws -> User {
        var user = User()
        if let id = self.id?.uuidString {
            user.id = id
            user.firstName = self.firstName ?? ""
            user.lastName = self.lastName ?? ""
            user.email = self.email ?? ""
            return user
        } else {
            throw AuthenticationError.userNotFound
        }
    }
}

extension User {
    var viewModel: UserModel {
        let user = UserModel(firstName: self.firstName,
                             lastName: self.lastName,
                             email: self.email,
                             password: self.password)
        return user
    }
}
