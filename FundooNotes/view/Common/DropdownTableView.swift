
import UIKit
protocol PDropdownMenu{
    func didSelectCell(indexPath:Int)
}


class DropdownTableView: UIView {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var containerView: UIView!
    
    var array = ["Archive","Delete","Make A Copy"]
    var delegate:PDropdownMenu?
    
    var height:CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    func commitInit(){
        Bundle.main.loadNibNamed("DropdownTableView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        let cell = UINib(nibName: "DropdownMenuTableViewCell", bundle: nil)
        self.tableView.register(cell, forCellReuseIdentifier: "DropdownMenuTableViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.height = tableView.contentSize.height
    }
}

extension DropdownTableView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownMenuTableViewCell") as! DropdownMenuTableViewCell
        cell.label.text = array[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCell(indexPath: indexPath.row)
        self.tableView.reloadData()
    }
}
