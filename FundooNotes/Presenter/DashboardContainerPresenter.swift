import Foundation


class DashboardContainerPresenter{
    let pDashboardContainerView:PDashboardContainerView?
    let presenterService:DashboardContainerPresenterService?
    
    init(pDashboardContainerView:PDashboardContainerView,presenterService:DashboardContainerPresenterService){
            self.pDashboardContainerView = pDashboardContainerView
            self.presenterService = presenterService
        }
    
    func searchNote(noteId:String,completion:@escaping (NoteModel)-> Void){
        presenterService?.searchNote(noteId: noteId, completion: { (note) in
            completion(note)
        })
    }
}
