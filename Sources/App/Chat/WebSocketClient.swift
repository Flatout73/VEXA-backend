//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Vapor

open class WebSocketClient {
    open var id: UUID
    open var socket: WebSocket

    public init(id: UUID, socket: WebSocket) {
        self.id = id
        self.socket = socket
    }
}
