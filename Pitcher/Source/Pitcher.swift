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

public enum MusicElement {
    case Play(Pitch)
    case Rest
}

public typealias Note = (MusicElement, Duration)

public enum Frequency {
    case Freq(Float)
    case VolumeLow
}

/// Exponentiation operator
infix operator ** { associativity left precedence 170 }

func ** (num: Float, power: Float) -> Float {
    return Float(pow(Double(num), Double(power)))
}

// linear processor
infix operator >>= { associativity left precedence 140 }
func >>= <T, R> (input: T, processor: (T) -> (R)) -> R {
    return processor(input)
}

public class NoteEngine {
    
    public init() {
        
    }
    
    public func pitchToNote(pitches: [Frequency], bpm: Float, pitchPerSecond: Float) -> [Note] {
        // Select best tuning standard frequency that fits the frequency sequence
        // Start from D2
        
        // Make a semitone sequence from D2
        var sequence: Array<Pitch> = []
        let semitone = Scale.Chromatic
        for octave: UInt in 2...4 {
            let D = Pitch(chroma: .D, octave: octave)
            sequence += Array(semitone(D))
        }
        
        var bestError: Float = 100000.0
        var bestConcertA = 440
        for concertA in 425...455 {
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
        // print("Best concert pitch: \(bestConcertA)")
        MusicKit.concertA = Double(bestConcertA)
        
        // Convert frequencies to notes/rest
        let notes: [MusicElement] = pitches
            .map({ pitch in
                switch pitch {
                case let .Freq(freq):
                    return sequence
                        .minElement({ (a: Pitch, b: Pitch) -> Bool in (a.frequency - freq) ** 2 - (b.frequency - freq) ** 2 < 0})!
                        >>= { MusicElement.Play($0) }
                case .VolumeLow:
                    return .Rest
                }
            })
     
        print(notes)
        
        return []
    }
}
