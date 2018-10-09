import UIKit

protocol PForgotPassword {
    func takeUserData()->ForgotPasswordModel
    func showAlert(title:String,message:String)
    func presentMainView()
}

class ForgotPasswordViewController: BaseViewController,PForgotPassword {

    @IBOutlet var emailText: UITextField!
    @IBOutlet var saveBtn: UIButton!
    
    var presenter:ForgotPasswrdPresenter?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialseView()
    }
    
    override func initialseView() {
        presenter = ForgotPasswrdPresenter(pForgotPassword: self, presenterService: PresenterService())
        saveBtn.layer.cornerRadius = 15
    }

    @IBAction func saveBtnAction(_ sender: Any) {
        if presenter?.checkAllFields() == true{
                    presenter?.updatePassword(email: emailText.text!)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        presenter?.presentMainView()
    }
    func takeUserData()->ForgotPasswordModel{
        let userData = ForgotPasswordModel(emailId: emailText.text!)
        return userData
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            if title == "Password changed"{
                self.presenter?.presentMainView()
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func presentMainView() {
        self.dismiss(animated: true, completion: nil)
    }
}
