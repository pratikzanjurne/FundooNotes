import Foundation
import UIKit
import CoreData

protocol PresenterDelegate:NSObjectProtocol {
    func setUserInfo(user:[UserLoginData])
}

class MainPresenter{
    private let presenterService:PresenterService
    var persenterDelegate:PresenterDelegate?
    init(presenterService:PresenterService) {
        self.presenterService = presenterService
    }
    func attachDelegate(presenter:PresenterDelegate){
        self.persenterDelegate = presenter
    }
    
    func detachDelegate(){
        self.persenterDelegate = nil
    }
    
    func getPeolpleLoginData(){
        let data = presenterService.fetchData()
        var users = [UserLoginData]()
        for person in data{
            let personinfo = UserLoginData(username: person.name!, password: person.password!)
            users.append(personinfo)
        }
        self.persenterDelegate?.setUserInfo(user: users)
    }
    func getPeopleAllData()->[Person]{
        let data = presenterService.fetchData()
        return data
    }
    
    func saveData(){
        PersistanceService.saveContext()
        
    }

}
