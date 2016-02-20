//
//  PowerNotation.swift
//  SingularityLib
//
//  Created by Yifei Teng on 2/20/16.
//  Copyright © 2016 Yifei Teng. All rights reserved.
//

/// Exponentiation operator
infix operator ** { associativity left precedence 170 }

public func ** (num: Float, power: Float) -> Float {
    return Float(pow(Double(num), Double(power)))
}
