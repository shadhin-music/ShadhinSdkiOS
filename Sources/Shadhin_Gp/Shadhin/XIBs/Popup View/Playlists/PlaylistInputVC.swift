//
//  PlaylistInputVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/7/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


typealias PlaylistCreateCompleted = ()->()

class PlaylistInputVC: UIViewController {

    @IBOutlet weak var playlistTxtFld: UITextField!
    var playlistCreateCompleted: PlaylistCreateCompleted?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelAction(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    func didPlaylistCreateCompleted(completion: @escaping PlaylistCreateCompleted) {
        playlistCreateCompleted = completion
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let name = playlistTxtFld.text else {return}
        if name != ""{
            ShadhinCore.instance.api.createUserPlaylist(name: name) { (err) in
                if err == nil {
                    self.playlistCreatedSuccess()
                }
            }
            
        }else {
            view.makeToast("Playlist name cannot be empty")
        }
    }
    
    func playlistCreatedSuccess(){
        self.view!.makeToast("Playlist created", duration: 1, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
            SwiftEntryKit.dismiss()
            self.playlistCreateCompleted?()
        }
    }
}
