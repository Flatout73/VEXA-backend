//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor

extension Request {
    var random: RandomGenerator {
        self.application.random
    }
}
