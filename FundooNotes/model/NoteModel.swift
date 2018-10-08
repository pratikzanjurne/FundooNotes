import Foundation

struct NoteModel{
    var title: String
    var note: String
    var image: NSData?
    var is_archived: Bool
    var is_remidered: Bool
    var is_deleted: Bool
    var creadted_date: String
    var colour: String
    var note_id: String
    var is_pinned:Bool
    var reminder_date:String?
    var reminder_time:String?
    var userId:String
    var edited_date:String
    var imageUrl:String?
    var imageHeight:CGFloat?
    var imageWidth:CGFloat?
}
