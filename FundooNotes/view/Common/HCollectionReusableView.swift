import UIKit

class HCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerLabel.numberOfLines = 0
        self.headerLabel.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.headerLabel.text = nil
    }
    func setHeader(text:String){
        self.headerLabel.text = text
    }
}
