import UIKit
import MaterialControls

protocol PSetReminderView{
    func openPopUpView(_ option : Helper.reminderOptionSelected)
}

protocol PReminderDelegate{
    func setReminderData(date:String,time:String)
}

class SetReminderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PSetReminderView {
    
    
    @IBOutlet var tableViewOptions: UITableView!
    var presenter:SetReminderPresenter?
    var reminderDelegate:PReminderDelegate?
    var array = ["Date","Time","Repeat"]
    var subTitleArray = ["MMM d, yyyy","h:mm a","Repeat"]
    var selectedSection:Int = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SetReminderPresenter(pSetReminderView: self)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let todaysDate = formatter.string(from: date)
        subTitleArray[0] = todaysDate
        formatter.dateFormat = "h:mm a"
        let currentTime = formatter.string(from: date)
        subTitleArray[1] = currentTime
        tableViewOptions.dataSource = self
        tableViewOptions.delegate = self
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .default
    }

    @IBAction func onCancelPressed(_ sender: Any) {
        self.reminderDelegate?.setReminderData(date: "MMM d, yyyy",time: "h:mm a")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        self.reminderDelegate?.setReminderData(date: subTitleArray[0],time: subTitleArray[1])
        self.dismiss(animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetReminderCell", for: indexPath) as! SetReminderTableViewCell
        cell.titleLabel.text = array[indexPath.row]
        cell.subTitleLbl.text = subTitleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.row
        switch indexPath.row {
        case 0:
            presenter?.openPopUpView(.date)
            break
        case 1:
            presenter?.openPopUpView(.time)
            break
        case 2:
            presenter?.openPopUpView(.repeate)
            break
        default:
            break
        }
    }
    
    func openPopUpView(_ option: Helper.reminderOptionSelected) {
        switch option {
        case .date:
            let datePickerDialog = MDDatePickerDialog()
            datePickerDialog.delegate = self
            datePickerDialog.show()
            break
        case .time:
            let timePickerDialog = MDTimePickerDialog()
            timePickerDialog.delegate = self
            timePickerDialog.show()
            break
            
        case .repeate:
            break
        default:
            break
        }
    }

}

extension SetReminderViewController:MDDatePickerDialogDelegate,MDTimePickerDialogDelegate{
    func timePickerDialog(_ timePickerDialog: MDTimePickerDialog, didSelectHour hour: Int, andMinute minute: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = "\(hour):\(minute)"
        let date = formatter.date(from: timeString)
        formatter.dateFormat = "h:mm a"
        let time = formatter.string(from: date!)
        self.subTitleArray[selectedSection] = time
        print(subTitleArray[selectedSection])
        self.tableViewOptions.reloadData()
    }
    
    func datePickerDialogDidSelect(_ date: Date) {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMM d, yyyy"
        let dateInFormat = dateFormater.string(from: date)
        self.subTitleArray[selectedSection] = "\(dateInFormat)"
        print(subTitleArray[0])
        self.tableViewOptions.reloadData()
    }
}

