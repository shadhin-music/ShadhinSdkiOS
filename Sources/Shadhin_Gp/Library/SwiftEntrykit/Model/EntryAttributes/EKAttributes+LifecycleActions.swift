//
//  EKAttributes+LifecycleActions.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 6/16/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation

 extension EKAttributes {

    /** Contains optionally injected events that take place during the entry lifecycle */
    struct LifecycleEvents {
        
         typealias Event = () -> Void

        /** Executed before the entry appears - before the animation starts.
         Might not get called in case another entry with a higher display priority is displayed.
         */
         var willAppear: Event?
        
        /** Executed after the animation ends.
         Might not get called in case another entry with a higher display priority is displayed.
         */
         var didAppear: Event?

        /** Executed before the entry disappears (Before the animation starts) */
         var willDisappear: Event?
        
        /** Executed after the entry disappears (After the animation ends) */
         var didDisappear: Event?
        
         init(willAppear: Event? = nil, didAppear: Event? = nil, willDisappear: Event? = nil, didDisappear: Event? = nil) {
            self.willAppear = willAppear
            self.didAppear = didAppear
            self.willDisappear = willDisappear
            self.didDisappear = didDisappear
        }
    }
}
