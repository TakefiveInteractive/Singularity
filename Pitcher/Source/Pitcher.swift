//
//  File.swift
//  Pitcher
//
//  Created by Yifei Teng on 2/18/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation
import MusicKit
import SingularityLib

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

infix operator ** { associativity left precedence 170 }
infix operator >>= { associativity left precedence 140 }

extension MusicElement: Hashable, Equatable {
    public var hashValue: Int {
        switch self {
        case let .Play(pitch):
            return pitch.hashValue
        case .Rest:
            return 0
        }
    }
}

public func == (lhs: MusicElement, rhs: MusicElement) -> Bool {
    switch lhs {
    case let .Play(pitch):
        if case let .Play(pitch2) = rhs {
            return pitch == pitch2
        } else {
            return false
        }
    case .Rest:
        switch rhs {
        case .Rest:
            return true
        default:
            return false
        }
    }
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
                        .minElement { (a: Pitch, b: Pitch) -> Bool in (a.frequency - freq) ** 2 < (b.frequency - freq) ** 2}!
                        >>= { MusicElement.Play($0) }
                case .VolumeLow:
                    return .Rest
                }
            })
        
        // Identify duration
        var movingMode = MovingMode<MusicElement>(window: 5)
        let smoothNotes = notes.map { movingMode.update($0) }
        print(smoothNotes)
        
        return []
    }
}
