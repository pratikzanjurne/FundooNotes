import Foundation
import UIKit

class UIHelper {
    static let shared = UIHelper()
    private init(){
        
    }
    
    func postNotification(Name:String){
        NotificationCenter.default.post(name: NSNotification.Name(Name), object: nil)
    }
    
    func givePlaceholder(textView:UITextView,placeholder:String){
        if textView.text == ""{
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
        
    }
    func removePlaceholder(textview:UITextView,placeholder:String){
        if textview.text == placeholder{
            textview.text = ""
            textview.textColor = UIColor.black
        }
    }
    
    func setShadow(view:UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width:0,height: 0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false;
    }
    
    func setCornerRadius(view:UIView ,radius:CGFloat){
        view.layer.cornerRadius = radius
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.masksToBounds = true;

    }
    
    
    
}
//extension UIView {
//    
//    func withPadding(padding: UIEdgeInsets) -&gt; UIView {
//    let container = UIView()
//    container.addSubview(self)
//    snp_makeConstraints { make in
//    make.edges.equalTo(container).inset(padding)
//    }
//    return container
//    }
//}

