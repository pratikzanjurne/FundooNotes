import Foundation
@objc protocol PNavigationItemDelegate{
        func onClickPin()
        func onClickDelete()
        func onClickColor()
        func onClickReminder()
        func onClickOption()
        func onClickBack()
        func onClickRestore()
}

class NavigationHelper{
    
    static func setNavigationItem(target:UIViewController,delegate:PNavigationItemDelegate?,option : Constant.NoteOfType,completion:(UINavigationItem)->Void){
        let pinBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "pin"), style: .plain, target: target, action: #selector(delegate?.onClickPin))
        pinBtn.tintColor = UIColor.gray
        let reminderBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "remind"), style: .plain, target: target, action: #selector(delegate?.onClickReminder))
        reminderBtn.tintColor = UIColor.gray
        let colorBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "color_lens"), style: .plain, target: target, action: #selector(delegate?.onClickColor))
        colorBtn.tintColor = UIColor.gray
        let optionBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "vertical_menu"), style: .plain, target: target, action: #selector(delegate?.onClickOption))
        optionBtn.tintColor = UIColor.gray
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: target, action: #selector(delegate?.onClickBack))
        backBtn.tintColor = UIColor.gray
        let restoreBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "restore"), style: .plain, target: target, action: #selector(delegate?.onClickRestore))
        restoreBtn.tintColor = UIColor.gray
        let title = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        title.tintColor = UIColor.gray
        
        let navigationItem = UINavigationItem()
        switch option {
        case .deleted:
            navigationItem.rightBarButtonItems = [optionBtn,restoreBtn]
            navigationItem.leftBarButtonItems = [backBtn,title]
            completion(navigationItem)
            break
        case .note:
            navigationItem.rightBarButtonItems = [optionBtn,colorBtn,reminderBtn,pinBtn]
            navigationItem.leftBarButtonItems = [backBtn,title]
            completion(navigationItem)
            break
        case .reminder:
            navigationItem.rightBarButtonItems = [optionBtn,colorBtn,reminderBtn,pinBtn]
            navigationItem.leftBarButtonItems = [backBtn,title]
            completion(navigationItem)
            break
        case .archive:
            navigationItem.rightBarButtonItems = [optionBtn,colorBtn,reminderBtn,pinBtn]
            navigationItem.leftBarButtonItems = [backBtn,title]
            completion(navigationItem)
            break
        default:
            break
        }
        
    }
}
