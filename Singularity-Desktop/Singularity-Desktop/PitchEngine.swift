//
//  FFT.swift
//  Singularity-Desktop
//
//  Created by Yifei Teng on 2/18/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Foundation
import EZAudio
import MusicKit
import Pitcher
import Scoresmith

infix operator >>= { associativity left precedence 140 }
func >>= <T, R> (input: T, processor: (T) -> (R)) -> R {
    return processor(input)
}

class PitchEngine: NSObject, EZMicrophoneDelegate, EZAudioFFTDelegate {
    
    var microphone: EZMicrophone?
    var fft: EZAudioFFT?
    
    var histFrequencies: [Float]?
    var onNewNote: (([Pitch]) -> ())?
    
    var estimator = HPSEstimator()
    var noteEngine = NoteEngine()
    var scoreEngine = ScoreEngine()
    var movingMode = MovingMode<Float>(window: 7)
    
    let FFTWindowSize: UInt = 8192
    
    var bpm: Float?
    var pitchPerSecond: Float?
    
    override init() {
        super.init()
        
        microphone = EZMicrophone(microphoneDelegate: self)
        fft = EZAudioFFTRolling(
            windowSize: FFTWindowSize,
            sampleRate: Float(microphone!.audioStreamBasicDescription().mSampleRate),
            delegate: self)
    }
    
    func start(bpm: Float) {
        histFrequencies = []
        self.bpm = bpm
        
        microphone?.startFetchingAudio()
    }
    
    func stop() {
        microphone?.stopFetchingAudio()
    }
    
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        let maxFrequency =
            estimator.estimateLocation({ fft.frequencyMagnitudeAtIndex(UInt($0)) }, numBins: Int(bufferSize))
                >>= { fft.frequencyAtIndex($0) }
                >>= { self.movingMode.update($0) }
        
        histFrequencies?.append(maxFrequency)
        if let bpm = bpm, histFrequencies = histFrequencies, pitchPerSecond = pitchPerSecond {
            let notes = noteEngine.pitchToNote(
                histFrequencies,
                bpm: bpm,
                pitchPerSecond: pitchPerSecond)
            
            scoreEngine.makeScore(notes)
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        // perform FFT calculation
        fft?.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
        // plot audio here
    }
}
