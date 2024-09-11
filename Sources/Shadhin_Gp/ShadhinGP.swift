//
//  ShadhinGP.swift
//  Shadhin_Gp
//
//  Created by Maruf on 5/6/24.
//

import UIKit

@objc
final class ShadhinGP : NSObject{
    public static let shared = ShadhinGP()
    var coordinator : HomeCoordinator!
    @objc
    private override init() {
        super.init()
        //  wrapper = BLWrapper(delegate: self)
    }
    func gotoShadhinMusic(parentVC: UIViewController, accesToken:String) {
        ShadhinCore.instance.defaults.userSessionToken = accesToken
        ShadhinCore.instance.api.getUserInfo(token: ShadhinCore.instance.defaults.userSessionToken) { response  in
            switch response {
            case .success(let success):
                UserInfoViewModel.shared.userInfo = success.data
                ShadhinCore.instance.defaults.userMsisdn = success.data?.phoneNumber ?? ""
            case .failure(let failure): break
            }
            
            
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.ShadhinMusicSdk)
            if let tabbar = (storyBoard.instantiateViewController(withIdentifier: "MainTabBar") as? UITabBarController){
                tabbar.modalPresentationStyle = .fullScreen
                parentVC.present(tabbar, animated: true)
            }
        }
       
    }
    
}

class UserInfoViewModel {
    static let shared = UserInfoViewModel()
    private init () {
        
    }
    var userInfo: UserData?
}

