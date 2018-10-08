import UIKit
import  CoreData
import UserNotifications


protocol PDashboardView {
    func setNotes(notes : [NoteModel])
    func setDeletedNotes(notes:[NoteModel])
    func stopLoading()
    func startLoading()
    func setSelectedNotes(notes:[NoteModel])
    func reloadView()
    
}


class DashboardViewController:BaseViewController{
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var notesNavigationItem: UINavigationItem!
    @IBOutlet var btnChangeView: UIBarButtonItem!
    @IBOutlet var searchBarConstraint: NSLayoutConstraint!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var dropDownColorOptnHC: NSLayoutConstraint!
    @IBOutlet var dropDownColorOption: ColourOptions!
    @IBOutlet var dropdownMenu: DropdownTableView!
    @IBOutlet var dropdownMenuHC: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    var userId:String?
    var isListView:Bool = false
    var isSearchBarVisible = false
    var isFilterActive = false
    var isMultipleSelectionActive = false
    var presenter:DashboardPresenter?
    var notes = [NoteModel]()
    var pinnedNotes = [NoteModel]()
    var unpinnedNotes = [NoteModel]()
    var filteredNotes = [NoteModel]()
    var pinnedFilteredNotes = [NoteModel]()
    var deletedNotes = [NoteModel]()
    var selectedNotes = [NoteModel]()
    var activeView = Constant.NoteOfType.note
    var selectedColor:String = Constant.Color.colourOrange
    var isDropdownColorOptionVisible = false
    var isDropdownMenuViaible = false
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialseView()
        presenter = DashboardPresenter(pDashboardView: self, presenterService: DashboardPresenterService())
        setupData()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if activeView == .note{
            self.isFilterActive = false
        }else{
            self.isFilterActive = true
        }
        presenter?.getNotesOfType(activeView, completion: { (notes) in
            self.filteredNotes = notes
        })
        setupData()
        collectionView.reloadData()
        if let presenter = presenter{
            presenter.getNotes()
        }
    }
    override func initialseView() {
        self.refreshControl = UIRefreshControl()
        self.navigationBar.barTintColor = UIColor(hexString: selectedColor)
        let cell = UINib(nibName: "DashboardNoteCell", bundle: nil)
        self.collectionView.register(cell, forCellWithReuseIdentifier: "DashboardNoteCell")
    collectionView.register(UINib(nibName:"HCollectionReusableView",bundle:nil),forSupplementaryViewOfKind:UICollectionElementKindSectionHeader,withReuseIdentifier:"HeaderCell")

        collectionView.contentInset.bottom = 5
        collectionView.contentInset.left = 5
        collectionView.contentInset.right = 5
        collectionView.contentInset.top = 5
        UIHelper.shared.setShadow(view: bottomView)
        bottomView.layer.shadowPath = UIBezierPath(roundedRect:bottomView.bounds, cornerRadius:bottomView.layer.cornerRadius).cgPath
        let  longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        SideMenuTableViewController.showNotesDelegate = self
        dropDownColorOption.delegate = self
        self.dropdownMenu.delegate = self
    }
    
    func setupData(){
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout{
            layout.delegate = self
            layout.numberOfColumns = isListView ? 1 : 2
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        self.presenter?.getNotes()
    }
    
    @objc func onRefresh(){
        print("Refreshing.........")
        presenter?.getNotes()
    }
    
    @IBAction func onSideMenuTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @IBAction func takeNoteAction(_ sender: Any) {
        let stroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stroryBoard.instantiateViewController(withIdentifier: "TakeNoteViewController") as! TakeNoteViewController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onChangeViewTapped(_ sender: Any) {
        if let layout = collectionView.collectionViewLayout as? PinterestLayout{
            layout.numberOfColumns = isListView ? 2 : 1
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
        let image = isListView ? #imageLiteral(resourceName: "list_view"):#imageLiteral(resourceName: "grid_view")
        self.isListView = self.isListView ? false : true
        btnChangeView.image = image
    }

    @IBAction func onSearchBtnPressed(_ sender: Any) {
        if isSearchBarVisible{
            searchBar.resignFirstResponder()
            self.searchBarConstraint.constant = 0
            UIView.animate(withDuration:0.5){
                self.view.layoutIfNeeded()
            }
            isSearchBarVisible = false
            searchBar.resignFirstResponder()
        }else{
            self.searchBarConstraint.constant = 44
            UIView.animate(withDuration:0.5){
                self.view.layoutIfNeeded()
            }
            isSearchBarVisible = true
            searchBar.becomeFirstResponder()
        }
        
    }
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {

        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            let cell = collectionView.cellForItem(at: selectedIndexPath)
            cell?.layer.borderColor = UIColor.gray.cgColor
            cell?.layer.borderWidth = 3.0
            collectionView.allowsMultipleSelection = true
            if isMultipleSelectionActive{
                
            }else{
                NavigationHelper.setNavigationItem(target: self, delegate: self, option: self.activeView, completion: { (navigationItem) in
                    if let navigationItems = navigationItem.leftBarButtonItems{
                        navigationItems[1].title = "\(self.selectedNotes.count)"
                    }
                    self.navigationBar.pushItem(navigationItem, animated: false)
                })
            }
            self.isMultipleSelectionActive = true
            self.view.backgroundColor = UIColor(hexString: Constant.Color.colourReminderText)
            self.navigationBar.barTintColor = UIColor.white
            collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .centeredVertically)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
                self.collectionView.reloadData()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}
extension DashboardViewController:PinterestLayoutDelegate{
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let gridWidth = ((collectionView.bounds.width-15)/2)
        let listWidth = ((collectionView.bounds.width-10))
        let width = self.isListView ? listWidth : gridWidth
        var cellHeight:CGFloat = 0
        if isFilterActive{
            presenter?.getCellHeight(note: filteredNotes[indexPath.item], width:width, completion: { (height) in
                print(height)
                cellHeight = height
            })
        }else{
            if indexPath.section == 0{
                if pinnedNotes.count != 0{
                    presenter?.getCellHeight(note: pinnedNotes[indexPath.item], width:width, completion: { (height) in
                        print(height)
                        cellHeight = height
                    })
                }
            }else{
                presenter?.getCellHeight(note: unpinnedNotes[indexPath.item], width:width, completion: { (height) in
                    print(height)
                    cellHeight = height
                })
            }

        }
        return cellHeight
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, sizeForSectionFooterViewForSection section: Int) -> CGSize {
        let gridWidth = ((collectionView.bounds.width-15)/2)
        let listWidth = ((collectionView.bounds.width-10)/2)
        let width = self.isListView ? listWidth : gridWidth
        return CGSize(width: width, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, sizeForSectionHeaderViewForSection section: Int) -> CGSize {
        let gridWidth = ((collectionView.bounds.width-15))
        let listWidth = ((collectionView.bounds.width-10))
        let width = self.isListView ? listWidth : gridWidth
        return CGSize(width: width, height:30)
    }
    
    
}
extension DashboardViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFilterActive{
            return filteredNotes.count
        }
        return (section == 0) ? self.pinnedNotes.count:self.unpinnedNotes.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isFilterActive ? 1:2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCell", for: indexPath) as! HCollectionReusableView
            if isFilterActive{
            reusableView.setHeader(text: "Notes")
        }else{
            if indexPath.section == 0{
                reusableView.setHeader(text: "Pinned")
            }else{
                reusableView.setHeader(text: "Notes")
            }
        }
            return reusableView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardNoteCell", for: indexPath) as! DashboardNoteCell
        let note:NoteModel
        if isFilterActive{
            note = filteredNotes[indexPath.item]
        }else{
            if indexPath.section == 0{
                note = pinnedNotes[indexPath.item]
            }else{
                note = unpinnedNotes[indexPath.item]
            }
        }
        cell.setData(note: note)
        UIHelper.shared.setCornerRadius(view: cell, radius: 5.0)
        UIHelper.shared.setCornerRadius(view: cell.contentView, radius: 5.0)
        UIHelper.shared.setShadow(view: cell)
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isMultipleSelectionActive{
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderColor = UIColor.gray.cgColor
            cell?.layer.borderWidth = 3.0
            if isFilterActive{
                selectedNotes.append(filteredNotes[indexPath.item])
            }else{
                if indexPath.section == 0{
                    selectedNotes.append(pinnedNotes[indexPath.item])
                }else{
                    selectedNotes.append(unpinnedNotes[indexPath.item])
                }
            }
            if let navigationItems = self.navigationBar.items{
                if navigationItems.count == 2{
                    if let leftNavigationItems = navigationItems[1].leftBarButtonItems{
                        leftNavigationItems[1].title = "\(self.selectedNotes.count)"
                    }
                }
            }
        }else{
            let stroryBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = stroryBoard.instantiateViewController(withIdentifier: "TakeNoteViewController") as! TakeNoteViewController
            if isFilterActive{
                vc.note = filteredNotes[indexPath.item]
            }else{
                if indexPath.section == 0{
                    vc.note = pinnedNotes[indexPath.item]
                }else{
                    vc.note = unpinnedNotes[indexPath.item]
                }
            }
            present(vc, animated: true, completion: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 0.0
        if collectionView.indexPathsForSelectedItems?.count == 0 {
            collectionView.allowsMultipleSelection = false
            isMultipleSelectionActive = false
            self.navigationBar.popItem(animated: false)
            self.view.backgroundColor = UIColor(hexString: self.selectedColor)
            self.navigationBar.barTintColor = UIColor(hexString: self.selectedColor)
            self.selectedNotes.removeAll()
            return
        }
        let note:NoteModel
        if isFilterActive{
            note = filteredNotes[indexPath.item]
        }else{
            if indexPath.section == 0{
                note = pinnedNotes[indexPath.item]
            }else{
                note = unpinnedNotes[indexPath.item]
            }
        }
        for i in 0..<selectedNotes.count {
            if selectedNotes[i].note_id == note.note_id{
                selectedNotes.remove(at: i)
                break
            }
        }
        if let navigationItems = self.navigationBar.items{
            if navigationItems.count == 2{
                if let leftNavigationItems = navigationItems[1].leftBarButtonItems{
                    leftNavigationItems[1].title = "\(self.selectedNotes.count)"
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if isFilterActive{
            let item = filteredNotes.remove(at: sourceIndexPath.item)
            filteredNotes.insert(item, at: destinationIndexPath.item)
            collectionView.reloadData()
        }else{
            if sourceIndexPath.section == 0 && destinationIndexPath.section == 0{
                let item = pinnedNotes.remove(at: sourceIndexPath.item)
                pinnedNotes.insert(item, at: destinationIndexPath.item)
                collectionView.reloadData()
            }else if sourceIndexPath.section == 1 && destinationIndexPath.section == 1{
                let item = unpinnedNotes.remove(at: sourceIndexPath.item)
                unpinnedNotes.insert(item, at: destinationIndexPath.item)
                collectionView.reloadData()
            }else{
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DashboardViewController:UISearchBarDelegate{
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isFilterActive = false
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFilterActive = false
        isSearchBarVisible = false
        presenter?.reloadView()
        searchBar.resignFirstResponder()
        searchBarConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isFilterActive = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)!{
           presenter?.getNotes()
        }else{
            filteredNotes = notes.filter({ (note) -> Bool in
                return note.title.lowercased().contains(searchText.lowercased()) || note.note.lowercased().contains(searchText.lowercased())
            })
            collectionView.reloadData()
        }
    }
}
extension DashboardViewController:PDashboardView{
    
    func reloadView() {
        self.filteredNotes = [NoteModel]()
        self.pinnedFilteredNotes = [NoteModel]()
        self.notes = [NoteModel]()
        self.pinnedNotes = [NoteModel]()
        self.unpinnedNotes = [NoteModel]()
        self.selectedNotes = [NoteModel]()
        if activeView == .note{
            self.isFilterActive = false
        }else{
            self.isFilterActive = true
        }
        presenter?.getNotesOfType(activeView, completion: { (notes) in
            self.filteredNotes = notes
        })
        if let presenter = presenter{
            presenter.getNotes()
        }
    }
    
    func setSelectedNotes(notes: [NoteModel]) {
        self.selectedNotes = notes
    }
    
    func startLoading(){
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
    
    func stopLoading(){
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
    }
    
    func setNotes(notes : [NoteModel]) {
        refreshControl.endRefreshing()
        self.notes = notes
        pinnedNotes = notes.filter({ (note) -> Bool in
            return note.is_pinned == true
        })
        unpinnedNotes = notes.filter({ (note) -> Bool in
            return note.is_pinned != true && note.is_archived != true
        })
        self.collectionView.reloadData()
        presenter?.getNotesOfType(self.activeView, completion: { (notes) in
            self.filteredNotes = notes
            self.collectionView.reloadData()
        })
    }
    
    func setDeletedNotes(notes: [NoteModel]) {
        self.filteredNotes = notes
        collectionView.reloadData()
    }
    
}


extension DashboardViewController:PShowNotes{
    func showNotes(_ option: Constant.NoteOfType, colour: String, viewTitle: String) {
        self.activeView = option
        self.selectedColor = colour
        switch option{
            case .deleted:
                self.dropdownMenu.array = ["Delete Permanently"]
                self.dropdownMenu.tableView.reloadData()
                self.isFilterActive = true
                self.notesNavigationItem.title = Constant.DashboardViewTitle.deletedView
                self.view.backgroundColor = UIColor(hexString: colour)
                self.navigationBar.barTintColor = UIColor(hexString: colour)
                presenter?.getNotesOfType(.deleted, completion: { (notes) in
                    self.filteredNotes = notes
                    self.collectionView.reloadData()
                })
            default:
                if option == .note{
                    self.isFilterActive = false
                    self.dropdownMenu.array = ["Archive","Delete","Make A Copy"]
                    self.dropdownMenu.tableView.reloadData()
                }else{
                    self.isFilterActive = true
                }
                if option == .archive{
                    self.dropdownMenu.array = ["Unarchive","Delete","Make A Copy"]
                    self.dropdownMenu.tableView.reloadData()
                }else if option == .reminder{
                    self.dropdownMenu.array = ["Archive","Delete","Make A Copy"]
                    self.dropdownMenu.tableView.reloadData()
                }
                self.notesNavigationItem.title = viewTitle
                self.view.backgroundColor = UIColor(hexString: colour)
                self.navigationBar.barTintColor = UIColor(hexString: colour)
                presenter?.getNotesOfType(option, completion: { (notes) in
                    self.filteredNotes = notes
                    self.collectionView.reloadData()
                })
        }
    }
}
extension DashboardViewController:PNavigationItemDelegate{
    func onClickOption() {
        if isDropdownMenuViaible{
            self.dropdownMenuHC.constant = 0
            isDropdownMenuViaible = false
            UIView.animate(withDuration: 0.15, animations: {
                self.view.layoutIfNeeded()
            })
        }else{
            self.dropdownMenuHC.constant = self.dropdownMenu.tableView.contentSize.height
            isDropdownMenuViaible = true
            UIView.animate(withDuration: 0.15, animations: {
                self.view.layoutIfNeeded()
            })
        }
        if isDropdownColorOptionVisible{
            self.onClickColor()
        }
    }
    func onClickBack() {
        self.selectedNotes.removeAll()
        self.navigationBar.popItem(animated: false)
        self.isMultipleSelectionActive = false
        self.view.backgroundColor = UIColor(hexString: self.selectedColor)
        self.navigationBar.barTintColor = UIColor(hexString: self.selectedColor)
        self.collectionView.allowsMultipleSelection = false
        self.presenter?.reloadView()
    }
    func onClickPin() {
        self.presenter?.pinNoteArray(notes: selectedNotes, completion: { (status, message) in
            self.onClickBack()
        })
    }
    func onClickDelete() {
        if self.activeView == .deleted{
            presenter?.deleteNoteArrayFromTrash(notes: self.selectedNotes, completion: { (status, message) in
                self.onClickBack()
            })
        }else{
            presenter?.deleteNoteArray(notes: self.selectedNotes, completion: { (status, message) in
                self.onClickBack()
            })
        }
    }
    func onClickColor(){
        if isDropdownColorOptionVisible{
            self.dropDownColorOptnHC.constant = 0
            isDropdownColorOptionVisible = false
            UIView.animate(withDuration: 0.15, animations: {
                self.view.layoutIfNeeded()
            })
        }else{
            self.dropDownColorOptnHC.constant = 130
            isDropdownColorOptionVisible = true
            UIView.animate(withDuration: 0.15, animations: {
                self.view.layoutIfNeeded()
            })
        }
        if isDropdownMenuViaible{
            self.onClickOption()
        }
    }
    func onClickReminder() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SetReminderView") as? SetReminderViewController else{
            return;
        }
        vc.reminderDelegate = self
        present(vc, animated: true, completion: nil)
    }
    func onClickRestore() {
        presenter?.restoreNoteArrayFromTrash(notes: self.selectedNotes, completion: { (status, message) in
            self.onClickBack()
        })
    }
    
}

extension DashboardViewController:PReminderDelegate{
    
    func setReminderData(date: String, time: String) {
        if date != "MMM d, yyyy" && time != "h:mm a"{
            self.presenter?.setReminderArray(notes: self.selectedNotes, reminderDate: date, reminderTime: time, completion: { (result, message) in
            })
            Helper.shared.setReminderForArray(notes: self.selectedNotes,    reminderDate: date, reminderTime: time) { (result, Message) in
            }
        }else{
            
        }
        self.onClickBack()
    }
}

extension DashboardViewController:PColorDelegate{
    func onChangeColor(color: String) {
        presenter?.changeColorOfNoteArray(notes: self.selectedNotes, color: color, completion: { (result, message) in
            self.isDropdownColorOptionVisible = false
            self.dropDownColorOptnHC.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            self.onClickBack()
        })

    }
}

extension DashboardViewController:PDropdownMenu{
    func didSelectCell(indexPath:Int) {
        switch activeView{
            case .note:
                switch indexPath{
                case 0:
                    presenter?.archiveNoteArray(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                case 1:
                    presenter?.deleteNoteArray(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                default:
                    break
                }
                break
            case .deleted:
                switch indexPath{
                case 0:
                    presenter?.deleteNoteArrayFromTrash(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                default:
                    break
                }
                break
            case .reminder:
                switch indexPath{
                case 0 :
                    presenter?.archiveNoteArray(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                case 1:
                    presenter?.deleteNoteArray(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                default:
                    break
                }
                break
            case .archive:
                switch indexPath{
                case 0:
                    presenter?.unarchiveNoteArray(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                case 1:
                    presenter?.deleteNoteArray(notes: self.selectedNotes, completion: { (result, message) in
                        self.presenter?.reloadView()
                    })
                    break
                default:
                    break
                }
                break
            }
        self.onClickOption()
        self.onClickBack()
    }
}

