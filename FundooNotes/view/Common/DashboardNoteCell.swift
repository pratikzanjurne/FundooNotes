import UIKit
import SDWebImage

class DashboardNoteCell:UICollectionViewCell{
    
    @IBOutlet var superView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scheduleImageView: UIImageView!
    @IBOutlet var noteTextLabel: UILabel!
    @IBOutlet var dateTextLabel: UILabel!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var pinImageConstraint: NSLayoutConstraint!
    @IBOutlet var reminderTextView:UIView!
    @IBOutlet var reminderTextViewHConstraint:NSLayoutConstraint!
    @IBOutlet var pinImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageViewHeightConstraint.constant = 0
        self.layer.backgroundColor = UIColor.white.cgColor
        self.noteTextLabel.sizeToFit()
        self.dateTextLabel.sizeToFit()
        self.scheduleImageView.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        self.reminderTextView.layer.cornerRadius = 2
        UIHelper.shared.setCornerRadius(view: reminderTextView, radius: 3.0)
        noteTextLabel.lineBreakMode = .byWordWrapping
        noteTextLabel.numberOfLines = 0
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.dateTextLabel.text = nil
        self.imageView.image = nil
        self.noteTextLabel.text = nil
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.imageViewHeightConstraint.constant = 0
    }
    
    func setData(note:NoteModel){
        if let imageUrl = note.imageUrl{
            let url = URL(string: imageUrl)
            self.imageView.sd_setImage(with: url, completed: { (image, error, imageCache, url) in
                if error == nil{
                    if let noteImage = image{
                        let newHeight = Helper.shared.getScaledHeight(imageWidth: noteImage.size.width, imageHeight: noteImage.size.height, scaleWidth: self.bounds.width)
                        self.imageViewHeightConstraint.constant = newHeight
                    }else{
                        print("Image not found")
                    }
                }else{
                    print(error?.localizedDescription)
                }

            })
        }
//        if let imageData = note.image{
//            if let noteImage = UIImage(data:imageData as Data){
//                let newHeight = Helper.shared.getScaledHeight(imageWidth: noteImage.size.width, imageHeight: noteImage.size.height, scaleWidth: self.bounds.width)
//                self.imageViewHeightConstraint.constant = newHeight
//                self.imageView.image = noteImage
//            }
//        }
        let titleString = "\(note.title) \n"
        let attributedString = NSMutableAttributedString(string: titleString, attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15)])
        attributedString.append(NSAttributedString(string: note.note, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        self.noteTextLabel.attributedText = attributedString
        if note.is_remidered{
            self.reminderTextViewHConstraint.constant = 18
            Helper.shared.compareDate(date: note.reminder_date!, time: note.reminder_time!, completion: { (dateString) in
                self.dateTextLabel.text = "\(dateString)"
            })
        }else{
            self.reminderTextViewHConstraint.constant = 0
        }
        dateTextLabel.sizeToFit()
        dateTextLabel.clipsToBounds = true
        dateTextLabel.layer.cornerRadius = 5
        self.layer.backgroundColor = UIColor(hexString: note.colour).cgColor
        if note.is_pinned{
            self.pinImageConstraint.constant = 18
            self.pinImage.backgroundColor = UIColor(hexString: note.colour)
        }else{
            self.pinImageConstraint.constant = 0
        }
    }
    
}

