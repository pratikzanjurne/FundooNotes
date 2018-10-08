import Foundation
import UIKit
import CoreData

class NoteDBManager{
    
    private init(){
    }
    
    static var context:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LoginPage")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func saveNote(note:NoteModel){
        let DBNote = Note(context:NoteDBManager.context)
        if let noteImage = note.image{
//            if let image = UIImagePNGRepresentation(noteImage) as NSData?
//            {
                DBNote.image = noteImage
//            }
        }
        DBNote.colour = note.colour
        DBNote.creadted_date = note.creadted_date
        DBNote.is_archived = note.is_archived
        DBNote.is_deleted = note.is_deleted
        DBNote.note = note.note
        DBNote.note_id = note.note_id
        DBNote.title = note.title
        DBNote.is_pinned = note.is_pinned
        DBNote.is_remidered = note.is_remidered
        DBNote.reminder_date = note.reminder_date
        DBNote.reminder_time = note.reminder_time
        DBNote.userid = note.userId
        DBNote.edited_date = note.edited_date
        saveContext()
        print("Saved1")
    }
    static func getNotes(completion:([NoteModel])->Void){
        var notes = [NoteModel]()
        do{
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            print(userId)
            let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
            let dBNotes = try self.context.fetch(fetchRequest)
            for note in dBNotes{
                if note.is_deleted != true && note.userid == userId{
                    if let image = note.image{
//                        let noteImage = UIImage(data: image as Data)
                        notes.append(NoteModel(title: note.title!, note: note.note!, image: image, is_archived: note.is_archived, is_remidered: note.is_remidered, is_deleted: note.is_deleted, creadted_date: note.creadted_date!, colour: note.colour!, note_id: note.note_id!, is_pinned: note.is_pinned, reminder_date: note.reminder_date, reminder_time: note.reminder_time, userId: note.userid!, edited_date: note.edited_date!, imageUrl: nil, imageHeight: nil, imageWidth: nil))
                        
                        
                    }else{
                        notes.append(NoteModel(title: note.title!, note: note.note!, image: nil, is_archived: note.is_archived, is_remidered: note.is_remidered, is_deleted: note.is_deleted, creadted_date: note.creadted_date!, colour: note.colour!, note_id: note.note_id!, is_pinned: note.is_pinned, reminder_date: note.reminder_date, reminder_time: note.reminder_time, userId: note.userid!, edited_date: note.edited_date!, imageUrl: nil, imageHeight: nil, imageWidth: nil))
                    }
                    
                }
                print("returned")
                completion(notes)
                }
        }catch{
            
        }
    }
    
   static  func deleteNote(noteToDelete:NoteModel,completion:(Bool,String)->Void){
        do{
            let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "note_id = %@", noteToDelete.note_id)
            let dBNotes = try self.context.fetch(fetchRequest)
            if let note = dBNotes.first{
                note.is_deleted  = true
                saveContext()
                completion(true, "Deleted")
            }else{
                completion(false, "Note not found")
                return
            }
        }catch{
            completion(false, "Not able to delete the note. ")
        }
    }
    static  func deleteNoteT(noteToDelete:NoteModel,completion:(Bool,String)->Void){
        do{
            let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "note_id = %@", noteToDelete.note_id)
            let dBNotes = try self.context.fetch(fetchRequest)
            if let note = dBNotes.first{
                context.delete(note)
                saveContext()
                completion(true, "Deleted")
            }else{
                completion(false, "Note not found")
                return
            }
        }catch{
            completion(false, "Not able to delete the note. ")
        }
    }

    
    static func getDeletedNotes(completion:([NoteModel])->Void){
         var notes = [NoteModel]()
        do{
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
            let dBNotes = try self.context.fetch(fetchRequest)
            for note in dBNotes{
                if note.is_deleted && note.userid == userId{
                    if let image = note.image{
//                        let noteImage = UIImage(data: image as Data)
                        notes.append(NoteModel(title: note.title!, note: note.note!, image: image, is_archived: note.is_archived, is_remidered: note.is_remidered, is_deleted: note.is_deleted, creadted_date: note.creadted_date!, colour: note.colour!, note_id: note.note_id!, is_pinned: note.is_pinned, reminder_date: note.reminder_date, reminder_time: note.reminder_time, userId: note.userid!, edited_date: note.edited_date!, imageUrl: nil, imageHeight: nil, imageWidth: nil))
                        
                        
                    }else{
                        notes.append(NoteModel(title: note.title!, note: note.note!, image: nil, is_archived: note.is_archived, is_remidered: note.is_remidered, is_deleted: note.is_deleted, creadted_date: note.creadted_date!, colour: note.colour!, note_id: note.note_id!, is_pinned: note.is_pinned, reminder_date: note.reminder_date, reminder_time: note.reminder_time, userId: note.userid!, edited_date: note.edited_date!, imageUrl: nil, imageHeight: nil, imageWidth: nil))
                    }
                    
                }
                print("returned")
                completion(notes)
            }
        }catch{
            
        }
    }
    
    static func getNotesOfType(_ type:Constant.NoteOfType,completion:([NoteModel])->Void){
        do{
            var dBNotes = [NoteModel]()
            getNotes(completion: { (notes) in
                dBNotes = notes
            })
            switch type {
            case .note:
                let notes = dBNotes.filter({ (note) -> Bool in
                    return note.is_deleted != true && note.is_archived != true
                })
                completion(notes)
                break
            case .archive:
                let notes = dBNotes.filter({ (note) -> Bool in
                    return note.is_deleted != true && note.is_archived == true
                })
                completion(notes)
                break
            case .reminder:
                let notes = dBNotes.filter({ (note) -> Bool in
                    return note.is_deleted != true && note.is_remidered == true
                })
                completion(notes)
                break
            case .deleted:
                getDeletedNotes(completion: { (notes) in
                    completion(notes)
                })
//                let notes = dBNotes.filter({ (note) -> Bool in
//                    return note.is_deleted == true
//                })
                break
//            default:
//                break
            }

        }catch{
        }
    }
    
    static func restoreNote(note:NoteModel,completion:(Bool,String)->Void){
        do{
            let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "note_id = %@", note.note_id)
            let dBNotes = try self.context.fetch(fetchRequest)
            if let note = dBNotes.first{
                note.is_deleted = false
                saveContext()
                completion(true, "Restored")
            }else{
                completion(false, "Note not found")
                return
            }
        }catch{
            completion(false, "Not able to restore the note. ")
        }
    }
    
    func setReminder(){
        
    }
    
    static func pinNote(note:NoteModel,completion:(Bool,String)->Void){
        do{
            let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "note_id = %@", note.note_id)
            let dBNotes = try self.context.fetch(fetchRequest)
            if let note = dBNotes.first{
                note.is_pinned = true
                note.is_archived = false
                saveContext()
                completion(true,"Success")
            }else{
                completion(false,"Not able to find the note")
                return
            }
        }catch{
            completion(false,"Something went wrong try after some time.")
        }
    }
    
    static func pinNoteArray(notes:[NoteModel],completion:(Bool,String)->Void){
        for note in notes{
            pinNote(note: note, completion: { (result,message) in
                completion(result, message)
            })
        }
    }
}
