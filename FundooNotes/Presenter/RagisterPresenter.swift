import Foundation

class RagisterPresenter{
    
    let pRagesterView:PRagisterView?
    let presenterService:PresenterService?

    init(pRagisterView:PRagisterView,presenterService:PresenterService) {
        self.pRagesterView = pRagisterView
        self.presenterService = presenterService
    }
    func createAccount(){
        let user = takeUserViewData()
        if presenterService?.validateMobNo(mobileNo: user.mobileNo) == true{
            if (pRagesterView?.checkEmailField())!{
                if (presenterService?.validateEmailPattern(email: user.emailId))!{
                    presenterService?.createUserAcc(user: user, completion: { (status) in
                        if status{
                            self.pRagesterView?.showAlert(title: "Account created", message: "Account created with the name \(user.username)")
                        }else{
                            self.pRagesterView?.showAlert(title: "Can't create account", message: "User with the entered email address already exist.")
                        }
                    })
                }else{
                    pRagesterView?.showAlert(title: "Can't create account", message: "Enter the valid email address.")
                }
            }else{
                pRagesterView?.showAlert(title: "Can't create Account", message: "Enter Email-id")
            }
        }else{
            pRagesterView?.showAlert(title: "Can't Create account", message: "Enter the valid mobile number.")
        }
    }
    
    func takeUserViewData()->UserModel{
        return (pRagesterView?.takeUserData())!
    }
    
    func presentMainView(){
        pRagesterView?.presentMainView()
    }
    
}
