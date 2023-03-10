//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Vapor
import Queues
import Fluent
import Mailgun

extension QueueContext {
    var db: Database {
        application.databases
            .database(logger: self.logger, on: self.eventLoop)!
    }

    func mailgun() -> MailgunProvider {
        application.mailgun().delegating(to: self.eventLoop)
    }

    func mailgun(_ domain: MailgunDomain? = nil) -> MailgunProvider {
        application.mailgun(domain).delegating(to: self.eventLoop)
    }

    var appConfig: AppConfig {
        application.config
    }
}
