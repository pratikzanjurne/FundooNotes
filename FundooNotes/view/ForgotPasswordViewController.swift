import UIKit

protocol PForgotPassword {
    func takeUserData()->ForgotPasswordModel
    func showAlert(title:String,message:String)
    func presentMainView()
}

class ForgotPasswordViewController: BaseViewController,PForgotPassword {

    @IBOutlet var emailText: UITextField!
    @IBOutlet var mobileNoText: UITextField!
    @IBOutlet var newPasswordText: UITextField!
    @IBOutlet var confirmPasswordText: UITextField!
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
            if presenter?.validateData(email:emailText.text!, mobNo: mobileNoText.text!) == true{
                if presenter?.validatePasswords(newPassword: newPasswordText.text!, confirmedPassword: confirmPasswordText.text!) == true{
                    presenter?.updatePassword(email: emailText.text!, password: newPasswordText.text!)
                }
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        presenter?.presentMainView()
    }
    func takeUserData()->ForgotPasswordModel{
        let userData = ForgotPasswordModel(emailId: emailText.text!, mobNo: mobileNoText.text!, newPassword: newPasswordText.text!, confirmPassword: confirmPasswordText.text!)
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "main")
        present(vc!, animated: true, completion: nil)
    }
}
