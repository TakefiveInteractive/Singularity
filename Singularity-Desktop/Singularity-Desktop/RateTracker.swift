//
//  RateTracker.swift
//  Singularity-Desktop
//
//  Created by Yifei Teng on 2/19/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation

class RateTracker {
    
    var ring: Ring<NSTimeInterval> = Ring(capacity: 200)
    
    init() {
        
    }
    
    func update(currTime: NSTimeInterval) -> Double? {
        ring.add(currTime)
        
        let newest = ring.first
        let oldest = ring.last
        
        if let oldest = oldest, newest = newest {
            if oldest == newest || ring.storedCount <= 1 {
                return nil
            } else {
                return Double(ring.storedCount - 1) / (newest - oldest)
            }
        }
        return nil
    }
    
}