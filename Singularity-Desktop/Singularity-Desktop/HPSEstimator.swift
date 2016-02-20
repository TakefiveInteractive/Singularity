//
//  HPSEstimator.swift
//  Singularity-Desktop
//
//  Created by Yifei Teng on 2/18/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation

class HPSEstimator {
    
    let harmonics = 6
    let minIndex = 6
    
    var lastLocation: Int?
    var lastMagnitude: Float?
    
    func sanitize(location: Int, reserveLocation: Int, elements: [Float]) -> Int {
        return location >= 0 && location < elements.count
            ? location
            : reserveLocation
    }
    
    func estimateLocation(magnitudeAt: Int -> Float, frequencyAt: Int -> Float, numBins: Int) -> UInt {
        let maxIndex = numBins - 1
        var maxHIndex = (numBins - 1) / harmonics
        let withinBounds: Int -> Bool = { frequencyAt($0) < 700 && frequencyAt($0) > 90 }
        
        var spectrum: [Float] = []
        for var k = 0; k < numBins; k++ {
            spectrum.append(magnitudeAt(k))
        }
        
        if maxIndex < maxHIndex {
            maxHIndex = maxIndex
        }
        
        var location = minIndex
        
        for var j = minIndex; j <= maxHIndex; j++ {
            for var i = 1; i <= harmonics; i++ {
                spectrum[j] *= spectrum[j * i]
            }
            
            if spectrum[j] > spectrum[location] {
                location = j
            }
        }
        
        var max2 = minIndex
        let maxsearch = location * 3 / 4
        
        for var i = minIndex + 1; i < maxsearch; i++ {
            if spectrum[i] > spectrum[max2] && withinBounds(i) {
                max2 = i
            }
        }
        
        if abs(max2 * 2 - location) < 20 && withinBounds(max2) {
            if spectrum[max2] / spectrum[location] > 0.05 {
                location = max2
            }
        }
        
        if frequencyAt(location) >= 700 && withinBounds(max2) {
            location = max2
        }
        
        // hack
        if let lastLocation = lastLocation, lastMagnitude = lastMagnitude {
            if abs(lastLocation * 2 - location) < 10 && withinBounds(lastLocation) {
                if spectrum[lastLocation] / lastMagnitude > 0.7 {
                    // print("Save")
                    location = lastLocation
                }
            }
        }
        
        lastLocation = sanitize(location, reserveLocation: maxIndex, elements: spectrum)
        lastMagnitude = spectrum[lastLocation!]
        return UInt(lastLocation!)
    }
    
}