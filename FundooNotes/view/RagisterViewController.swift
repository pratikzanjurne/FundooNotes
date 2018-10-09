import UIKit



protocol PRagisterView {
    func showAlert(title:String,message:String)
    func takeUserData()->UserModel
    func checkEmailField()->Bool
    func presentMainView()
}

class RagisterViewController: BaseViewController,PRagisterView {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var emailID: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var createAccBtn: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var presenter:RagisterPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialseView()
    }
    
    override func initialseView() {
        presenter = RagisterPresenter(pRagisterView: self, presenterService: PresenterService())
        self.activityIndicator.isHidden = true
        createAccBtn.layer.cornerRadius = 15
    }
    
    @IBAction func createAcc(_ sender: Any) {
        presenter?.createAccount()
    }
    @IBAction func onPressedAlredyhavAcc(_ sender: Any) {
        presenter?.presentMainView()
    }
    
    func takeUserData()->UserModel{
        let userId = UUID().uuidString.lowercased()
        let user = UserModel(username: name.text!, lastname: lastName.text!, mobileNo: phoneNumber.text!, emailId: emailID.text!, password: password.text!, userId: userId)
        return user
    }
    
    func showAlert(title:String,message: String) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            if title == "Account created"{
                self.presenter?.presentMainView()
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func checkEmailField()->Bool{
        if !((emailID.text?.isEmpty)!){
            return true
        }
        return false
    }
    
    func presentMainView() {
        self.dismiss(animated: true, completion: nil)
    }
}
