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

public class NoteEngine {
    
    public init() {
        
    }
    
    public func pitchToNote(pitches: [Frequency], bpm: Float, pitchPerSecond: Float) -> [Note] {
        return []
    }
}
