//
//  File.swift
//  Shadhin
//
//  Created by Gakk Alpha on 1/10/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func openMusicPlayerV4(
        musicData   : [CommonContentProtocol],
        songIndex   : Int,
        isRadio     : Bool =  true,
        playlistId  : String = "",
        rootModel   : CommonContentProtocol? = nil)
    {
        var popVC = MainTabBar.shared?.popupContainerViewController as? MusicPlayerV4
        if popVC == nil{
            popVC  = MusicPlayerV4.shared
        }
        guard let popVC = popVC else {
            return
        }
        var success = true
        if rootModel == nil && !playlistId.isEmpty{
            let newRoot = CommonContent_V0(contentID: playlistId, contentType: "mp")
            success = popVC.initMusic(items: musicData,rootItem: newRoot, selectedIndex: songIndex)
        }else{
            success = popVC.initMusic(items: musicData,rootItem: rootModel, selectedIndex: songIndex)
        }
        guard success else{
            MainTabBar.shared?.showError(title: "Error", msg: "Opps! unble to create Audio items for player, please try again later")
            closePlayer()
            return
        }
        if let popupBar =  MainTabBar.shared?.popupBar {
            popupBar.customPopupBarViewController = MusicPlayerV4Mini.instantiateNib()
        }
        if let container =  MainTabBar.shared?.popupContentView{
            container.popupPresentationStyle = .fullScreen
            container.popupCloseButtonStyle = .none
        }
        MainTabBar.shared?.presentPopupBar(withPopupContentViewController: popVC, animated: true, completion: nil)
        MainTabBar.shared?.popupController.isGestureEnabled = false
        
        if isRadio {
            MainTabBar.shared?.popupBar.popupTapGestureRecognizer.isEnabled = false
        }else {
            MainTabBar.shared?.popupBar.popupTapGestureRecognizer.isEnabled = true
            guard let rootModel = rootModel,
                  let rootId = rootModel.contentID,
                  let rootType = rootModel.contentType,
                  ShadhinCore.instance.isUserLoggedIn,
                  musicData[songIndex].trackType?.uppercased() != "LM"
            else {return}
            
            let isDatabaseRecordExits = RecentlyPlayedDatabase.instance.checkRecordExists(contentID: rootId)
            if isDatabaseRecordExits {
                RecentlyPlayedDatabase.instance.updateDataToDatabase(musicData: rootModel)
            }else {
                RecentlyPlayedDatabase.instance.saveDataToDatabase(musicData: rootModel)
            }
            ShadhinCore.instance.api.recentlyPlayedPost(with: rootId, contentType: rootType)
        }
    }
    
    func minimiseMusicPlayer(){
        MainTabBar.shared?.popupController.closePopupContent()
    }
    
    func closePlayer(){
        MainTabBar.shared?.hidePopupBar(animated: true)
    }
}

