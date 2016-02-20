//
//  File.swift
//  SingularityLib
//
//  Created by Yifei Teng on 2/20/16.
//  Copyright © 2016 Yifei Teng. All rights reserved.
//

// linear processor
infix operator >>= { associativity left precedence 140 }

public func >>= <T, R> (input: T, processor: (T) -> (R)) -> R {
    return processor(input)
}