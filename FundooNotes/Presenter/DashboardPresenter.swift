import Foundation
import UIKit

class DashboardPresenter{
    let pDashboardView:PDashboardView?
    let presenterService:DashboardPresenterService?
    
    init(pDashboardView:PDashboardView,presenterService:DashboardPresenterService){
        self.pDashboardView = pDashboardView
        self.presenterService = presenterService
    }
    
    func getNotes(){
        pDashboardView?.startLoading()
        presenterService?.getNotes(completion: { (notes) in
            self.pDashboardView?.stopLoading()
            self.pDashboardView?.setNotes(notes: notes)
        })
        
    }
    
    func getDeletedNotes(){
        pDashboardView?.startLoading()
        presenterService?.getDeletedNotes(completion: { (notes) in
            self.pDashboardView?.stopLoading()
            self.pDashboardView?.setDeletedNotes(notes: notes)
        })
        
    }
    
    func getCellHeight(note:NoteModel,width:CGFloat,completion:(_ Height:CGFloat)->Void){
        var height:CGFloat = 15
        let titleString = "\(note.title) \n"
        let attributedString = NSMutableAttributedString(string: titleString, attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15)])
        attributedString.append(NSAttributedString(string: note.note, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        self.computeTextLabelHeightAttributed(text: attributedString, width: width) { (noteHeight) in
            height = height + noteHeight
        }
        self.computeTextLabelHeight(text: note.creadted_date,  width: width) { (dateHeight) in
            height = height + 30
        }
        if let imageUrl = note.imageUrl{
            guard let newImgheight = note.imageHeight else { return }
            guard let newImgWidth = note.imageWidth else { return }
            let newHeight =  Helper.shared.getScaledHeight(imageWidth: newImgWidth, imageHeight: newImgheight , scaleWidth: width)
            height = height + newHeight
//            if let noteImage = UIImage(data:imageData as Data){
//                self.computeImageHeight(image: noteImage, width: width) { (imageHeight) in
//                    height = height + imageHeight
//                }
//            }
        }
        completion(height)
    }
    
    func computeTextLabelHeightAttributed(text:NSAttributedString,width:CGFloat,completion:(CGFloat)->Void){
        let labelText = UILabel()
        labelText.numberOfLines = 0
        labelText.lineBreakMode = .byWordWrapping
        labelText.attributedText = text
        labelText.preferredMaxLayoutWidth = (width) - 32
        labelText.invalidateIntrinsicContentSize()
        completion(labelText.intrinsicContentSize.height)
    }
    
    func computeTextLabelHeight(text:String,width:CGFloat,completion:(CGFloat)->Void){
        let labelText = UILabel()
        labelText.numberOfLines = 0
        labelText.lineBreakMode = .byWordWrapping
        labelText.text = text
        labelText.preferredMaxLayoutWidth = (width) - 32
        labelText.invalidateIntrinsicContentSize()
        completion(labelText.intrinsicContentSize.height)
    }
    
    func computeImageHeight(image:UIImage,width:CGFloat,completion:(CGFloat)->Void){
        let newHeight =  Helper.shared.getScaledHeight(imageWidth: image.size.width, imageHeight: image.size.height, scaleWidth: width)
        completion(newHeight)
    }
    
    func getNotesOfType(_ type:Constant.NoteOfType,completion:@escaping ([NoteModel])->Void){
        presenterService?.getNotesOfType(type, completion: { (notes) in
            completion(notes)
        })
    }
    
    func pinNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        presenterService?.pinNoteArray(notes: notes, completion: { (status,message) in
            completion(status,message)
        })
    }
    func deleteNoteArray(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        presenterService?.deleteNoteArray(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    
    func deleteNoteArrayFromTrash(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        presenterService?.deleteNoteArrayFromTrash(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    
    func restoreNoteArrayFromTrash(notes:[NoteModel],completion:@escaping (Bool,String)->Void){
        presenterService?.restoreNoteArrayFromTrash(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    func reloadView(){
        pDashboardView?.reloadView()
    }
    
    func setReminderArray(notes:[NoteModel],reminderDate:String,reminderTime:String,completion:@escaping (Bool,String)->Void){
        presenterService?.setReminderArray(notes: notes, reminderDate: reminderDate, reminderTime: reminderTime, completion: { (result, message) in
            completion(result, message)
        })
    }
    func changeColorOfNoteArray(notes:[NoteModel],color:String,completion:@escaping (Bool,String)->Void){
        presenterService?.changeColorOfNoteArray(notes: notes, color: color, completion: { (result, message) in
            completion(result, message)
        })
    }
    
    func archiveNoteArray(notes:[NoteModel],completion:@escaping(Bool,String)->Void){
        presenterService?.archiveNoteArray(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    func unarchiveNoteArray(notes:[NoteModel],completion:@escaping(Bool,String)->Void){
        presenterService?.unarchiveNoteArray(notes: notes) { (result, message) in
            completion(result, message)
        }
    }
    

}
