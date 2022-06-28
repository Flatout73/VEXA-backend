//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 28.06.2022.
//

import Foundation
import Protobuf

//extension ChatModel {
//    func requestChat() throws -> ChatMessage {
//        var message = ChatMessage()
//        if let id = self.id?.uuidString {
//            message.id = id
//            message.text = text
//            return message
//        } else {
//            throw AuthenticationError.userNotFound
//        }
//    }
//}

extension ChatMessage {
    var model: ChatModel {
        var message = ChatModel()
        message.text = text
        return message
    }
}

