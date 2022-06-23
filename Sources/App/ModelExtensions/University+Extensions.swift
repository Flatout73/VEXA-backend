//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 23.06.2022.
//

import Foundation
import SwiftProtobuf
import Protobuf

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
        uni.id = id?.uuidString ?? ""
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
