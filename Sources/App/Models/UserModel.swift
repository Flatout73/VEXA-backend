import Fluent
import Vapor
import Foundation

final class UserModel: Content, Model, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String?
    @Field(key: "lastName")
    var lastName: String?
    @Field(key: "email")
    var email: String?
    @OptionalField(key: "imageURL")
    var imageURL: URL?
    @OptionalField(key: "password")
    var password: String?

    @Field(key: "isAdmin")
    var isAdmin: Bool
    @Field(key: "isEmailVerified")
    var isEmailVerified: Bool

    init() {

    }

    init(userID: UUID? = nil, firstName: String, lastName: String, email: String,
         password: String?, isAdmin: Bool = false,
         isEmailVerified: Bool = false) {
        self.id = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.isAdmin = isAdmin
        self.isEmailVerified = isEmailVerified
    }
}
