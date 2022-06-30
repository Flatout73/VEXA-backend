//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Foundation

protocol Email: Codable {
    var templateName: String { get }
    var templateData: [String: String] { get }
    var subject: String { get }
}

struct AnyEmail: Email {
    var templateName: String
    var templateData: [String : String]
    var subject: String

    init<E>(_ email: E) where E: Email {
        self.templateData = email.templateData
        self.templateName = email.templateName
        self.subject = email.subject
    }
}
