import UIKit
import SDWebImage

protocol PSideMenuView{
}
protocol PShowNotes{
    func showNotes(_ option: Constant.NoteOfType ,colour:String,viewTitle:String)
}
protocol PHideSideMenu{
    func toggleMenu()
    func showSignOutAlert()
}

class SideMenuTableViewController: UITableViewController,PSideMenuView {


    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var notesCell: UITableViewCell!
    @IBOutlet var archiveCell: UITableViewCell!
    @IBOutlet var deletedCell: UITableViewCell!
    @IBOutlet var remainderCell: UITableViewCell!
    @IBOutlet var signOutCell: UITableViewCell!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userIdlabel: UILabel!
    let menu = ["Notes","Archive","Deleted","Remainder"," Sign Out",""]
    var presenter:SideMenuPresenter?
    static var showNotesDelegate:PShowNotes?
    static var sideMenuDelegate:PHideSideMenu?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseView()
    }
    func initialiseView(){
        presenter = SideMenuPresenter(pSideMenuView: self, persenterService: DashboardPresenterService())
        self.userImageView.backgroundColor = UIColor.white
        if let imageUrlString = UserDefaults.standard.object(forKey: "imageUrl") as? String{
            let url = URL(string: imageUrlString)
            self.userImageView.sd_setImage(with: url, completed: { (image, error, cachetype, url) in
            })
        }
        self.userNameLabel.text = (UserDefaults.standard.object(forKey: "username") as? String)
        self.userEmailLabel.text = UserDefaults.standard.object(forKey: "userEmail") as? String
        notesCell.textLabel?.text = menu[0]
        notesCell.imageView?.image = #imageLiteral(resourceName: "note")
        notesCell.imageView?.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        archiveCell.textLabel?.text = menu[1]
        archiveCell.imageView?.image = UIImage(named: Constant.Image.archive)
        archiveCell.imageView?.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        deletedCell.textLabel?.text = menu[2]
        deletedCell.imageView?.image = UIImage(named: Constant.Image.deleted)
        deletedCell.imageView?.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        remainderCell.textLabel?.text = menu[3]
        remainderCell.imageView?.image = UIImage(named: Constant.Image.reminder)
        remainderCell.imageView?.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        signOutCell.textLabel?.text = menu[4]
        signOutCell.imageView?.image = #imageLiteral(resourceName: "log_out")
        signOutCell.imageView?.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        UIHelper.shared.setCornerRadius(view: self.userImageView, radius: userImageView.bounds.width/2)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
            case 0:
                SideMenuTableViewController.sideMenuDelegate?.toggleMenu()
                SideMenuTableViewController.showNotesDelegate?.showNotes(.note, colour: Constant.Color.colourOrange, viewTitle: Constant.DashboardViewTitle.noteView)
                break;
            case 1:
               SideMenuTableViewController.sideMenuDelegate?.toggleMenu()
               SideMenuTableViewController.showNotesDelegate?.showNotes(.archive, colour: Constant.Color.colourForFilterOn, viewTitle: Constant.DashboardViewTitle.archivedView)
                break;
            case 2:
                SideMenuTableViewController.sideMenuDelegate?.toggleMenu()
                SideMenuTableViewController.showNotesDelegate?.showNotes(.deleted, colour: Constant.Color.colorForDeleted, viewTitle: Constant.DashboardViewTitle.deletedView)
                break;
            case 3:
               SideMenuTableViewController.sideMenuDelegate?.toggleMenu()
               SideMenuTableViewController.showNotesDelegate?.showNotes(.reminder, colour: Constant.Color.colourForFilterOn, viewTitle: Constant.DashboardViewTitle.reminderView)
                break;
            case 4:
                SideMenuTableViewController.sideMenuDelegate?.toggleMenu()
                SideMenuTableViewController.sideMenuDelegate?.showSignOutAlert()
                break;
            default:
                break
        }
    }
}
