//
//  UIViewControllerExt.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//


import UIKit

private var countTapped = 0
private let discoverStoryboard = UIStoryboard(name: "Discover", bundle: Bundle.ShadhinMusicSdk)
private let paymentStoryboard = UIStoryboard.init(name: "Payment", bundle: Bundle.ShadhinMusicSdk)

extension UIViewController {
    
    func openMusicPlayer(
        musicData   : [CommonContentProtocol],
        songIndex   : Int,
        isRadio     : Bool,
        playlistId  : String = "",
        rootModel : CommonContentProtocol? = nil) {
            
            
        
//        var _popVC = self.tabBarController?.popupContent as? MusicPlayerVC
//        if _popVC == nil{
//            _popVC = discoverStoryboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as? MusicPlayerVC
//        }
//        guard let popVC = _popVC else {
//            return
//        }
//        
//        popVC.loadViewIfNeeded()
//        popVC.songsIndex = songIndex
//        popVC.musicdata = musicData
//        popVC.playlistId = playlistId
//        popVC.initplayer(rootModel)
//            
//        self.tabBarController?.presentPopupBar(withContentViewController: popVC, animated: true, completion: nil)
//        tabBarController?.popupBar.barTintColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
//        tabBarController?.popupBar.tintColor = .red
//        tabBarController?.popupBar.progressViewStyle = .bottom
//        tabBarController?.popupContentView.popupCloseButton.isHidden = true
//        tabBarController?.popupBar.imageView.cornerRadius = 24
//        tabBarController?.popupBar.imageView.borderWidth = 2
//        tabBarController?.popupBar.imageView.borderColor = .gray
//        
//        if isRadio {
//            tabBarController?.popupInteractionStyle = .none
//            tabBarController?.popupBar.popupOpenGestureRecognizer.isEnabled = false
//        }else {
//            tabBarController?.popupInteractionStyle = .drag
//            tabBarController?.popupBar.popupOpenGestureRecognizer.isEnabled = true
//
//            guard let rootModel = rootModel,
//                  let rootId = rootModel.contentID,
//                  let rootType = rootModel.contentType,
//                  ShadhinCore.instance.isUserLoggedIn,
//                  musicData[songIndex].trackType?.uppercased() != "LM"
//                  else {return}
//
//            let isDatabaseRecordExits = RecentlyPlayedDatabase.instance.checkRecordExists(contentID: rootId)
//            if isDatabaseRecordExits {
//                RecentlyPlayedDatabase.instance.updateDataToDatabase(musicData: rootModel)
//            }else {
//                RecentlyPlayedDatabase.instance.saveDataToDatabase(musicData: rootModel)
//            }
//            ShadhinCore.instance.api.recentlyPlayedPost(with: rootId, contentType: rootType)
//        }
    }
    
    func openVideoPlayer(videoData: [CommonContentProtocol],index: Int) {
        let vc = VideoPlayerVC.instantiateNib()
        vc.index = index
        vc.videoList = videoData
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        SMAnalytics.viewContent(content: videoData[index])
    }
    
     func goSubscriptionTypeVC(_ useParent:Bool = false,
                              _ subscriptionPlatForm :String = "common",
                              _ subscriptionPlanName :String = "common") {
        if let navigationController = self.navigationController {
            // Push to the navigation stack
            let anotherViewController = SubscriptionVCv3.instantiateNib()
            navigationController.navigationItem.hidesBackButton = true
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.pushViewController(anotherViewController, animated: true)
        } else {
            // Present modally with a new navigation controller
            let anotherViewController = SubscriptionVCv3.instantiateNib()
            let navController = UINavigationController(rootViewController: anotherViewController)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationItem.hidesBackButton = true
            navController.setNavigationBarHidden(true, animated: true)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func goAlbumVC(isFromThreeDotMenu: Bool,content: CommonContentProtocol)-> MusicAlbumListVC {
        let vc = discoverStoryboard.instantiateViewController(withIdentifier: "MusicAlbumListVC") as! MusicAlbumListVC
        vc.discoverModel = content
        vc.isFromThreeDotMenu = isFromThreeDotMenu
        vc.hidesBottomBarWhenPushed = false
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : "r" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(content: content)
        return vc
    }
    
    func goArtistVC(content: CommonContentProtocol)-> MusicArtistListVC {
        let vc = discoverStoryboard.instantiateViewController(withIdentifier: "MusicArtistListVC") as! MusicArtistListVC
        vc.discoverModel = content
        vc.hidesBottomBarWhenPushed = false
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : "a" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(content: content)
        return vc
    }
    
    func goPlaylistVC(
        content: CommonContentProtocol,
        suggestedPlaylists : [CommonContentProtocol] = []
    )-> PlaylistOrSingleDetailsVC {
        let vc = discoverStoryboard.instantiateViewController(withIdentifier: PlaylistOrSingleDetailsVC.identifier) as! PlaylistOrSingleDetailsVC
        vc.discoverModel = content
        vc.suggestedPlaylists = suggestedPlaylists
        vc.hidesBottomBarWhenPushed = false
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : content.contentType?.lowercased() ?? "p" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(content: content)
        return vc
    }
    
    func goAddPlaylistVC(content: CommonContentProtocol) {
//        if !ShadhinCore.instance.isUserLoggedIn{
////            self.showNotUserPopUp(callingVC: self)
//            return
//        }
        guard checkProUser() else { 
            return
        }
                   
        let storyBoard = UIStoryboard(name: "MyMusic", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlaylistsVC") as! PlaylistsVC
        vc.fromThreeDotMenu = true
        vc.addPlaylistData = content
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .custom
        self.present(navVC, animated: true, completion: nil)
    }
    
    func countButtonTouch() {
        guard ShadhinCore.instance.isUserPro else {
            countTapped += 1
            if countTapped > 9 {
                countTapped = 0
                NavigationHelper.shared.navigateToSubscription(from: self)
            }
            return
        }
    }
    func resetCountButtonTouch() {
        countTapped = 0
    }
    
    //Tap to hide keyboard.
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //user status
      func checkProUser()-> Bool{
            if ShadhinCore.instance.isUserPro{
                return true
            }else{
                NavigationHelper.shared.navigateToSubscription(from: self)
            }
        return false
    }
}
