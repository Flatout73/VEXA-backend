//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 30.06.2022.
//

import Vapor
import Fluent
import Protobuf

extension StudentModel {
    func requestStudent(for db: Database) async throws -> Student {
        var student = Student()
        try await self.$user.load(on: db)
        student.user = try await self.user.requestUser(for: db)
        student.nativeLanguage = self.nativeLanguage ?? ""
        student.bio = self.bio ?? ""
        student.otherLanguages = self.otherLanguages ?? []
        student.currentCountry = self.currentCountry ?? ""
        student.enrollmentYear = self.enrollmentYear ?? 0
        try await self.$unisFollowed.load(on: db)
        student.unisFollowed = self.unisFollowed.map {
            var uni = ShortUniversity()
            uni.name = $0.name
            uni.id = $0.id?.uuidString ?? ""
            uni.imageURL = $0.photos.first ?? ""
            return uni
        }
        return student
    }
}

extension Student {
    func model(for db: Database) async throws -> StudentModel {
        let student = StudentModel()
        student.user = try await self.user.model(for: db)
        student.nativeLanguage = self.nativeLanguage
        student.bio = self.bio
        student.otherLanguages = self.otherLanguages
        student.currentCountry = self.currentCountry
        student.enrollmentYear = self.enrollmentYear
        return student
    }
}
