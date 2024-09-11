//
//  UIViewControllerV3++.swift
//  Shadhin
//
//  Created by Joy on 23/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

extension UIViewController{
    func openMusicPlayerV3(
        musicData   : [CommonContentProtocol],
        songIndex   : Int,
        isRadio     : Bool =  false,
        playlistId  : String = "",
        rootModel   : CommonContentProtocol? = nil) {
            
            
//            update to V4
//            openMusicPlayerV4(
//                musicData: musicData,
//                songIndex: songIndex,
//                isRadio: isRadio,
//                playlistId: playlistId,
//                rootModel: rootModel)
            
          //  guard !MusicPlayerV3.shared.isChorkiAdIsPlaying else {return}
            var popVC = tabBarController?.popupContainerViewController as? MusicPlayerV3
            if popVC == nil{
                popVC  = MusicPlayerV3.shared
            }
            guard let popVC = popVC else {
                return
            }
            
            popVC.loadViewIfNeeded()
            popVC.songsIndex = songIndex
            popVC.musicdata = musicData
            popVC.playlistId = playlistId
            popVC.initplayer(rootModel, songIndex)
            
            //execule till this for outside
            popVC.rootContent = rootModel
            self.tabBarController?.popupController.delegate = popVC
            if let popupBar = self.tabBarController?.popupBar {
                
                popupBar.dataSource = popVC
                popupBar.progressViewStyle  = .bottom
                popupBar.pbBackgroundColor = .appTintColor
                popupBar.progressView.tintColor = .red
                popupBar.customPopupBarViewController = MusicPlayerV4Mini.instantiateNib()
            }
            if let popupBar = tabBarController?.popupBar {
                popupBar.customPopupBarViewController = MusicPlayerV4Mini.instantiateNib()
            }
            if let container = self.tabBarController?.popupContentView{
                container.popupPresentationStyle = .fullScreen
                container.popupCloseButtonStyle = .none
            }
            
            self.tabBarController?.presentPopupBar(withPopupContentViewController: popVC, animated: true, completion: nil)
            popVC.viewDidLoad()
            
            if isRadio {
                
                tabBarController?.popupBar.popupTapGestureRecognizer.isEnabled = false
                tabBarController?.popupController.popupBarPanGestureRecognizer.isEnabled = false
            }else {
                
                tabBarController?.popupBar.popupTapGestureRecognizer.isEnabled = true
                tabBarController?.popupController.popupBarPanGestureRecognizer.isEnabled = true
                
                guard let rootModel = rootModel,
                      let rootId = rootModel.contentID,
                      let rootType = rootModel.contentType,
                    //  ShadhinCore.instance.isUserLoggedIn,
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
    
    func openGPMusicsInMiniPlayer() {
        
        if self.tabBarController == nil {
            print("NIL")
        }
        let index =  GPAudioViewModel.shared.selectedIndexInCarousel
        let viewModel = GPAudioViewModel.shared
        let content = viewModel.gpMusicContents[viewModel.selectedIndexInCarousel].toCommonContentV4()
        //var popVC = tabBarController?.popupContainerViewController as? MusicPlayerV3
        //if popVC == nil{
            var popVC  = MusicPlayerV3.shared
        //}
//        guard let popVC = popVC else {
//            return
//        }
        
        
        popVC.loadViewIfNeeded()
        popVC.songsIndex = GPAudioViewModel.shared.selectedIndexInCarousel
        popVC.musicdata = GPAudioViewModel.shared.gpMusicContents.compactMap({$0.toCommonContentV4()})
        //popVC.playlistId = playlistId
        popVC.updateUI(withIndex: index)
        
        //execule till this for outside
        //popVC.rootContent = rootModel
        self.tabBarController?.popupController.delegate = popVC
        if let popupBar = self.tabBarController?.popupBar {
            
            popupBar.dataSource = popVC
            popupBar.progressViewStyle  = .bottom
            popupBar.pbBackgroundColor = .appTintColor
            popupBar.progressView.tintColor = .red
            
            let miniPlayer = MusicPlayerV4Mini.instantiateNib()
            popupBar.customPopupBarViewController = miniPlayer
            
        }
        
        if let container = self.tabBarController?.popupContentView{
            container.popupPresentationStyle = .fullScreen
            container.popupCloseButtonStyle = .none
        }
        
        self.tabBarController?.presentPopupBar(withPopupContentViewController: popVC, animated: true, completion: nil)
        //popVC.viewDidLoad()
        popVC.iCarouselView.scrollToItem(at: index, animated: false)
        popVC.updateMiniPlayerInfo(content: content, tabBar: self.tabBarController)
        
        
    }
}
