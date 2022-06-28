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
            do {
                let message = try buffer.decodeWebsocketMessage()
                switch message.content {
                case .connectMessage(let connect):
                    let client = WebSocketClient(id: UUID(message.client)!, socket: ws)
                    self.clients.add(client)
                case .textMessage(let text):
                    if let client = self.clients.find(UUID(message.client)!) {
                        print("MSG", text)
                        client.messages.append(text.model)
                    }
                default:
                    print("Smth in socket")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func send() {

    }
}
