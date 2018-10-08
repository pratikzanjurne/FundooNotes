import Foundation

class SetReminderPresenter{
    
    var pSetReminderView:PSetReminderView?
    
    init(pSetReminderView:PSetReminderView) {
        self.pSetReminderView = pSetReminderView
    }
    
    func openPopUpView(_ option : Helper.reminderOptionSelected){
        pSetReminderView?.openPopUpView(option)
    }
    
}
