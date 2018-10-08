import Foundation
import UIKit
import UserNotifications


class Helper {
    static let shared = Helper()
    
    private init(){
        
    }
    
    func getScaledHeight(imageWidth:CGFloat,imageHeight:CGFloat,scaleWidth:CGFloat) -> CGFloat{
        let oldWidth = imageWidth
        let scalFactor = scaleWidth/oldWidth
        return imageHeight * scalFactor
    }
    enum photoOptionSelected {
        case camera
        case gallary
    }
    
    enum reminderOptionSelected{
        case date
        case time
        case repeate
    }
    
    enum sideMenuOptionSelected {
        case notes
        case reminder
        case archived
        case deleted
    }
    
    func compareDate(date:String,time:String,completion:(String)->Void){
        let dateD = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let todaysDate = formatter.string(from: dateD)
        if todaysDate == date{
            completion("Today \(time)")
            return
        }
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day); // +1 day
        let tomorrow = Calendar.current.date(byAdding: dateComponents, to: dateD)
        let tomorrowDateString = formatter.string(from: tomorrow!)
        if tomorrowDateString == date{
            completion("Tomorrow \(time)")
        }else{
            completion("\(date) \(time)")
        }
    }
    
    func setReminderForArray(notes:[NoteModel],reminderDate:String,reminderTime:String,completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.setReminder(note: note, reminderDate: reminderDate, reminderTime: reminderTime, completion: { (result, message) in
                completion(result, message)
            })
        }
    }
    
    func setReminder(note:NoteModel,reminderDate:String,reminderTime:String,completion:@escaping (Bool,String)->Void) {
//        let center = UNUserNotificationCenter.current()
//        let options: UNAuthorizationOptions = [.alert,.sound]
//        center.requestAuthorization(options: options) { (granted, error) in
//            if !granted{
//            }
//        }
//        center.getNotificationSettings { (setting) in
//            if setting.authorizationStatus != .authorized{
//
//            }
//        }
        let content = UNMutableNotificationContent()
        content.body = note.note
        content.title = note.title
        content.sound = UNNotificationSound.default()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy h:mm a"
        let convertedDate = dateFormater.date(from: "\(reminderDate) \(reminderTime)")
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: convertedDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: note.note_id, content: content, trigger: trigger)
        AppDelegate.center.add(request) { (error) in
            if error == nil{
                completion(true,"Reminder has been set.")
            }
        }
    }

}
