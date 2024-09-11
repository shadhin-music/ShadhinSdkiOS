//
//  EKRatingMessage.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 6/1/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation

 struct EKRatingMessage {
    
    // NOTE: Intentionally a reference type
    class SelectedIndex {
        var selectedIndex: Int!
    }
    
    /** Selection */
     typealias Selection = (Int) -> Void

    /** Initial title */
     var initialTitle: EKProperty.LabelContent
    
    /** Initial description */
     var initialDescription: EKProperty.LabelContent
    
    /** Rating items */
     var ratingItems: [EKProperty.EKRatingItemContent]
    
    /** Button bar content appears after selection */
     var buttonBarContent: EKProperty.ButtonBarContent
    
    /** Selection event - Each time the user interacts a rating star */
     var selection: Selection!

    let selectedIndexRef = SelectedIndex()
    
    /** Selected index (if there is one) */
     var selectedIndex: Int? {
        get {
            return selectedIndexRef.selectedIndex
        }
        set {
            selectedIndexRef.selectedIndex = newValue
        }
    }
    
    /** Initializer */
     init(initialTitle: EKProperty.LabelContent,
                initialDescription: EKProperty.LabelContent,
                ratingItems: [EKProperty.EKRatingItemContent],
                buttonBarContent: EKProperty.ButtonBarContent,
                selection: Selection? = nil) {
        self.initialTitle = initialTitle
        self.initialDescription = initialDescription
        self.ratingItems = ratingItems
        self.buttonBarContent = buttonBarContent
        self.selection = selection
    }
}
