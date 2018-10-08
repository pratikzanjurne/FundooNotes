import Foundation
import CoreData
import UIKit

class PresenterService{
    
    func fetchData()->[User]{
        var data  = [User]()
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        do{
            let users = try UserDBManager.context.fetch(fetchRequest)
            data = users
        }catch{
            print("Enable to fetch the data.")
        }
        return data
    }
        
    func validateMobNo(mobileNo: String) -> Bool{
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: mobileNo)
        return result
    }
    
    func validateEmailPattern(email:String) ->Bool{
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    func createUserAcc(user:UserModel,completion:@escaping (Bool)->Void) {
//        UserDBManager.ragisterUserModel(user: user) { (status) in
//            completion(status)
//        }
        FirebaseDBManager.shared.createUser(userModel: user) { (status) in
            completion(status)
        }
    }
    
    func validateDataForPassword(email:String,mobNo:String)->Bool{
        let users = fetchData()
        var f = 0
        for user in users{
            if user.email == email && user.moble_number == mobNo{
                f = f + 1
            }
        }
        if f != 0{
            return true
        }
        return false
    }
    
    func updatePassword(email:String,password:String,completion:(Bool)->Void){
        UserDBManager.updatePassword(email: email, password: password,completion:{(status) in
            completion(status)
        })
    }
    func loginUser(email:String,password:String,completion:@escaping (Bool,String)->Void) {
//        UserDBManager.loginUser(email: email, password: password) { (response, message, user) in
//            completion(response, message, user)
//        }
        FirebaseDBManager.shared.loginUser(email: email, password: password) { (result, message) in
            completion(result, message)
        }
    }
    
    func isUserExist(email:String,completion:(Bool)->Void){
        UserDBManager.isUserExist(email: email) { (result) in
            completion(result)
        }
    }

}
