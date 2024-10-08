//
//  VGPlayerCacheConfiguration.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation

 class VGPlayerCacheConfiguration: NSObject {
    
     var maxCacheAge: TimeInterval = 60 * 60 * 24 * 7 // 1 week
    
    /// The maximum size of the cache, in bytes.
     var maxCacheSize: UInt = 0
}
