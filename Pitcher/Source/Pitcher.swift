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

func toDuration(beat: Double) -> Duration {
    if beat >= 0.75 { return .Whole }
    if beat >= 0.375 { return .Half }
    if beat >= 0.1875 { return .Quarter }
    return .Eigth
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
        let movingMode = MovingMode<MusicElement>(window: 7)
        let smoothNotes = notes.map { movingMode.update($0) }
        let minimumBeat = (1.0 / 16.0 + 1.0 / 8.0) / 2.0
        let minimumElementCount = Int(minimumBeat / (Double(bpm) / 60.0) * Double(pitchPerSecond))
        let wholeBeatCount = Int(Double(pitchPerSecond) / (Double(bpm) / 60.0) * 4.0)      // assume 4/4 time
        print("Minimum elem count: \(minimumElementCount)")
        
        print(smoothNotes)
        
        let noteChunks = smoothNotes.reduce([(smoothNotes[0], 1)]) { (var noteChunks: [(MusicElement, Int)], curr: MusicElement) -> [(MusicElement, Int)] in
            let (lastElement, lastCount) = noteChunks.last!
            if curr == lastElement {
                noteChunks[noteChunks.count - 1] = (lastElement, lastCount + 1)
            } else {
                noteChunks.append((curr, 1))
            }
            return noteChunks
        }
        
        print(noteChunks)
        
        // filter out transient notes
        return noteChunks
        .filter { (elem, count) in count > minimumElementCount }
        .flatMap { (elem, count) -> [(MusicElement, Int)] in
            if count > wholeBeatCount {
                let partsNum = count / wholeBeatCount
                return [(MusicElement, Int)](count: partsNum, repeatedValue: (elem, wholeBeatCount))
            } else {
                return [(elem, count)]
            }
        }
            .map { (elem: MusicElement, count: Int) in (elem, toDuration(Double(count) / Double(pitchPerSecond) * (Double(bpm) / 60.0))) }
    }
}
