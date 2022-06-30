//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Vapor
import Queues

struct EmailVerifier {
    let emailTokenRepository: EmailTokenRepository
    let config: AppConfig
    let queue: Queue
    let eventLoop: EventLoop
    let generator: RandomGenerator

    func verify(for user: UserModel) async throws -> EmailToken {
        let token: String
        let emailToken: EmailToken
        if let existedEmailToken = try await emailTokenRepository.find(userID: user.requireID()) {
            token = existedEmailToken.token
            emailToken = existedEmailToken
        } else {
            token = generator.generate(bits: 256)
            emailToken = try EmailToken(userID: user.requireID(), token: SHA256.hash(token))
            try await emailTokenRepository.create(emailToken)
            print("Email token created: \(emailToken)")
        }
        let verifyUrl = url(token: token)

        // TODO: Add mailgun
        //try await self.queue.dispatch(EmailJob.self, .init(VerificationEmail(verifyUrl: verifyUrl), to: user.email))

        return emailToken
    }

    private func url(token: String) -> String {
        #"\#(config.apiURL)/auth/email-verification?token=\#(token)"#
    }
}

extension Application {
    var emailVerifier: EmailVerifier {
        .init(emailTokenRepository: self.repositories.emailTokens, config: self.config, queue: self.queues.queue, eventLoop: eventLoopGroup.next(), generator: self.random)
    }
}

extension Request {
    var emailVerifier: EmailVerifier {
        .init(emailTokenRepository: self.emailTokens, config: application.config, queue: self.queue, eventLoop: eventLoop, generator: self.application.random)
    }
}
