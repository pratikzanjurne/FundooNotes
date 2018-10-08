import UIKit
protocol PColorOptionTblView{
    func onOptionSelected(_ option : Constant.TableViewOptions)
}

class ColourOptionTblView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var colourOptionTblView: UITableView!
    
    var height:CGFloat = 0
    var delegate:PColorOptionTblView?
    var array = ["Delete", "Make a copy","Send","Colabrator","Labels"]
    var imageArray = [#imageLiteral(resourceName: "delete"),#imageLiteral(resourceName: "file_copy"),#imageLiteral(resourceName: "send"),#imageLiteral(resourceName: "add_person"),#imageLiteral(resourceName: "label_black")]
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    func commitInit(){
        Bundle.main.loadNibNamed("ColourOptionTblVew", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        let cell = UINib(nibName: "ColourOptionTbleViewCell", bundle: nil)
        self.colourOptionTblView.register(cell, forCellReuseIdentifier: "ColourOptionTblViewCell")
        self.colourOptionTblView.delegate = self
        self.colourOptionTblView.dataSource = self
        self.height = colourOptionTblView.contentSize.height
    }
}

extension ColourOptionTblView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColourOptionTblViewCell") as! ColourOptionTblViewCell
        let imageView = UIImageView(frame: CGRect(x: 10, y: 9, width: 25, height: 25))
        imageView.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        imageView.image = imageArray[indexPath.row]
        let label = UILabel(frame: CGRect(x:  60, y: 0, width: 374, height: 44))
        label.textColor = UIColor(hexString: Constant.Color.colourReminderText)
        label.text = array[indexPath.row]
        cell.addSubview(imageView)
        cell.addSubview(label)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if array.count == 2{
            switch indexPath.row {
            case 0:
                self.delegate?.onOptionSelected(.delete)
                break
            default:
                self.delegate?.onOptionSelected(.restore)
                break
            }
        }else{
            switch indexPath.row{
            case 0 :
                self.delegate?.onOptionSelected(.delete)
                break
            default:
                self.delegate?.onOptionSelected(.Labels)
            }
        }
    }
}
