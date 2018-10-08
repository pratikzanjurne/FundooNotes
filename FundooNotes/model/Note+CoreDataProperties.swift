
import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var colour: String?
    @NSManaged public var creadted_date: String?
    @NSManaged public var image: NSData?
    @NSManaged public var is_archived: Bool
    @NSManaged public var is_deleted: Bool
    @NSManaged public var is_remidered: Bool
    @NSManaged public var note: String?
    @NSManaged public var note_id: String?
    @NSManaged public var title: String?

}
