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
    let response: SwiftProtobuf.Message

    init(from content: SwiftProtobuf.Message) {
        self.response = content
    }

    func encodeResponse(for request: Request) async throws -> Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        return .init(status: .ok, headers: headers, body: .init(string: try response.jsonString()))
    }
}
