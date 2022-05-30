import Fluent
import Vapor
import Foundation

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String?
    @Field(key: "lastName")
    var lastName: String?
    @Field(key: "email")
    var email: String?
    @Field(key: "password")
    var password: String?

    init() {

    }

    init(userID: UUID? = nil, firstName: String, lastName: String, email: String, password: String) {
        self.id = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
    }
}
