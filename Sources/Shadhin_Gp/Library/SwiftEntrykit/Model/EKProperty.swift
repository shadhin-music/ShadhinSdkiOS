//
//  EKProperty.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/19/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

 struct EKProperty {
    
    /** Button content descriptor */
     struct ButtonContent {
        
         typealias Action = () -> ()
        
        /** Button title label content descriptor */
         var label: LabelContent
        
        /** Button background color */
         var backgroundColor: EKColor
         var highlightedBackgroundColor: EKColor

        /** Content edge inset */
         var contentEdgeInset: CGFloat
        
        /** The display mode of the button */
         var displayMode: EKAttributes.DisplayMode
        
        /** Accessibility identifier that identifies the button */
         var accessibilityIdentifier: String?
        
        /** Action */
         var action: Action?
        
         init(label: LabelContent,
                    backgroundColor: EKColor,
                    highlightedBackgroundColor: EKColor,
                    contentEdgeInset: CGFloat = 5,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    accessibilityIdentifier: String? = nil,
                    action: @escaping Action = {}) {
            self.label = label
            self.backgroundColor = backgroundColor
            self.highlightedBackgroundColor = highlightedBackgroundColor
            self.contentEdgeInset = contentEdgeInset
            self.displayMode = displayMode
            self.accessibilityIdentifier = accessibilityIdentifier
            self.action = action
        }
        
         func backgroundColor(for traitCollection: UITraitCollection) -> UIColor {
            return backgroundColor.color(for: traitCollection, mode: displayMode)
        }
        
         func highlightedBackgroundColor(for traitCollection: UITraitCollection) -> UIColor {
            return highlightedBackgroundColor.color(for: traitCollection, mode: displayMode)
        }
        
         func highlighedLabelColor(for traitCollection: UITraitCollection) -> UIColor {
            return label.style.color.with(alpha: 0.8).color(
                for: traitCollection,
                mode: label.style.displayMode
            )
        }
    }
    
    /** Label content descriptor */
     struct LabelContent {
        
        /** The text */
         var text: String
        
        /** The label's style */
         var style: LabelStyle
        
        /** The label's accessibility ideentifier */
         var accessibilityIdentifier: String?
        
         init(text: String,
                    style: LabelStyle,
                    accessibilityIdentifier: String? = nil) {
            self.text = text
            self.style = style
            self.accessibilityIdentifier = accessibilityIdentifier
        }
    }
    
    /** Label style descriptor */
     struct LabelStyle {
        
        /** Font of the text */
         var font: UIFont
        
        /** Color of the text */
         var color: EKColor
        
        /** Text Alignment */
         var alignment: NSTextAlignment
        
        /** Number of lines */
         var numberOfLines: Int
        
        /** Display mode for the label */
         var displayMode: EKAttributes.DisplayMode
        
         init(font: UIFont,
                    color: EKColor,
                    alignment: NSTextAlignment = .left,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    numberOfLines: Int = 0) {
            self.font = font
            self.color = color
            self.alignment = alignment
            self.displayMode = displayMode
            self.numberOfLines = numberOfLines
        }
        
         func color(for traitCollection: UITraitCollection) -> UIColor {
            return color.color(for: traitCollection, mode: displayMode)
        }
    }
    
    /** Image View style descriptor */
     struct ImageContent {
        
        /** Repeated-reversed animation throughout the presentation of an image */
         enum TransformAnimation {
            case animate(duration: TimeInterval, options: UIView.AnimationOptions, transform: CGAffineTransform)
            case none
        }
        
        /** Tint color for the image/s */
         var tint: EKColor?
        
        /** The images */
         var images: [UIImage]
        
        /** Image sequence duration, if any */
         var imageSequenceAnimationDuration: TimeInterval
        
        /** Image View size - can be forced.
         If nil, then the image view hugs content and resists compression */
         var size: CGSize?
    
        /** Content mode */
         var contentMode: UIView.ContentMode
        
        /** Should the image be rounded */
         var makesRound: Bool
        
        /** Repeated-Reversed animation */
         var animation: TransformAnimation
        
        /** The display mode of the image */
         var displayMode: EKAttributes.DisplayMode
        
        /** Image accessibility identifier */
         var accessibilityIdentifier: String?
        
         init(imageName: String,
                    animation: TransformAnimation = .none,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    size: CGSize? = nil,
                    contentMode: UIView.ContentMode = .scaleToFill,
                    tint: EKColor? = nil,
                    makesRound: Bool = false,
                    accessibilityIdentifier: String? = nil) {
            let image = UIImage(named: imageName)!
            self.init(image: image,
                      displayMode: displayMode,
                      size: size,
                      tint: tint,
                      contentMode: contentMode,
                      makesRound: makesRound,
                      accessibilityIdentifier: accessibilityIdentifier)
        }
        
         init(image: UIImage,
                    animation: TransformAnimation = .none,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    size: CGSize? = nil,
                    tint: EKColor? = nil,
                    contentMode: UIView.ContentMode = .scaleToFill,
                    makesRound: Bool = false,
                    accessibilityIdentifier: String? = nil) {
            self.images = [image]
            self.size = size
            self.tint = tint
            self.displayMode = displayMode
            self.contentMode = contentMode
            self.makesRound = makesRound
            self.animation = animation
            self.imageSequenceAnimationDuration = 0
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
         init(images: [UIImage],
                    imageSequenceAnimationDuration: TimeInterval = 1,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    animation: TransformAnimation = .none,
                    size: CGSize? = nil,
                    tint: EKColor? = nil,
                    contentMode: UIView.ContentMode = .scaleToFill,
                    makesRound: Bool = false,
                    accessibilityIdentifier: String? = nil) {
            self.images = images
            self.size = size
            self.displayMode = displayMode
            self.tint = tint
            self.contentMode = contentMode
            self.makesRound = makesRound
            self.animation = animation
            self.imageSequenceAnimationDuration = imageSequenceAnimationDuration
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
         init(imagesNames: [String],
                    imageSequenceAnimationDuration: TimeInterval = 1,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    animation: TransformAnimation = .none,
                    size: CGSize? = nil,
                    tint: EKColor? = nil,
                    contentMode: UIView.ContentMode = .scaleToFill,
                    makesRound: Bool = false,
                    accessibilityIdentifier: String? = nil) {
            let images = imagesNames.map { return UIImage(named: $0)! }
            self.init(images: images,
                      imageSequenceAnimationDuration: imageSequenceAnimationDuration,
                      displayMode: displayMode,
                      animation: animation,
                      size: size,
                      tint: tint,
                      contentMode: contentMode,
                      makesRound: makesRound,
                      accessibilityIdentifier: accessibilityIdentifier)
        }
        
        /** Quick thumbail property generator */
         static func thumb(with image: UIImage,
                                 edgeSize: CGFloat) -> ImageContent {
            return ImageContent(images: [image],
                                size: CGSize(width: edgeSize, height: edgeSize),
                                contentMode: .scaleAspectFill,
                                makesRound: true)
        }
        
        /** Quick thumbail property generator */
         static func thumb(with imageName: String,
                                 edgeSize: CGFloat) -> ImageContent {
            return ImageContent(imagesNames: [imageName],
                                size: CGSize(width: edgeSize, height: edgeSize),
                                contentMode: .scaleAspectFill,
                                makesRound: true)
        }
        
         func tintColor(for traitCollection: UITraitCollection) -> UIColor? {
            return tint?.color(for: traitCollection, mode: displayMode)
        }
    }
    
    /** Text field content **/
     struct TextFieldContent {
        
        // NOTE: Intentionally a reference type
        class ContentWrapper {
            var text = ""
        }
        
         weak var delegate: UITextFieldDelegate?
         var keyboardType: UIKeyboardType
         var isSecure: Bool
         var leadingImage: UIImage!
         var placeholder: LabelContent
         var textStyle: LabelStyle
         var tintColor: EKColor!
         var displayMode: EKAttributes.DisplayMode
         var bottomBorderColor: EKColor
         var accessibilityIdentifier: String?
        let contentWrapper = ContentWrapper()
         var textContent: String {
            set {
                contentWrapper.text = newValue
            }
            get {
                return contentWrapper.text
            }
        }
        
         init(delegate: UITextFieldDelegate? = nil,
                    keyboardType: UIKeyboardType = .default,
                    placeholder: LabelContent,
                    tintColor: EKColor? = nil,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    textStyle: LabelStyle,
                    isSecure: Bool = false,
                    leadingImage: UIImage? = nil,
                    bottomBorderColor: EKColor = .clear,
                    accessibilityIdentifier: String? = nil) {
            self.delegate = delegate
            self.keyboardType = keyboardType
            self.placeholder = placeholder
            self.textStyle = textStyle
            self.tintColor = tintColor
            self.displayMode = displayMode
            self.isSecure = isSecure
            self.leadingImage = leadingImage
            self.bottomBorderColor = bottomBorderColor
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
         func tintColor(for traitCollection: UITraitCollection) -> UIColor? {
            return tintColor?.color(for: traitCollection, mode: displayMode)
        }
        
         func bottomBorderColor(for traitCollection: UITraitCollection) -> UIColor? {
            return bottomBorderColor.color(for: traitCollection, mode: displayMode)
        }
    }
    
    /** Button bar content */
     struct ButtonBarContent {
        
        /** Button content array */
         var content: [ButtonContent] = []
        
        /** The color of the separator */
         var separatorColor: EKColor
        
        /** Upper threshold for the number of buttons (*ButtonContent*) for horizontal distribution. Must be a positive value */
         var horizontalDistributionThreshold: Int
        
        /** Determines whether the buttons expands animately */
         var expandAnimatedly: Bool
        
        /** The height of each button. All are equally distributed in their axis */
         var buttonHeight: CGFloat
        
        /** The display mode of the button bar */
         var displayMode: EKAttributes.DisplayMode
        
         init(with buttonContents: ButtonContent...,
                    separatorColor: EKColor,
                    horizontalDistributionThreshold: Int = 2,
                    buttonHeight: CGFloat = 50,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    expandAnimatedly: Bool) {
            self.init(with: buttonContents,
                      separatorColor: separatorColor,
                      horizontalDistributionThreshold: horizontalDistributionThreshold,
                      buttonHeight: buttonHeight,
                      displayMode: displayMode,
                      expandAnimatedly: expandAnimatedly)
        }
        
         init(with buttonContents: [ButtonContent],
                    separatorColor: EKColor,
                    horizontalDistributionThreshold: Int = 2,
                    buttonHeight: CGFloat = 50,
                    displayMode: EKAttributes.DisplayMode = .inferred,
                    expandAnimatedly: Bool) {
            guard horizontalDistributionThreshold > 0 else {
                fatalError("horizontalDistributionThreshold Must have a positive value!")
            }
            self.separatorColor = separatorColor
            self.horizontalDistributionThreshold = horizontalDistributionThreshold
            self.buttonHeight = buttonHeight
            self.displayMode = displayMode
            self.expandAnimatedly = expandAnimatedly
            content.append(contentsOf: buttonContents)
        }
        
         func separatorColor(for traitCollection: UITraitCollection) -> UIColor {
            return separatorColor.color(for: traitCollection, mode: displayMode)
        }
    }
    
    /** Rating item content */
     struct EKRatingItemContent {
         var title: EKProperty.LabelContent
         var description: EKProperty.LabelContent
         var unselectedImage: EKProperty.ImageContent
         var selectedImage: EKProperty.ImageContent
         var size: CGSize
        
         init(title: EKProperty.LabelContent,
                    description: EKProperty.LabelContent,
                    unselectedImage: EKProperty.ImageContent,
                    selectedImage: EKProperty.ImageContent,
                    size: CGSize = CGSize(width: 50, height: 50)) {
            self.title = title
            self.description = description
            self.unselectedImage = unselectedImage
            self.selectedImage = selectedImage
            self.size = size
        }
    }
}
