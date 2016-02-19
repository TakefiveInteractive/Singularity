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
    let minIndex = 9
    
    func sanitize(location: Int, reserveLocation: Int, elements: [Float]) -> Int {
        return location >= 0 && location < elements.count
            ? location
            : reserveLocation
    }
    
    func estimateLocation(magnitudeAt: Int -> Float, numBins: Int) -> UInt {
        let maxIndex = numBins - 1
        var maxHIndex = (numBins - 1) / harmonics
        
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
            if spectrum[i] > spectrum[max2] {
                max2 = i
            }
        }
        
        if abs(max2 * 2 - location) < 4 {
            if spectrum[max2] / spectrum[location] > 0.2 {
                location = max2
            }
        }

        return UInt(sanitize(location, reserveLocation: maxIndex, elements: spectrum))
    }
    
}