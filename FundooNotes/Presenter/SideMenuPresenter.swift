import Foundation

class SideMenuPresenter{
    var pSideMenuView:PSideMenuView?
    var persenterService:DashboardPresenterService?
    
    init(pSideMenuView:PSideMenuView,persenterService:DashboardPresenterService) {
        self.pSideMenuView = pSideMenuView
        self.persenterService = persenterService
    }
    
    func showSignOutAlert(){
    }
}
