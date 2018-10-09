import Foundation

class LoginViewPresenter{
    var pLoginView:PLoginView?
    let presenterService:PresenterService
    
    init(pLoginView:PLoginView,presenterService:PresenterService) {
        self.pLoginView = pLoginView
        self.presenterService = presenterService
    }
    
    func loginUser(email:String,password:String){
        if presenterService.validateEmailPattern(email: email){
            self.pLoginView?.startLoading()
            presenterService.loginUser(email: email, password: password) { (response, message) in
                self.pLoginView?.stopLoading()
                if response{
                    self.pLoginView?.showDashboardViewController()
                }else{
                    self.pLoginView?.showAlert(message: message)
                }
            }
        }else {
            self.pLoginView?.showAlert(message: "Enter the valid email address.")
        }
    }
    
    func loginWithFacebook(email:String?,username:String?,imageUrl:String?){
        if let email = email{
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
        if let username = username{
            UserDefaults.standard.set(username, forKey: "username")

        }
        presenterService.logInWithFAcebook { (result) in
        }
        pLoginView?.showDashboardViewController()
    }
}
