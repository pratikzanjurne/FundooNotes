import UIKit

class OptionCell: UITableViewCell {

    @IBOutlet var optionLabel: UILabel!
    
    func optionLabel(label:String){
        self.optionLabel.text = label
    }
    

}
