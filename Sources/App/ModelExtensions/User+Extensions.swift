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
    func requestUser(for database: Database) async throws -> User {
        var user = User()
        if let id = self.id?.uuidString {
            user.id = id
            user.firstName = self.firstName ?? ""
            user.lastName = self.lastName ?? ""
            user.email = self.email
            user.imageURL = self.imageURL ?? ""
            user.userType = self.userType.requestType
            try await self.$devices.load(on: database)
            user.deviceIds = self.devices.compactMap({ $0.id?.uuidString })
            return user
        } else {
            throw AuthenticationError.userNotFound
        }
    }
}

extension User {
    func model(for database: Database) async throws -> UserModel {
        let user = UserModel(firstName: self.firstName,
                             lastName: self.lastName,
                             email: self.email,
                             password: self.password)
        let devices: [DeviceModel] = self.deviceIds.map {
            let device = DeviceModel()
            device.id = UUID($0)
            device.$user.id = user.id!
            return device
        }

        for device in devices {
            try await device.save(on: database)
        }

        return user
    }
}

extension User.UserType {
    var model: UserType {
        switch self {
        case .admin:
            return .admin
        case .ambassador:
            return .ambassador
        case .student:
            return .student
        default:
            return .student
        }
    }
}

extension UserType {
    var requestType: User.UserType {
        switch self {
        case .admin:
            return .admin
        case .ambassador:
            return .ambassador
        case .student:
            return .student
        default:
            return .student
        }
    }
}
