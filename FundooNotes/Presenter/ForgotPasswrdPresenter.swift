import Foundation

class ForgotPasswrdPresenter {
    
    let pForgotPassword:PForgotPassword?
    let presenterService:PresenterService?
    
    init(pForgotPassword:PForgotPassword,presenterService:PresenterService) {
        self.pForgotPassword = pForgotPassword
        self.presenterService = presenterService
    }
    
    func checkAllFields()->Bool{
        let data = pForgotPassword?.takeUserData()
        if data?.emailId != ""{
            return true
        }else{
            pForgotPassword?.showAlert(title: "Can't change Password", message: "Enter all the fields Correctly.")
        }
        return false
    }
    
    func updatePassword(email:String){
        presenterService?.updatePassword(email: email,completion: {(status) in
            if status{
                self.pForgotPassword?.showAlert(title: "Request sent", message: "The mail has been sent to you for further process.")
            }
        })
    }
    
    func presentMainView(){
        pForgotPassword?.presentMainView()
    }
}
