//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 12.06.2022.
//

import Vapor

func services(_ app: Application) throws {
    app.randomGenerators.use(.random)
    //app.repositories.use(.database)
}
