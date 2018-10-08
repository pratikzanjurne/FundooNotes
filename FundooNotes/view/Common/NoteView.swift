import UIKit

class NoteView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleHeightContraint: NSLayoutConstraint!
    @IBOutlet var imageViewHeightC: NSLayoutConstraint!
    @IBOutlet var noteHeightConstraint: NSLayoutConstraint!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var scheduleImageView:UIImageView!
    @IBOutlet var reminderTextViewHC:NSLayoutConstraint!
    @IBOutlet var reminderTextView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    private func commitInit(){
        Bundle.main.loadNibNamed("NoteView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        self.scheduleImageView.tintColor = UIColor(hexString: Constant.Color.colourReminderText)
        UIHelper.shared.setCornerRadius(view: reminderTextView, radius: 3.0)
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
}
