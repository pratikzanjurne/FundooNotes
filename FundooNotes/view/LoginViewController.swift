import UIKit
import CoreData
import FBSDKLoginKit
import Firebase
import FirebaseAuth

protocol PLoginView{
    func showAlert(message:String)
    func showDashboardViewController()
    func startLoading()
    func stopLoading()
}


class LoginViewController:BaseViewController,PLoginView {
    private var presenter:LoginViewPresenter?
    
    @IBOutlet var facebookBtn: UIButton!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var createAccBtn: UIButton!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var usernameID: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialseView()
        facebookBtn.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
    }
    
    override func initialseView() {
        self.activityIndicator.isHidden = true
        presenter = LoginViewPresenter(pLoginView: self, presenterService: PresenterService())
        if UserDefaults.standard.object(forKey: "userId") != nil{
            showDashboardViewController()
        }else{
            
        }
        facebookBtn.layer.borderColor = UIColor.blue.cgColor
        facebookBtn.layer.borderWidth = 2
        facebookBtn.layer.cornerRadius = 15
        createAccBtn.layer.cornerRadius = 15
        loginBtn.layer.cornerRadius = 15
    }
    @IBAction func loginAction(_ sender: Any) {
        if (usernameID.text?.isEmpty)! && (passwordText.text?.isEmpty)!{
            showAlert(message: "Enter email and password.")
        }else{
            presenter?.loginUser(email: usernameID.text!, password: passwordText.text!)
        }
    }
 
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Can't Login", message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
           alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showDashboardViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DashboardContainerViewController") as! DashboardContainerViewController
        present(vc, animated: true) {
        }
    }
    func startLoading() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    @objc func loginButtonClicked() {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }else{
                    self.presenter?.loginWithFacebook(email: authResult?.user.email, username: authResult?.user.displayName, imageUrl: "\(String(describing: authResult?.user.photoURL))")
                }
            })
        }
    }
}
