import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var lastname: String?
    @NSManaged public var moble_number: String?
    @NSManaged public var password: String?
    @NSManaged public var userid: String?
    @NSManaged public var username: String?

}
