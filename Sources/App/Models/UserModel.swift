import Fluent
import Vapor
import Foundation

enum UserType: String, Codable {
    case ambassador
    case student
    case admin
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

    @Enum(key: "userType")
    var userType: UserType
    @Field(key: "isEmailVerified")
    var isEmailVerified: Bool

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
         isEmailVerified: Bool = false) {
        self.id = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.imageURL = imageURL
        self.password = password
        self.userType = userType
        self.isEmailVerified = isEmailVerified
    }
}
