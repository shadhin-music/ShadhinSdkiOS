//
//  EKAlertMessage.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 6/1/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

 struct EKAlertMessage {
    
     enum ImagePosition {
        case top
        case left
    }
    
    /** The position of the image inside the alert */
     let imagePosition: ImagePosition
    
    /** Image, Title, Description */
     let simpleMessage: EKSimpleMessage
    
    /** Contents of button bar */
     let buttonBarContent: EKProperty.ButtonBarContent
    
     init(simpleMessage: EKSimpleMessage,
                imagePosition: ImagePosition = .top,
                buttonBarContent: EKProperty.ButtonBarContent) {
        self.simpleMessage = simpleMessage
        self.imagePosition = imagePosition
        self.buttonBarContent = buttonBarContent
    }
}
