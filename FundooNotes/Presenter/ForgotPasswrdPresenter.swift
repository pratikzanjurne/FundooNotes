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
        if data?.emailId != "" && data?.newPassword != "" && data?.mobNo != "" && data?.confirmPassword != ""{
            return true
        }else{
            pForgotPassword?.showAlert(title: "Can't change Password", message: "Enter all the fields Correctly.")
        }
        return false
    }
    
    func validateData(email:String,mobNo:String)->Bool{
        let validation = presenterService?.validateDataForPassword(email: email, mobNo: mobNo)
        if validation == true{
            return true
        }else{
            pForgotPassword?.showAlert(title: "Can't change Password", message: "The entered emaid Id and password doesn't exist.")
        }
        return false
    }
    
    func validatePasswords(newPassword:String,confirmedPassword:String)->Bool{
        if newPassword == confirmedPassword{
            return true
        }else{
            pForgotPassword?.showAlert(title: "Can't change Password", message: "Enter the same password in the both fields")
        }
        return false
    }
    
    func updatePassword(email:String,password:String){
        presenterService?.updatePassword(email: email, password: password,completion: {(status) in
            if status{
                pForgotPassword?.showAlert(title: "Password updated", message: "Your password is updated.")
            }
        })
    }
    
    func presentMainView(){
        pForgotPassword?.presentMainView()
    }
}
