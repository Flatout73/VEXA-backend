//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Fluent
import Vapor

struct ImageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let images = routes.grouped("images")

        images.post("uploadImages", use: uploadImages)
    }

    func uploadImages(req: Request) async throws -> [String] {
        let files = try req.content.decode([File].self)

        let prefix = fileFormatter.string(from: .init())

        var urls: [String] = []

        for file in files where file.data.readableBytes > 0 {
            let fileName = prefix + file.filename
            let path = req.application.directory.publicDirectory + fileName
            //let isImage = ["png", "jpeg", "jpg", "gif"].contains(file.extension?.lowercased())
            try await req.fileio.writeFile(file.data, at: path)

            urls.append("\(req.application.config.frontendURL)/\(fileName)")
        }

        return urls
    }
}

