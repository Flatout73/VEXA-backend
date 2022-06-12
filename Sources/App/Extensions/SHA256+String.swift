//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Crypto
import Foundation

extension SHA256 {
    /// Returns hex-encoded string
    static func hash(_ string: String) -> String {
        SHA256.hash(data: string.data(using: .utf8)!)
    }

    /// Returns a hex encoded string
    static func hash<D>(data: D) -> String where D : DataProtocol {
        SHA256.hash(data: data).hex
    }
}
