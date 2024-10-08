//
//  EKAttributes+Animation.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/21/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

// A protocol that describes an animation
protocol EKAnimation {
    var delay: TimeInterval { get set }
    var duration: TimeInterval { get set }
    var spring: EKAttributes.Animation.Spring? { get set }
}

// A protocol that describes a range animation
protocol EKRangeAnimation: EKAnimation {
    var start: CGFloat { get set }
    var end: CGFloat { get set }
}

 extension EKAttributes {
    
    /** Describes an animation that can be performed on the entry */
    struct Animation: Equatable {
    
        /** Describes properties for a spring animation that can be performed on the entry */
         struct Spring: Equatable {
            
            /** The dampic of the spring animation */
             var damping: CGFloat
            
            /** The initial velocity of the spring animation */
             var initialVelocity: CGFloat
            
            /** Initializer */
             init(damping: CGFloat, initialVelocity: CGFloat) {
                self.damping = damping
                self.initialVelocity = initialVelocity
            }
        }

        /** Describes an animation with range */
         struct RangeAnimation: EKRangeAnimation, Equatable {
            
            /** The duration of the range animation */
             var duration: TimeInterval
            
            /** The delay of the range animation */
             var delay: TimeInterval
            
            /** The start value of the range animation (e.g. alpha, scale) */
             var start: CGFloat
            
            /** The end value of the range animation (e.g. alpha, scale) */
             var end: CGFloat
            
            /** The spring of the animation */
             var spring: Spring?
            
            /** Initializer */
             init(from start: CGFloat, to end: CGFloat, duration: TimeInterval, delay: TimeInterval = 0, spring: Spring? = nil) {
                self.start = start
                self.end = end
                self.delay = delay
                self.duration = duration
                self.spring = spring
            }
        }
        
        /** Describes translation animation */
         struct Translate: EKAnimation, Equatable {
            
            /** Describes the anchor position */
             enum AnchorPosition: Equatable {
                
                /** Top position - the entry shows from top or exits towards the top */
                case top
                
                /** Bottom position - the entry shows from bottom or exits towards the bottom */
                case bottom
                
                /** Automatic position - the entry shows and exits according to EKAttributes.Position value. If the position of the entry is top, bottom, the entry's translation anchor is top, bottom - respectively.*/
                case automatic
            }
            
            /** Animation duration */
             var duration: TimeInterval
            
            /** Animation delay */
             var delay: TimeInterval
            
            /** To where OR from the entry is animated */
             var anchorPosition: AnchorPosition
            
            /** Optional translation spring */
             var spring: Spring?

            /** Initializer */
             init(duration: TimeInterval, anchorPosition: AnchorPosition = .automatic, delay: TimeInterval = 0, spring: Spring? = nil) {
                self.anchorPosition = anchorPosition
                self.duration = duration
                self.delay = delay
                self.spring = spring
            }
        }
        
        /** Translation animation prop */
         var translate: Translate?
        
        /** Scale animation prop */
         var scale: RangeAnimation?
        
        /** Fade animation prop */
         var fade: RangeAnimation?
        
        /** Does the animation contains translation */
         var containsTranslation: Bool {
            return translate != nil
        }
        
        /** Does the animation contains scale */
         var containsScale: Bool {
            return scale != nil
        }
        
        /** Does the animation contains fade */
         var containsFade: Bool {
            return fade != nil
        }
        
        /** Does the animation contains any animation whatsoever */
         var containsAnimation: Bool {
            return containsTranslation || containsScale || containsFade
        }
        
        /** Returns the maximum delay amongst all animations */
         var maxDelay: TimeInterval {
            return max(translate?.delay ?? 0, max(scale?.delay ?? 0, fade?.delay ?? 0))
        }
        
        /** Returns the maximum duration amongst all animations */
         var maxDuration: TimeInterval {
            return max(translate?.duration ?? 0, max(scale?.duration ?? 0, fade?.duration ?? 0))
        }
        
        /** Returns the maximum (duration+delay) amongst all animations */
         var totalDuration: TimeInterval {
            return maxDelay + maxDuration
        }
        
        /** Returns the maximum (duration+delay) amongst all animations */
         static var translation: Animation {
            return Animation(translate: .init(duration: 0.3))
        }
        
        /** No animation at all */
         static var none: Animation {
            return Animation()
        }
        
        /** Initializer */
         init(translate: Translate? = nil, scale: RangeAnimation? = nil, fade: RangeAnimation? = nil) {
            self.translate = translate
            self.scale = scale
            self.fade = fade
        }
    }
}
