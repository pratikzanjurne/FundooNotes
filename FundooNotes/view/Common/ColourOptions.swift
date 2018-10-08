import Foundation
import UIKit
protocol PColorDelegate {
    func onChangeColor(color:String)
}
class ColourOptions:UIView{
    @IBOutlet var colourCollectionView: UICollectionView!
    @IBOutlet var containerView: UIView!
    let colourArray = ["#80d8ff","#cfd8dc","#d7ccc8","#f8bbd0","#82b1ff","#a7ffeb","#ccff90","#ffff8c","#fdd180","#fdd180","#fafafa"]
    var delegate:PColorDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    private func commitInit(){
        Bundle.main.loadNibNamed("ColourOptions", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        colourCollectionView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        let cell = UINib(nibName: "ColourCell", bundle: nil)
        self.colourCollectionView.register(cell, forCellWithReuseIdentifier: "colourCell")
        colourCollectionView.delegate = self
        colourCollectionView.dataSource = self
    }
}

extension ColourOptions:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colourArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colourCell", for: indexPath) as! ColourCell
        cell.backgroundColor = UIColor(hexString: colourArray[indexPath.item])
        UIHelper.shared.setShadow(view: cell)
        UIHelper.shared.setCornerRadius(view: cell,radius:cell.bounds.width/2)
        UIHelper.shared.setCornerRadius(view: cell.contentView,radius:24)
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor(hexString: Constant.Color.colourReminderText).cgColor
        cell.sizeThatFits(CGSize(width: 30, height: 30))
//        cell.layer.shadowRadius = 2.0
//        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.onChangeColor(color: colourArray[indexPath.item])
    }
    
    
    
}
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
