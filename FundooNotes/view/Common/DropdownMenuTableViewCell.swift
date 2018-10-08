import UIKit

class DropdownMenuTableViewCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = nil
    }
}
