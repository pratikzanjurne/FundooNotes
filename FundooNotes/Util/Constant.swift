
import Foundation

struct Constant {
    
    struct App{
        static let APP_NAME = "FundooNotes"
    }
    struct Color {
        static let colorWhite = "#ffffff"
        static let colorBlack = "#000000"
        static let colourForFilterOn = "#507786"
        static let colourOrange = "#f9bd00"
        static let colourReminderText = "#898989"
        static let colorForDeleted = "#555555"
    }
    
    struct DashboardViewTitle{
        static let noteView = "Notes"
        static let reminderView = "Remindered"
        static let archivedView = "Archived"
        static let deletedView = "Deleted"
    }
    
    struct Image{
        static let archive = "archive"
        static let deleted = "delete"
        static let reminder = "remind"
    }
    
    enum NoteOfType{
        case note
        case reminder
        case archive
        case deleted
    }
    
    enum TableViewOptions{
        case delete
        case makeACopy
        case send
        case colabrator
        case Labels
        case restore
    }
    
}
