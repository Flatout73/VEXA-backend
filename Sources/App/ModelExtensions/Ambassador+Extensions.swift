//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 23.06.2022.
//

import Protobuf
import Fluent
import Foundation

extension AmbassadorModel {
    func requestAmbassador(for db: Database) async throws -> Ambassador {
        var ambassador = Ambassador()
        ambassador.user = try await self.$user.wrappedValue.requestUser(for: db)
        return ambassador
    }
}

extension CreateAmbassadorRequest {
    func model(for db: Database) async throws -> AmbassadorModel {
        let ambassador = AmbassadorModel()
        if let id = UUID(self.universityID) {
            ambassador.$university.id = id
        }

        let user = try await self.user.model(for: db)
        user.userType = .ambassador
        try await user.save(on: db)
        if let id = user.id {
            ambassador.$user.id = id
        }
        try await ambassador.save(on: db)
        return ambassador
    }
}
