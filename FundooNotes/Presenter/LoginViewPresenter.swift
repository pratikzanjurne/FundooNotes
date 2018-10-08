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
    
    func loginWithFacebook(email:String,username:String,imageUrl:String?){
                UserDefaults.standard.set(email, forKey: "userId")
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(imageUrl, forKey: "imageUrl")
                pLoginView?.showDashboardViewController()
    }
}
