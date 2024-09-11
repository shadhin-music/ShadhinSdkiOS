//
//  EKAttributes+Shadow.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/21/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation
import UIKit

 extension EKAttributes {

    /** The shadow around the entry */
    enum Shadow {
        
        /** No shadow */
        case none
        
        /** Shadow with value */
        case active(with: Value)
        
        /** The shadow properties */
         struct Value {
             let radius: CGFloat
             let opacity: Float
             let color: EKColor
             let offset: CGSize
            
             init(color: EKColor = .black,
                        opacity: Float,
                        radius: CGFloat,
                        offset: CGSize = .zero) {
                self.color = color
                self.radius = radius
                self.offset = offset
                self.opacity = opacity
            }
        }
    }
}


