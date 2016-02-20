//
//  Ring.swift
//
//  Copyright (c) 2014 Pelfunc, Inc. All rights reserved.
//

/// Allow iteration of Ring<T> in LIFO order

public struct RingGenerator<T> : GeneratorType {
    
    public mutating func next() -> T?
    {
        if remainingCount > 0 {
            let value = buffer[index%buffer.count]
            --remainingCount
            ++index
            return value
        }
        return nil
    }
    
    private init(_ ring:Ring<T>!) {
        buffer = ring.buffer
        remainingCount = ring.storedCount
        index = (ring.count-remainingCount) % ring.capacity
    }
    
    private let buffer:[T]
    private var index:Int
    private var remainingCount:Int
}

/// A ring keeps track of the last n objects where n is set
/// using capacity.  The ring can be iterated on in LIFO
/// order.
public class Ring<T> : SequenceType {
    
    /// Where the buffer is stored.
    final private var buffer:[T] = []
    
    /// The total number of times add() has been called since
    /// init or the last reset.
    public private(set) var count:Int = 0
    
    /// The number of objects this ring can store.
    public var capacity:Int = 0
    
    /// The number of objects store in the ring.
    public var storedCount:Int {
        return min(count, capacity)
    }
    
    /// Create an empty ring with the specified capacity
    /// @requires capacity must be > 0
    public init(capacity:Int) {
        assert(capacity > 0)
        self.capacity = capacity
    }
    
    /// Add value to the ring.
    public func add(value:T) {
        if !isFull {
            buffer.append(value)
        }
        else {
            buffer[count % buffer.count] = value
        }
        ++count
    }
    
    /// The value that will be removed when a new values is
    /// added to the ring.
    public var willRemoveValue:T? {
        if isFull {
            let index = (count-storedCount) % capacity
            return buffer[index]
        }
        return nil
    }
    
    /// Set the storedCount to zero.
    public func reset() {
        count = 0
        buffer = []
    }
    
    /// Return true if the ring is empty
    public var isEmpty:Bool {
        return count == 0
    }
    
    /// Return true if the ring is full and newly added values will bump out old ones.
    public var isFull:Bool {
        return count >= capacity
    }
    
    /// Allow iteration from oldest to newest value.
    public func generate() -> RingGenerator<T> {
        return RingGenerator(self)
    }
    
    public var first: T? {
        if isEmpty { return nil }
        return buffer[(count - 1) % buffer.count]
    }
    
    public var last: T? {
        if isEmpty { return nil }
        return buffer[(count - storedCount) % capacity]
    }
}
