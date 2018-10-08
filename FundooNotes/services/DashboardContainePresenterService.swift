import Foundation

class DashboardContainerPresenterService {
    func searchNote(noteId:String,completion:@escaping (NoteModel)->Void) {
        FirebaseDBManager.shared.searchNote(noteId: noteId) { (note) in
            completion(note)
        }
    }
}
