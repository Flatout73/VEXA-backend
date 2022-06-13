//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Protobuf
import Vapor
import SwiftProtobuf

extension GeneralResponse {
    init(from content: Google_Protobuf_Any) {
        self.init()
        self.content = content
    }
}

struct Proto: AsyncResponseEncodable {
    let response: GeneralResponse

    init(from content: Google_Protobuf_Any) {
        var response = GeneralResponse()
        response.content = content
        self.response = response
    }

    func encodeResponse(for request: Request) async throws -> Response {
        return .init(status: .ok, body: .init(string: try response.jsonString()))
    }
}
