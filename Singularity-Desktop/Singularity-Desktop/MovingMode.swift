//
//  MovingMode.swift
//  Singularity-Desktop
//
//  Created by Yifei Teng on 2/18/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation

protocol NumericType: Equatable, Comparable, Hashable {
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
    func %(lhs: Self, rhs: Self) -> Self
    init(_ v: Int)
}

extension Double  : NumericType {}
extension Int     : NumericType {}
extension Float   : NumericType {}

class MovingMode<T: NumericType> {
    
    var ring: Ring<T>!
    
    init(window: Int) {
        ring = Ring<T>(capacity: window)
    }
    
    func update(val: T) -> T {
        ring.add(val)
        var hash = [T : Int]()
        ring.forEach({ key in if let val = hash[key] { hash[key] = val + 1 } else { hash[key] = 1 } })
        let (key, _) = hash.maxElement { $0.0 < $1.0 }!
        return key
    }
    
}