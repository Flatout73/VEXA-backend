//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 23.06.2022.
//

import Foundation

let fileFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "y-m-d-HH-MM-SS-"
    return formatter
}()
