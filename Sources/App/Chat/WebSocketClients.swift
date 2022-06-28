//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Foundation
import Vapor

open class WebsocketClients {
    var eventLoop: EventLoop
    var storage: [UUID: WebSocketClient]

    var active: [WebSocketClient] {
        self.storage.values.filter { !$0.socket.isClosed }
    }

    init(eventLoop: EventLoop, clients: [UUID: WebSocketClient] = [:]) {
        self.eventLoop = eventLoop
        self.storage = clients
    }

    func add(_ client: WebSocketClient) {
        self.storage[client.id] = client
    }

    func remove(_ client: WebSocketClient) {
        self.storage[client.id] = nil
    }

    func find(_ uuid: UUID) -> WebSocketClient? {
        self.storage[uuid]
    }

    deinit {
        let futures = self.storage.values.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}
