//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Vapor
import Queues
import QueuesRedisDriver

func queues(_ app: Application) throws {
    // MARK: Queues Configuration
    if app.environment != .testing {
        try app.queues.use(
            Application.Queues.Provider
                .redis(url:
                        Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379"
                      )
        )
    }

    // MARK: Jobs
    app.queues.add(EmailJob())
}
