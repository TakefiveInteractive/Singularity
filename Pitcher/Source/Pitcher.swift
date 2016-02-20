//
//  File.swift
//  Pitcher
//
//  Created by Yifei Teng on 2/18/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation
import MusicKit

public enum Duration {
    case Whole
    case Half
    case Quarter
    case Eigth
}

public typealias Note = (Pitch, Duration)

public enum Frequency {
    case Freq(Float)
    case VolumeLow
}

/// Exponentiation operator
infix operator ** { associativity left precedence 170 }

func ** (num: Float, power: Float) -> Float {
    return Float(pow(Double(num), Double(power)))
}

public class NoteEngine {
    
    public init() {
        
    }
    
    public func pitchToNote(pitches: [Frequency], bpm: Float, pitchPerSecond: Float) -> [Note] {
        // Select best tuning standard frequency
        // Start from C2
        
        // Make a semitone sequence from D2
        var sequence: Array<Pitch> = []
        let semitone = Scale.Chromatic
        for octave: UInt in 2...4 {
            let D = Pitch(chroma: .D, octave: octave)
            sequence += Array(semitone(D))
        }
        
        var bestError: Float = 100000.0
        var bestConcertA = 440
        for concertA in 430...450 {
            MusicKit.concertA = Double(concertA)
            var error: Float = 0.0
            for case let Frequency.Freq(freq) in pitches {
                let closestStandardFreq = sequence
                    .map({ ($0.frequency - freq) ** 2 })
                    .minElement()!
                error += closestStandardFreq
            }
            if error < bestError {
                bestError = error
                bestConcertA = concertA
            }
        }
        print("Best concert pitch: \(bestConcertA)")
        MusicKit.concertA = Double(bestConcertA)
        
        return []
    }
}
