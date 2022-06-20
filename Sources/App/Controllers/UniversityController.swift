//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 20.06.2022.
//

import Fluent
import Vapor
import SwiftProtobuf
import Protobuf

struct UniversityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let universities = routes.grouped("universities")
        universities.get(":x", use: index)
        universities.post(use: create)
        universities.group(":uniID") { todo in
            todo.delete(use: delete)
        }

        universities.put([":x", "uploadImages"], use: uploadImages)
    }

    func index(req: Request) async throws -> Proto {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let uni = try await UniversityModel.find(id, on: req.db)?.requestUni() else {
            throw Abort(.notFound)
        }
        return Proto(from: try Google_Protobuf_Any(message: uni))
    }

    func create(req: Request) async throws -> UniversityModel {
        guard let content = req.body.string else {
            throw Abort(.badRequest)
        }
        let uniVM = try University(jsonString: content).viewModel
        try await uniVM.save(on: req.db)
        return uniVM
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let uni = try await UniversityModel.find(req.parameters.get("uniID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await uni.delete(on: req.db)
        return .ok
    }

    func uploadImages(req: Request) async throws -> [String] {
        guard let id = req.parameters.get("x", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let uni = try await UniversityModel.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        let files = try req.content.decode([File].self)

        let formatter = DateFormatter()
        formatter.dateFormat = "y-m-d-HH-MM-SS-"
        let prefix = formatter.string(from: .init())

        for file in files where file.data.readableBytes > 0 {
            let fileName = prefix + file.filename
            let path = req.application.directory.publicDirectory + fileName
            //let isImage = ["png", "jpeg", "jpg", "gif"].contains(file.extension?.lowercased())
            try await req.fileio.writeFile(file.data, at: path)

            let serverConfig = req.application.http.server.configuration
            let hostname = serverConfig.hostname
            let port = serverConfig.port

            uni.photos.append("\(hostname):\(port)/\(fileName)")
            try await uni.update(on: req.db)
        }

        return uni.photos
    }
}

extension UniversityModel {
    func requestUni() throws -> University {
        var uni = University()
        uni.name = name
        uni.photos = photos
        uni.address = address
        uni.applyLink = applyLink
        uni.exams = exams
        uni.requirementsDescription = requirementsDescription ?? ""
        uni.facties = facties ?? ""
        uni.gpa = gpa
        uni.studentsCount = Int32(studentsCount)
        uni.latitude = latitude
        uni.longitude = longitude
        uni.phone = phone
        uni.address = address
        uni.tags = tags
        let ambassadors = self.$ambassadors.value?.map { amb -> University.Ambassador in
            var ambassdor = University.Ambassador()
            ambassdor.id = amb.id?.uuidString ?? ""
            ambassdor.name = amb.user.firstName ?? "" + (amb.user.lastName ?? "")
            ambassdor.imageURL = amb.user.imageURL?.path ?? ""
            return ambassdor
        } ?? []
        uni.ambassador = ambassadors
        uni.videos = self.$ambassadors.value?.map {
            let content = $0.contents.first
            var video = University.Video()
            video.id = content?.id?.uuidString ?? ""
            video.imageURL = content?.imageURL ?? ""
            video.likes = Int32(content?.likes.count ?? 0)
            return video
        } ?? []
        return uni
    }
}

extension University {
    var viewModel: UniversityModel {
        let uni = UniversityModel()
        uni.name = name
        uni.photos = photos
        uni.address = address
        uni.applyLink = applyLink
        uni.exams = exams
        uni.requirementsDescription = requirementsDescription
        uni.facties = facties
        uni.gpa = gpa
        uni.studentsCount = Int(studentsCount)
        uni.latitude = latitude
        uni.longitude = longitude
        uni.phone = phone
        uni.address = address
        uni.tags = tags
        return uni
    }
}

