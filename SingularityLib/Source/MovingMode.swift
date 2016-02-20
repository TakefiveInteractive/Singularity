//
//  MovingMode.swift
//  Singularity-Desktop
//
//  Created by Yifei Teng on 2/18/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

public class MovingMode<T where T: Hashable, T: Equatable> {
    
    var ring: Ring<T>!
    
    public init(window: Int) {
        ring = Ring<T>(capacity: window)
    }
    
    public func update(val: T) -> T {
        ring.add(val)
        var hash = [T : Int]()
        ring.forEach({ key in if let val = hash[key] { hash[key] = val + 1 } else { hash[key] = 1 } })
        let (key, _) = hash.maxElement { $0.1 < $1.1 }!
        return key
    }
    
}