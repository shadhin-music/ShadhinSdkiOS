//
//  MusicPlayerV3TimerExt.swift
//  Shadhin
//
//  Created by Joy on 23/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit
extension MusicPlayerV3: ShadhinPlayerSleepTimerDelegate{
    func timerStateChanged(newState: ShadhinPlayerSleepTimer.State) {
        if case .off = newState {
            sleepTimerBtn.setImage(UIImage(named: "ic_sleep_timer", in: Bundle.ShadhinMusicSdk, with: nil), for: .normal)
        }else{
            sleepTimerBtn.setImage(UIImage(named: "ic_sleep_timer_active", in: Bundle.ShadhinMusicSdk, with: nil), for: .normal)
        }
    }
    
    func stopPlayer() {
        audioPause()
    }
}
