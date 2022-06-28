//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Foundation
import Vapor
import Protobuf

extension ByteBuffer {
    func decodeWebsocketMessage() throws -> WebSocketMessage {
        let data = Data(buffer: self)
        let webSocketMessage = try WebSocketMessage(jsonUTF8Data: data)
        return webSocketMessage
    }
}
