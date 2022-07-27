import Fluent
import Vapor
import Foundation

enum UserType: String, Codable {
    case ambassador
    case student
    case admin
}

enum EmailVerificationType: String, Codable {
    case manually
    case google
    case apple
}

final class UserModel: Content, Model, Authenticatable {

    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String?
    @Field(key: "lastName")
    var lastName: String?
    @Field(key: "email")
    var email: String
    @OptionalField(key: "imageURL")
    var imageURL: String?
    @OptionalField(key: "password")
    var password: String?

    @OptionalField(key: "appleIdentifier")
    var appleIdentifier: String?

    @Enum(key: "userType")
    var userType: UserType
    @OptionalField(key: "emailVerified")
    var emailVerified: EmailVerificationType?

    @OptionalChild(for: \AmbassadorModel.$user)
    var ambassador: AmbassadorModel?

    @OptionalChild(for: \StudentModel.$user)
    var student: StudentModel?

    @Children(for: \DeviceModel.$user)
    var devices: [DeviceModel]

    init() {

    }

    init(userID: UUID? = nil, firstName: String, lastName: String, email: String,
         imageURL: String?,
         password: String?, userType: UserType = .student,
         emailVerified: EmailVerificationType? = nil) {
        self.id = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.imageURL = imageURL
        self.password = password
        self.userType = userType
        self.emailVerified = emailVerified
    }
}
