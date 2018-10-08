import Foundation
import CoreData

class UserDBManager{
    
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
    
    static func updatePassword(email:String,password:String,completion:(Bool)->Void){
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        do{
            let users = try self.context.fetch(fetchRequest)
            for user in users{
                if user.email == email.lowercased(){
                    user.password = password
                    completion(true)
                    return
                }
            }
            completion(false)
            saveContext()
        }catch{
            completion(false)
            print("Enable to fetch the data.")
        }
    }
    
    static func ragisterUserModel(user:UserModel,completion:(Bool)->Void){
        self.isUserExist(email: user.emailId) { (result) in
            if result == false{
                completion(true)
                let dBUser = User(context: UserDBManager.context)
                dBUser.username = user.username
                dBUser.lastname = user.lastname
                dBUser.moble_number = user.mobileNo
                dBUser.email = user.emailId.lowercased()
                dBUser.password = user.password
                dBUser.userid = user.userId
                saveContext()
            }else{
                completion(false)
            }
        }
    }
    
    static func loginUser(email:String,password:String,completion:(Bool,String,User?)->Void){
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ && password == %@", email.lowercased(),password)
        do{
            let users = try self.context.fetch(fetchRequest) as [User]
            if let user = users.first{
                completion(true,"User found",user)
            }else{
                completion(false,"User not exist",nil)
            }
        }catch let error as NSError{
            completion(false, error.localizedDescription, nil)
        }
    }
    
    static func isUserExist(email:String,completion:(Bool)->Void){
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email.lowercased())
        do{
            let users = try self.context.fetch(fetchRequest) as [User]
            if users.first == nil{
                completion(false)
            }else{
                completion(true)
            }
        }catch{
            print(error)
        }
    }
 
}
