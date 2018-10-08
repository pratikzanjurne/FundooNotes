import UIKit

protocol PTakeNoteView{
    func getPhoto(_ option: Helper.photoOptionSelected)
    func updateView()
    func updateImageView()
    func showAlert(message: String)
    func presentDashboardView()
    func pinAction()
    func archiveAction()
    func setUpData(note:NoteModel)
    func toggleColorOptionTblView(constant:CGFloat)
}

class TakeNoteViewController: BaseViewController,UITextViewDelegate,PColorDelegate {

    @IBOutlet var noteView: NoteView!
    @IBOutlet var noteViewHeightC: NSLayoutConstraint!
    @IBOutlet var showOptionConstrains: NSLayoutConstraint!
    @IBOutlet var optionMenuHeight: NSLayoutConstraint!
    @IBOutlet var optionMenuTableView: UITableView!
    @IBOutlet var optionView: UIView!
    @IBOutlet var colourOptionView: ColourOptions!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var btnPin: UIBarButtonItem!
    @IBOutlet var btnArchive: UIBarButtonItem!
    @IBOutlet var editedDateBarBtnItm: UIBarButtonItem!
    @IBOutlet var colorOptionTblViewHeight: NSLayoutConstraint!
    @IBOutlet var colorOptionTblView: ColourOptionTblView!
    @IBOutlet var colorOptionTblConstraint: NSLayoutConstraint!
    
    var image:UIImage?
    var note:NoteModel?
    var isOptionsEnabled = false
    var isColourOptionEnabled = false
    var isPinned = false
    var isArchived = false
    var isRemindered = false
    var isDeleted = false
    let optionsMenu = ["Open Gallery","Open Camera"]
    var reminderArray = ["MMM d, yyyy","h:mm a"]
    var imageData:NSData?
    var presenter:TakeNotePresenter?
    var colorOptionTblContentHeight:CGFloat?
    var notificationId:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialseView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(reminderArray)
    }
    
    override func initialseView() {
        btnPin.target = self
        btnPin.action = #selector(onPinPressed)
        btnArchive.target = self
        btnArchive.action = #selector(onArchivePressed)
        noteView.reminderTextView.isUserInteractionEnabled = true
//        noteView.reminderLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onReminderLblPressed(sender:)))
        noteView.reminderTextView.addGestureRecognizer(tapGesture)
        presenter = TakeNotePresenter(pTakeNoteView: self, presenterService: TakeNotePresenterService())
        noteView.noteTextView.delegate = self
        noteView.titleTextView.delegate = self
        optionMenuTableView.delegate = self
        optionMenuTableView.dataSource = self
        optionMenuTableView.reloadData()
        optionMenuTableView.layoutIfNeeded()
        optionMenuHeight.constant = optionMenuTableView.contentSize.height
        showOptionConstrains.constant = -(optionMenuTableView.contentSize.height - 40)
//        colorOptionTblViewHeight.constant = colorOptionTblView.colourOptionTblView.contentSize.height
        UIHelper.shared.setShadow(view: optionView)
        UIHelper.shared.setShadow(view: colorOptionTblView)
        colourOptionView.delegate = self
        colorOptionTblView.delegate = self
        self.noteView.reminderTextViewHC.constant = 0
        if let recievedNote = note{
            presenter?.setUpData(note: recievedNote)
        }
    }
    
    func onChangeColor(color: String) {
        colorOptionTblConstraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        isColourOptionEnabled = false
        self.view.backgroundColor = UIColor(hexString: color)
        self.navigationBar.barTintColor = UIColor(hexString: color)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        presenter?.updateView()
    }

    
    
    @IBAction func backAction(_ sender: Any) {
        let dateFormater = DateFormatter()
        let date = Date()
        dateFormater.dateFormat = "MMM d, yyyy"
        let dateInFormat = dateFormater.string(from: date)
        let createdDate:String = dateInFormat
        let uuid = UUID().uuidString.lowercased()
        if let image = self.image{
            self.imageData = UIImagePNGRepresentation(image) as NSData?
        }
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        var note = NoteModel(title: noteView.titleTextView.text, note: noteView.noteTextView.text, image:imageData, is_archived: isArchived, is_remidered: isRemindered , is_deleted: isDeleted, creadted_date: createdDate , colour: (self.view.backgroundColor?.toHexString())! , note_id: uuid, is_pinned: isPinned, reminder_date: reminderArray[0], reminder_time: reminderArray[1], userId: userId, edited_date: dateInFormat, imageUrl: nil, imageHeight: image?.size.height, imageWidth: image?.size.width)
        if reminderArray[0] != "MMM d, yyyy" && reminderArray[1] != "HH:MM"{
            Helper.shared.setReminder(note: note, reminderDate: note.reminder_date!, reminderTime: note.reminder_time!, completion: { (result, message) in
                
            })
        }else{
            note.is_remidered = false
        }
        if (note.image != nil || note.note != "" || note.title != ""){
            if let receivedNote = self.note{
                note.creadted_date = receivedNote.creadted_date
                note.note_id = receivedNote.note_id
                presenter?.updateNote(note: note)
            }else{
                presenter?.saveNote(note: note)
            }
        }
        presenter?.presentDashboardView()
    }
    
    @IBAction func showColourOption(_ sender: Any) {
        if let note = self.note{
            if note.is_deleted{
                presenter?.toggleColorOptionTblView(constant: -88)
            }else{
                presenter?.toggleColorOptionTblView(constant: -268)
            }
        }else{
            presenter?.toggleColorOptionTblView(constant: -268)
        }
    }
    @IBAction func showOptions(_ sender: Any) {
        if isColourOptionEnabled{
            colorOptionTblConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isColourOptionEnabled = false
        }
        if isOptionsEnabled == false{
            colourOptionView.isHidden = true
            colorOptionTblView.isHidden = true
            showOptionConstrains.constant = 44
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isOptionsEnabled = true
        }else{
            showOptionConstrains.constant = -(optionMenuTableView.contentSize.height-44)
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isOptionsEnabled = false
        }
        
    }
    
    @IBAction func setReminder(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SetReminderView") as? SetReminderViewController else{
            return;
        }
        vc.reminderDelegate = self
        present(vc, animated: true, completion: nil)
    }
   @objc func onPinPressed() {
        presenter?.performPinAction()
    }
    
    @objc func onReminderLblPressed(sender: UITapGestureRecognizer){
            print("Label pressed")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SetReminderView") as? SetReminderViewController else{
            return;
        }
        vc.reminderDelegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc func onArchivePressed() {
        presenter?.performArchiveAction()
    }
}

extension TakeNoteViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsMenu.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OptionCell
        cell.optionLabel(label: optionsMenu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showOptionConstrains.constant = -(optionMenuTableView.contentSize.height-44)
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        isOptionsEnabled = false
        switch indexPath.row {
        case 0:
            presenter?.getPhoto(.gallary)
            break
        case 1:
            presenter?.getPhoto(.camera)
            break
        default:
            break
        }
    }
}

extension TakeNoteViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Cant find the image.")
        }
        image = selectedImage
        noteView.imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.width / selectedImage.getAspectRatio()))
        noteView.imageView.image = selectedImage
        noteView.imageViewHeightC.constant = noteView.imageView.frame.height
        presenter?.updateImageView()
        dismiss(animated: true, completion: nil)
    }
}


extension UIImage{
    func getAspectRatio()->CGFloat{
        return CGFloat(self.size.width/self.size.height)
    }
}


extension TakeNoteViewController:PTakeNoteView {
    func toggleColorOptionTblView(constant: CGFloat) {
        if isOptionsEnabled{
            showOptionConstrains.constant = -(optionMenuTableView.contentSize.height-44)
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isOptionsEnabled = false
        }
        if isColourOptionEnabled == false{
            colourOptionView.isHidden = false
            colorOptionTblView.isHidden = false
            colorOptionTblConstraint.constant = constant
            //                (colorOptionTblView.colourOptionTblView.contentSize.height + 40)
            print(colorOptionTblConstraint.constant)
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isColourOptionEnabled = true
        }else{
            colorOptionTblConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isColourOptionEnabled = false
        }
    }
    
    func getPhoto(_ option: Helper.photoOptionSelected){
        switch option{
        case .camera:
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
            break
        case .gallary:
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
            break
        }
    }
    
    
    func updateView(){
        var height:CGFloat = 55
        let titleHeight = noteView.titleTextView.frame.size.height
        let noteHeight = noteView.noteTextView.frame.size.height
        let imageViewHeight = noteView.imageView.frame.height
        
        if titleHeight >= 30{
            noteView.titleHeightContraint.constant = titleHeight
            height = height + titleHeight
        }else{
            noteView.titleHeightContraint.constant = 30
            height = height + 30
        }
        if noteHeight >= 30{
            height = height + noteHeight
            noteView.noteHeightConstraint.constant = noteHeight
        }else{
            height = height + 30
            noteView.noteHeightConstraint.constant = 30
        }
        if image != nil{
            height = height + imageViewHeight
        }else{
            noteView.imageViewHeightC.constant = 0
        }
        noteViewHeightC.constant = height
    }
    
    func updateImageView(){
        let imageViewHeight = noteView.imageViewHeightC.constant
        var height = noteViewHeightC.constant
        if image != nil{
            height = height + imageViewHeight
        }else{
            noteView.imageViewHeightC.constant = 0
        }
        noteViewHeightC.constant = height
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: nil , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            if message == "Deleted"{
                self.presenter?.presentDashboardView()
            }else if message == "Restored"{
                self.presenter?.presentDashboardView()
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func presentDashboardView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func pinAction(){
        if isPinned{
            btnPin.tintColor = UIColor(hexString: "#919191")
            isPinned = false
        }
        else{
            btnPin.tintColor = UIColor.blue
            isPinned = true
            isArchived = false
        }
    }
    func archiveAction(){
        if isArchived{
            btnArchive.image = UIImage(named: "archive")
            isArchived = false
        }else{
            btnArchive.image = UIImage(named: "unarchive")
            isArchived = true
            isPinned = false
        }
    }
    
    func setUpData(note:NoteModel){
        noteView.titleTextView.insertText(note.title)
        noteView.noteTextView.insertText(note.note)
        self.editedDateBarBtnItm.title = "Edited \(note.edited_date)"
        if note.is_remidered{
            self.noteView.reminderTextViewHC.constant = 18
            self.isRemindered = true
            self.reminderArray[0] = note.reminder_date!
            self.reminderArray[1] = note.reminder_time!
            Helper.shared.compareDate(date: note.reminder_date!, time: note.reminder_time!, completion: { (dateString) in
                noteView.reminderLabel.text = "\(dateString)"
            })
        }else{
            self.isRemindered = false
            self.noteView.reminderTextViewHC.constant = 0
        }
        self.view.backgroundColor = UIColor(hexString: note.colour)
        self.navigationBar.barTintColor = UIColor(hexString: note.colour)
        if let imageData = note.image{
            if let noteImage = UIImage(data:imageData as Data){
                self.image = noteImage
                noteView.imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.width / noteImage.getAspectRatio()))
                noteView.imageView.image = noteImage
                noteView.imageViewHeightC.constant = noteView.imageView.frame.height
                presenter?.updateImageView()
            }
        }
        if let imageUrl = note.imageUrl{
            guard let url = URL(string: imageUrl) else { return }
            noteView.imageView.sd_setImage(with: url, completed: { (image, error, imageCache, url) in
                if error == nil{
                    if let noteImage = image{
                        self.image = noteImage
                        self.noteView.imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.width / noteImage.getAspectRatio()))
                        self.noteView.imageView.image = noteImage
                        self.noteView.imageViewHeightC.constant = self.noteView.imageView.frame.height
                        self.presenter?.updateImageView()
                        
                    }
                }
            })
        }
        if note.is_pinned{
            btnPin.tintColor = UIColor.blue
            isPinned = true
        }
        if note.is_archived{
            btnArchive.image = UIImage(named: "unarchive")
            isArchived = true
        }
        if note.is_deleted{
            self.isDeleted = true
            noteView.noteTextView.isEditable = false
            noteView.titleTextView.isEditable = false
            self.colorOptionTblView.array = ["Delete permanantly","Restore"]
            self.colorOptionTblView.imageArray = [#imageLiteral(resourceName: "delete"),#imageLiteral(resourceName: "restore")]
            self.colorOptionTblView.colourOptionTblView.reloadData()
        }else{
            noteView.noteTextView.isEditable = true
            noteView.titleTextView.isEditable = true
        }

        presenter?.updateImageView()
        presenter?.updateView()
    }
}

extension TakeNoteViewController:PReminderDelegate{
    func setReminderData(date: String, time: String) {
        self.reminderArray[0] = date
        self.reminderArray[1] = time
        if date != "MMM d, yyyy" && time != "h:mm a"{
            self.isRemindered = true
            self.noteView.reminderTextViewHC.constant = 18
            Helper.shared.compareDate(date: date, time: time, completion: { (dateString) in
                noteView.reminderLabel.text = "\(dateString)"
            })
        }else{
            noteView.reminderLabel.text = nil
            self.noteView.reminderTextViewHC.constant = 0
        }
    }
}

extension TakeNoteViewController:PColorOptionTblView{
    func onOptionSelected(_ option: Constant.TableViewOptions) {
        switch  option {
        case .delete:
            colorOptionTblConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isColourOptionEnabled = false
            if let note = self.note{
                if note.is_deleted{
                    presenter?.deleteNoteFromTrash(noteToDelete: note, completion: { (status, message) in
                        self.showAlert(message: message)
                    })
                }else{
                    presenter?.deleteNote(noteToDelete: note, completion: { (status, message) in
                        self.showAlert(message: message)
                    })
                }
            }else{
                showAlert(message: "Note not Found.")
            }
            break
        case .restore:
            colorOptionTblConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isColourOptionEnabled = false
            if let note = self.note{
                if note.is_deleted{
                    presenter?.restoreNote(noteToRestore: note, completion: { (status, message) in
                        self.showAlert(message: message)
                    })
                }else{
                    showAlert(message: "Note not Found.")
                }
            }else{
                showAlert(message: "Note not Found.")
            }
            break
        default:
            colorOptionTblConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            isColourOptionEnabled = false
            break
        }
    }
}
