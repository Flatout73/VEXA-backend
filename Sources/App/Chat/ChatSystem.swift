//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Foundation
import Vapor

class ChatSystem {
    var clients: WebsocketClients

    init(eventLoop: EventLoop) {
        self.clients = WebsocketClients(eventLoop: eventLoop)
    }

    func connect(_ ws: WebSocket) {
        ws.onBinary { [unowned self] ws, buffer in
            if let msg = buffer.decodeWebsocketMessage(Connect.self) {
                let player = WebSocketClient(id: msg.client, socket: ws)
                self.clients.add(player)
            }
        }
    }
}
