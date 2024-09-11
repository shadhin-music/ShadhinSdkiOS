//
//  EKColor.swift
//  SwiftEntryKit
//
//  Created by Daniel on 21/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

/** A color representation attribute as per user interface style */
 struct EKColor: Equatable {
    
    // MARK: - Properties
    
     private(set) var dark: UIColor
     private(set) var light: UIColor
    
    // MARK: - Setup
    
     init(light: UIColor, dark: UIColor) {
        self.light = light
        self.dark = dark
    }
    
     init(_ unified: UIColor) {
        self.light = unified
        self.dark = unified
    }
    
     init(rgb: Int) {
        dark = UIColor(rgb: rgb)
        light = UIColor(rgb: rgb)
    }
    
     init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        let color = UIColor(red: CGFloat(red) / 255.0,
                            green: CGFloat(green) / 255.0,
                            blue: CGFloat(blue) / 255.0,
                            alpha: 1.0)
        light = color
        dark = color
    }
    
    /** Computes the proper UIColor */
     func color(for traits: UITraitCollection,
                      mode: EKAttributes.DisplayMode) -> UIColor {
        switch mode {
        case .inferred:
            if #available(iOS 13, *) {
                switch traits.userInterfaceStyle {
                case .light, .unspecified:
                    return light
                case .dark:
                    return dark
                @unknown default:
                    return light
                }
            } else {
                return light
            }
        case .light:
            return light
        case .dark:
            return dark
        }
    }
}

 extension EKColor {
    
    /// Returns the inverse of `self` (light and dark swapped)
    var inverted: EKColor {
        return EKColor(light: dark, dark: light)
    }
    
    /** Returns an `EKColor` with the specified alpha component */
    func with(alpha: CGFloat) -> EKColor {
        return EKColor(light: light.withAlphaComponent(alpha),
                       dark: dark.withAlphaComponent(alpha))
    }
    
    /** White color for all user interface styles */
    static var white: EKColor {
        return EKColor(.white)
    }
    
    /** Black color for all user interface styles */
    static var black: EKColor {
        return EKColor(.black)
    }
    
    /** Clear color for all user interface styles */
    static var clear: EKColor {
        return EKColor(.clear)
    }
    
    /** Color that represents standard background. White for light mode, black for dark mode */
    static var standardBackground: EKColor {
        return EKColor(light: .white, dark: .black)
    }
    
    /** Color that represents standard content. black for light mode, white for dark mode */
    static var standardContent: EKColor {
        return EKColor(light: .black, dark: .white)
    }
}
