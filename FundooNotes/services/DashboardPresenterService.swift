import Foundation

class DashboardPresenterService {
    func getNotes(completion:@escaping ([NoteModel])->Void){
//        NoteDBManager.getNotes { (notes) in
//            completion(notes)
//        }
        FirebaseDBManager.shared.getNotes { (notes) in
            completion(notes)
        }
    }
    
    func getDeletedNotes(completion:@escaping ([NoteModel])->Void){
//        NoteDBManager.getDeletedNotes { (notes) in
//            completion(notes)
//        }
        FirebaseDBManager.shared.getDeletedNotes { (notes) in
            completion(notes)
        }
    }
    func getNotesOfType(_ type:Constant.NoteOfType,completion:@escaping ([NoteModel])->Void){
//        NoteDBManager.getNotesOfType(type) { (notes) in
//            completion(notes)
//        }
        FirebaseDBManager.shared.getNotesOfType(type) { (notes) in
            completion(notes)
        }
    }
    
    func pinNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
//        NoteDBManager.pinNoteArray(notes: notes) { (status,message) in
//            completion(status,message)
//        }
        FirebaseDBManager.shared.pinNoteArray(notes: notes) { (status, message) in
            completion(status, message)
        }
    }
    func deleteNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        FirebaseDBManager.shared.deleteNoteArray(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    
    func deleteNoteArrayFromTrash(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        FirebaseDBManager.shared.deleteNoteArrayFromTrash(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    
    func restoreNoteArrayFromTrash(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        FirebaseDBManager.shared.restoreNoteArrayFromTrash(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    
    func setReminderArray(notes:[NoteModel],reminderDate:String,reminderTime:String,completion:@escaping (Bool,String)->Void){
        FirebaseDBManager.shared.setReminderArray(notes: notes, reminderDate: reminderDate, reminderTime: reminderTime) { (result, message) in
            completion(result, message)
        }
    }
    
    func changeColorOfNoteArray(notes:[NoteModel],color:String,completion:@escaping (Bool,String)->Void){
        FirebaseDBManager.shared.changeColorOfNoteArray(notes: notes, color: color) { (result, message) in
            completion(result, message)
        }
    }
    
    func archiveNoteArray(notes:[NoteModel],completion:@escaping(Bool,String)->Void){
        FirebaseDBManager.shared.archiveNoteArray(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    func unarchiveNoteArray(notes:[NoteModel],completion:@escaping(Bool,String)->Void){
        FirebaseDBManager.shared.unarchiveNoteArray(notes: notes) { (result, message) in
            completion(result, message)
        }
    }

}
