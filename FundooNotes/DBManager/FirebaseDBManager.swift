import Foundation
import Firebase
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class FirebaseDBManager{
    static let shared = FirebaseDBManager()
    private let rootRef = Database.database().reference().child("users")
    private let storageRootRef = Storage.storage().reference()
    
    private init(){
        rootRef.keepSynced(true)
    }
    
    func createUser(userModel:UserModel,completion:@escaping (Bool)->Void){
        Auth.auth().createUser(withEmail: userModel.emailId, password: userModel.password) { (authResult, error) in
            if error == nil {
                guard let user = authResult?.user else{
                    completion(false)
                    return
                }
                let userRef = self.rootRef.child(user.uid)
                let userInfoRef = userRef.child("user_info")
                let userInfo = ["username":userModel.username,"lastname":userModel.lastname,"email":userModel.emailId,"password":userModel.password,"mobile_no":userModel.mobileNo]
                userInfoRef.setValue(userInfo)
                completion(true)
            }
        }
    }
    
    func logInWithFacebook(completion:@escaping(Bool)->Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let user = Auth.auth().currentUser else { return }
        let userRef = rootRef.child(uid)
        let userInfoRef = userRef.child("user_info")
        let userInfo:[String:Any] = ["username":user.displayName,"email":user.email,"mobile_no":user.phoneNumber,"photoUrl":"\(String(describing: user.photoURL))"]
        userInfoRef.setValue(userInfo)
        completion(true)
    }
    
    func loginUser(email:String,password:String,completion:@escaping (Bool,String)->Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error == nil{
                if let user = authResult?.user{
                    self.getCurrentUserInfo(userId: user.uid, completion: { (userInfo) in
                        UserDefaults.standard.set(userInfo.email, forKey: "userEmail")
                        UserDefaults.standard.set(userInfo.username, forKey: "username")
                        completion(true, "User found")
                    })
                }else{
                    completion(false, "User not Found")
                }
            }else{
                completion(false, (error?.localizedDescription)!)
            }
        }
    }
    
    func getCurrentUserInfo(userId:String,completion:@escaping (UserInfoModel)->Void){
        let userRef = self.rootRef.child(userId)
        let userInfoRef = userRef.child("user_info")
        userInfoRef.observe(DataEventType.value, with: {(snapshot) in
            if let userInfo = snapshot.value as? [String:Any]{
                guard let firstname = userInfo["username"] as? String else { return }
                guard let lastname = userInfo["lastname"] as? String else { return }
                guard let email = userInfo["email"] as? String else {
                    return
                }
                let username = "\(firstname) \(lastname)"
                let userInfoModel = UserInfoModel(username: username, email: email)
                completion(userInfoModel)
            }
        })
    }

    func createNote(note:NoteModel){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        let noteRef = userNotesRef.child(note.note_id)
        let noteInfo:[String:Any] = ["title":note.title,"note":note.note,"creadtedDate":note.creadted_date,"reminderDate":"\(note.reminder_date!) \(note.reminder_time!)","editedDate":note.edited_date,"isArchived":note.is_archived,"isDeleted":note.is_deleted,"isPinned":note.is_pinned,"isRemindered":note.is_remidered,"color":note.colour]
        noteRef.setValue(noteInfo)
        if let imageData = note.image as Data?{
            let stringUID = NSUUID().uuidString
            let imageRef = storageRootRef.child("noteImages").child("\(stringUID).png")
            imageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    print(error?.localizedDescription as Any)
                    return
                }
                imageRef.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error?.localizedDescription as Any)
                        return
                    }
                    if let imageURL = url?.absoluteString{
                        self.updateImageUrl(note: note, imageUrl: imageURL)
                    }
                })
            })
        }
    }
    
    func updateImageUrl(note:NoteModel,imageUrl:String){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(note.note_id){
                let noteRef = userNotesRef.child(note.note_id)
                let value:[String:Any] = ["image":imageUrl,"imageHeight":note.imageHeight!,"imageWidth":note.imageWidth!]
                noteRef.updateChildValues(value)
                return
            }
        }
    }
    
    func updateNote(note:NoteModel){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(note.note_id){
                let noteRef = userNotesRef.child(note.note_id)
                let value:[String:Any] = ["title":note.title,"note":note.note,"creadtedDate":note.creadted_date,"reminderDate":"\(note.reminder_date!) \(note.reminder_time!)","editedDate":note.edited_date,"isArchived":note.is_archived,"isDeleted":note.is_deleted,"isPinned":note.is_pinned,"isRemindered":note.is_remidered,"color":note.colour]
                noteRef.updateChildValues(value)
                if let imageData = note.image as Data?{
                    let stringUID = NSUUID().uuidString
                    let imageRef = self.storageRootRef.child("noteImages").child("\(stringUID).png")
                    imageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                        if error != nil{
                            print(error?.localizedDescription as Any)
                            return
                        }
                        imageRef.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print(error?.localizedDescription as Any)
                                return
                            }
                            if let imageURL = url?.absoluteString{
                                self.updateImageUrl(note: note, imageUrl: imageURL)
                            }
                        })
                    })
                }
                return
            }
            return
        }
    }
    func deleteNote(noteToDelete:NoteModel,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(noteToDelete.note_id){
                let noteRef = userNotesRef.child(noteToDelete.note_id)
                let value = ["isDeleted":true]
                noteRef.updateChildValues(value)
                completion(true,"Deleted")
                return
            }else{
                completion(false, "Note not found")
            }
        }
    }
    
    func deleteNoteFromTrash(noteToDelete:NoteModel,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNoteRef = rootRef.child(userId).child("notes")
        userNoteRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(noteToDelete.note_id){
                let noteRef = userNoteRef.child(noteToDelete.note_id)
                noteRef.removeValue()
                completion(true,"Deleted")
                return
            }else{
                completion(false, "Note note found")
            }
        }
    }
    
    func restoreNoteFromTrash(noteToRestore:NoteModel,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(noteToRestore.note_id){
                let noteRef = userNotesRef.child(noteToRestore.note_id)
                let value = ["isDeleted":false]
                noteRef.updateChildValues(value)
                completion(true,"Restored")
                return
            }else{
                completion(false, "Note not found")
            }
        }
    }
    
    func setReminderArray(notes:[NoteModel],reminderDate:String,reminderTime:String,completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.setReminder(note: note, reminderDate: reminderDate, reminderTime: reminderTime, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }
    
    func setReminder(note:NoteModel,reminderDate:String,reminderTime:String,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(note.note_id){
                let noteRef = userNotesRef.child(note.note_id)
                let value:[String:Any] = ["isRemindered":true,"reminderDate":"\(reminderDate) \(reminderTime)"]
                noteRef.updateChildValues(value)
                completion(true,"Reminder set")
                return
            }else{
                completion(false, "Note not found")
            }
        }
    }


    func pinNote(noteToPin:NoteModel,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(noteToPin.note_id){
                let noteRef = userNotesRef.child(noteToPin.note_id)
                let value = ["isPinned":true,"isArchived":false]
                noteRef.updateChildValues(value)
                completion(true,"Restored")
                return
            }else{
                completion(false, "Note not found")
            }
        }
    }
    
    func archiveNote(note:NoteModel,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(note.note_id){
                let noteRef = userNotesRef.child(note.note_id)
                let value = ["isPinned":false,"isArchived":true]
                noteRef.updateChildValues(value)
                completion(true,"Archived")
                return
            }else{
                completion(false, "Not able to archive")
            }
        }
    }
    
    func unarchiveNote(note:NoteModel,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(note.note_id){
                let noteRef = userNotesRef.child(note.note_id)
                let value = ["isPinned":false,"isArchived":false]
                noteRef.updateChildValues(value)
                completion(true,"Unarchived")
                return
            }else{
                completion(false, "Not able to unarchive")
            }
        }
    }
    
    func archiveNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.archiveNote(note: note, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }
    
    func unarchiveNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.unarchiveNote(note: note, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }


    func pinNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.pinNote(noteToPin: note, completion: { _,_ in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(true, "Done")
                }
            })
        }
    }
    
    func deleteNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.deleteNote(noteToDelete: note, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }
    
    func deleteNoteArrayFromTrash(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.deleteNoteFromTrash(noteToDelete: note, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }
    
    func restoreNoteArrayFromTrash(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.restoreNoteFromTrash(noteToRestore: note, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }
    
    func changeColorOfNoteArray(notes:[NoteModel],color:String,completion:@escaping (Bool,String)->Void){
        for note in notes{
            self.changeColorOfNote(note: note, color: color, completion: { (result, message) in
                if note.note_id == notes[notes.count-1].note_id{
                    completion(result, message)
                }
            })
        }
    }
    
    func changeColorOfNote(note:NoteModel,color:String,completion:@escaping (Bool,String)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(note.note_id){
                let noteRef = userNotesRef.child(note.note_id)
                let value = ["color":color]
                noteRef.updateChildValues(value)
                completion(true, "Color Changed.")
                return
            }else{
                completion(false,"Something went wrong.")
            }
        }
    }
    
    func getNotes(completion:@escaping ([NoteModel])->Void){
        var notes = [NoteModel]()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = rootRef.child(userId).child("notes")
         userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let noteObjects  = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for noteObject in noteObjects{
                guard let note = noteObject.value as? [String:Any] else { return }
                let noteId = noteObject.key
                let color = note["color"] as! String
                let createdDate = note["creadtedDate"] as! String
                let editedDate = note["editedDate"] as! String
                let isArchived = note["isArchived"] as! Bool
                let isDeleted = note["isDeleted"] as! Bool
                let isPinned = note["isPinned"] as! Bool
                let isRemindered = note["isRemindered"] as! Bool
                let noteDisc = note["note"] as! String
                let reminderDateNTime = note["reminderDate"] as! String
                let title = note["title"] as! String
                var reminderDate:String = ""
                var reminderTime:String = ""
                if isRemindered{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy h:mm a"
                    let date = formatter.date(from: reminderDateNTime)
                    formatter.dateFormat = "MMM d, yyyy"
                    reminderDate = formatter.string(from: date!)
                    formatter.dateFormat = "h:mm a"
                    reminderTime = formatter.string(from: date!)
                }
                if isDeleted == false{
                    if let noteImageURL = note["image"] as? String{
                        let imageHeight = note["imageHeight"] as? CGFloat
                        let imageWidth = note["imageWidth"] as? CGFloat
                        notes.append(NoteModel(title: title, note: noteDisc, image: nil, is_archived: isArchived, is_remidered: isRemindered, is_deleted: isDeleted, creadted_date: createdDate, colour: color, note_id: noteId, is_pinned: isPinned, reminder_date: reminderDate, reminder_time: reminderTime, userId: userId, edited_date: editedDate, imageUrl: noteImageURL, imageHeight: imageHeight, imageWidth: imageWidth))
                    }else{
                        notes.append(NoteModel(title: title, note: noteDisc, image: nil, is_archived: isArchived, is_remidered: isRemindered, is_deleted: isDeleted, creadted_date: createdDate, colour: color, note_id: noteId, is_pinned: isPinned, reminder_date: reminderDate, reminder_time: reminderTime, userId: userId, edited_date: editedDate, imageUrl: nil, imageHeight: nil, imageWidth: nil))
                    }
                }
            }
            completion(notes)
        }
    }
    
    func getDeletedNotes(completion:@escaping ([NoteModel])->Void){
        var notes = [NoteModel]()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = rootRef.child(userId).child("notes")
         userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let noteObjects  = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for noteObject in noteObjects{
                guard let note = noteObject.value as? [String:Any] else { return }
                let noteId = noteObject.key
                let color = note["color"] as! String
                let createdDate = note["creadtedDate"] as! String
                let editedDate = note["editedDate"] as! String
                let isArchived = note["isArchived"] as! Bool
                let isDeleted = note["isDeleted"] as! Bool
                let isPinned = note["isPinned"] as! Bool
                let isRemindered = note["isRemindered"] as! Bool
                let noteDisc = note["note"] as! String
                let reminderDateNTime = note["reminderDate"] as! String
                let title = note["title"] as! String
                var reminderDate:String = ""
                var reminderTime:String = ""
                if isRemindered{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy h:mm a"
                    let date = formatter.date(from: reminderDateNTime)
                    formatter.dateFormat = "MMM d, yyyy"
                    reminderDate = formatter.string(from: date!)
                    formatter.dateFormat = "h:mm a"
                    reminderTime = formatter.string(from: date!)
                }
                if isDeleted{
                    if let noteImageURL = note["image"] as? String{
                        let imageHeight = note["imageHeight"] as? CGFloat
                        let imageWidth = note["imageWidth"] as? CGFloat
                        notes.append(NoteModel(title: title, note: noteDisc, image: nil, is_archived: isArchived, is_remidered: isRemindered, is_deleted: isDeleted, creadted_date: createdDate, colour: color, note_id: noteId, is_pinned: isPinned, reminder_date: reminderDate, reminder_time: reminderTime, userId: userId, edited_date: editedDate, imageUrl: noteImageURL, imageHeight: imageHeight, imageWidth: imageWidth))
                    }else{
                        notes.append(NoteModel(title: title, note: noteDisc, image: nil, is_archived: isArchived, is_remidered: isRemindered, is_deleted: isDeleted, creadted_date: createdDate, colour: color, note_id: noteId, is_pinned: isPinned, reminder_date: reminderDate, reminder_time: reminderTime, userId: userId, edited_date: editedDate, imageUrl: nil, imageHeight: nil, imageWidth: nil))
                    }
                }
            }
            completion(notes)
        }

    }
    
    func getNotesOfType(_ type:Constant.NoteOfType,completion:@escaping ([NoteModel])->Void){

        switch type {
            case .note:
                var dBNotes = [NoteModel]()
                self.getNotes { (notes) in
                    dBNotes = notes
                    let notes = dBNotes.filter({ (note) -> Bool in
                        return note.is_deleted != true && note.is_archived != true
                    })
                    completion(notes)
                }
            case .archive:
                var dBNotes = [NoteModel]()
                self.getNotes { (notes) in
                    dBNotes = notes
                    let notes = dBNotes.filter({ (note) -> Bool in
                        return note.is_deleted != true && note.is_archived == true
                    })
                    completion(notes)
                }
            case .reminder:
                var dBNotes = [NoteModel]()
                self.getNotes { (notes) in
                    dBNotes = notes
                    let notes = dBNotes.filter({ (note) -> Bool in
                        return note.is_deleted != true && note.is_remidered == true
                    })
                    completion(notes)
                }
            case .deleted:
                getDeletedNotes(completion: { (notes) in
                    completion(notes)
                })
                break
            default:
                break
        }
    }
    
    func searchNote(noteId:String,completion:@escaping (NoteModel)->Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotesRef = self.rootRef.child(userId).child("notes")
        let noteRef = userNotesRef.child(noteId)
        userNotesRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let note = snapshot.value as? [String:Any] else { return }
            let noteId = noteId
            let color = note["color"] as! String
            let createdDate = note["creadtedDate"] as! String
            let editedDate = note["editedDate"] as! String
            let isArchived = note["isArchived"] as! Bool
            let isDeleted = note["isDeleted"] as! Bool
            let isPinned = note["isPinned"] as! Bool
            let isRemindered = note["isRemindered"] as! Bool
            let noteDisc = note["note"] as! String
            let reminderDateNTime = note["reminderDate"] as! String
            let title = note["title"] as! String
            var reminderDate:String = ""
            var reminderTime:String = ""
            if isRemindered{
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy h:mm a"
                let date = formatter.date(from: reminderDateNTime)
                formatter.dateFormat = "MMM d, yyyy"
                reminderDate = formatter.string(from: date!)
                formatter.dateFormat = "h:mm a"
                reminderTime = formatter.string(from: date!)
            }
            if let noteImageURL = note["image"] as? String{
                let imageHeight = note["imageHeight"] as? CGFloat
                let imageWidth = note["imageWidth"] as? CGFloat
                let noteModel = NoteModel(title: title, note: noteDisc, image: nil, is_archived: isArchived, is_remidered: isRemindered, is_deleted: isDeleted, creadted_date: createdDate, colour: color, note_id: noteId, is_pinned: isPinned, reminder_date: reminderDate, reminder_time: reminderTime, userId: userId, edited_date: editedDate, imageUrl: noteImageURL, imageHeight: imageHeight, imageWidth: imageWidth)
                completion(noteModel)
            }else{
                let noteModel = NoteModel(title: title, note: noteDisc, image: nil, is_archived: isArchived, is_remidered: isRemindered, is_deleted: isDeleted, creadted_date: createdDate, colour: color, note_id: noteId, is_pinned: isPinned, reminder_date: reminderDate, reminder_time: reminderTime, userId: userId, edited_date: editedDate, imageUrl: nil, imageHeight: nil, imageWidth: nil)
                completion(noteModel)
            }
        }
    }
    
    func signOutUser(){
        do{
            try Auth.auth().signOut()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func updatePassword(email:String,completion:@escaping (Bool)->Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil{
                completion(true)
            }
            else{
                completion(false)
            }
        }
    }
}
