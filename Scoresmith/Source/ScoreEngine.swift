//
//  ScoreEngine.swift
//  Scoresmith
//
//  Created by Yifei Teng on 2/19/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation
import MusicKit
import Pitcher
import PromiseKit

public class ScoreEngine {
    
    public init() {
        
    }
    
    public func notesToLiliTex(notes: [Note]) -> String {
        let notes_array_length = notes.count
        var return_string = ""
        var pitch_final = ""
        
        
        for array_number_count in 0..<notes_array_length {
            
            let rawnote = notes[array_number_count].0
            
            switch rawnote {
            case let .Play(pitch):
                let note_midi = pitch.midi
                //midi to note(lower letters conversion)
                let pitch_letter_raw = Int(note_midi % 12)
                let pitch_number = Int(note_midi/12 - Float(pitch_letter_raw)/12)
                var pitch_letter_final = ""
                
                switch pitch_letter_raw {
                case 0:
                    pitch_letter_final = "c"
                case 1:
                    pitch_letter_final = "cis"
                case 2:
                    pitch_letter_final = "d"
                case 3:
                    pitch_letter_final = "dis"
                case 4:
                    pitch_letter_final = "e"
                case 5:
                    pitch_letter_final = "f"
                case 6:
                    pitch_letter_final = "fis"
                case 7:
                    pitch_letter_final = "g"
                case 8:
                    pitch_letter_final = "gis"
                case 9:
                    pitch_letter_final = "a"
                case 10:
                    pitch_letter_final = "ais"
                case 11:
                    pitch_letter_final = "b"
                default:
                    pitch_letter_final = "ais"
                    //default is set to A# for debugging
                }
                pitch_final = pitch_letter_final + "\(String(count: pitch_number - 2, repeatedValue: Character("'")))"
                
            case .Rest:
                 pitch_final = "r"
            //default:
            //    break
            }
            
            let rawduration = notes[array_number_count].1

            var duration_final = 0
            switch rawduration{
            case .Whole:
                duration_final = 1
            case .Half:
                duration_final = 2
            case .Quarter:
                duration_final = 4
            case .Eigth:
                duration_final = 8
                //default:
                //  duration_final = 128
                //error detection
            }
            return_string += (" " + pitch_final + "\(duration_final)")
            
        }
        return return_string

    }
    
    public func makeScore(notes: [Note]) -> Promise<NSImage> {
        return Promise { resolve, reject in
        }
    }
    
}