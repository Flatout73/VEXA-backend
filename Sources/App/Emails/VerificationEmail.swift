//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Foundation

struct VerificationEmail: Email {
    let templateName: String = "email_verification"
    let verifyUrl: String

    var subject: String {
        "Please verify your email"
    }

    var templateData: [String : String] {
        ["verify_url": verifyUrl]
    }

    init(verifyUrl: String) {
        self.verifyUrl = verifyUrl
    }
}
