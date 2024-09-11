//
//  QLUtils.swift
//  QuickLayout
//
//  Created by Daniel Huri on 11/21/17.
//

import Foundation
import UIKit

/**
 Typealias for dictionary that contains multiple constraints
 */
 typealias QLMultipleConstraints = [QLAttribute: NSLayoutConstraint]

/**
 Extends layout priority to other readable types
 */
 extension QLPriority {
    static let must = QLPriority(rawValue: 999)
    static let zero = QLPriority(rawValue: 0)
}

/**
 Represents pair of attributes
 */
 struct QLAttributePair {
     let first: QLAttribute
     let second: QLAttribute
}

/**
 Represents size constraints
 */
 struct QLSizeConstraints {
     let width: NSLayoutConstraint
     let height: NSLayoutConstraint
}

/**
 Represents center constraints
 */
 struct QLCenterConstraints {
     let x: NSLayoutConstraint
     let y: NSLayoutConstraint
}

/**
 Represents axis constraints (might be .top and .bottom, .left and .right, .leading and .trailing)
 */
 struct QLAxisConstraints {
     let first: NSLayoutConstraint
     let second: NSLayoutConstraint
}

/**
 Represents center and size constraints
 */
 struct QLFillConstraints {
     let center: QLCenterConstraints
     let size: QLSizeConstraints
}

/**
 Represents pair of priorities
 */
 struct QLPriorityPair {
    
     let horizontal: QLPriority
     let vertical: QLPriority
     static var required: QLPriorityPair {
        return QLPriorityPair(.required, .required)
    }
    
     static var must: QLPriorityPair {
        return QLPriorityPair(.must, .must)
    }
    
     init(_ horizontal: QLPriority, _ vertical: QLPriority) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

/**
 Represents axis description
 */
 enum QLAxis {
    case horizontally
    case vertically
    
     var attributes: QLAttributePair {
        
        let first: QLAttribute
        let second: QLAttribute
        
        switch self {
        case .horizontally:
            first = .left
            second = .right
        case .vertically:
            first = .top
            second = .bottom
        }
        return QLAttributePair(first: first, second: second)
    }
}
