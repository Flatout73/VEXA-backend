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
    func requestAmbassador() throws -> Ambassador {
        var ambassador = Ambassador()
        ambassador.user = try self.$user.wrappedValue.requestUser()
        return ambassador
    }
}

extension CreateAmbassadorRequest {
    func model(for db: Database) async throws -> AmbassadorModel {
        let ambassador = AmbassadorModel()
        ambassador.$university.id = UUID(self.universityID) ?? UUID()

        let user = self.user.viewModel
        user.userType = .ambassador
        try await user.save(on: db)
        if let id = user.id {
            ambassador.$user.id = id
        }
        try await ambassador.save(on: db)
        return ambassador
    }
}
