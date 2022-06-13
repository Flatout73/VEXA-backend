//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor

protocol RequestService {
    func `for`(_ req: Request) -> Self
}
