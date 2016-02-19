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

class FFT: NSObject, EZMicrophoneDelegate, EZAudioFFTDelegate {
    
    var microphone: EZMicrophone?
    var fft: EZAudioFFT?
    
    var histFrequencies: [Float]?
    var onNewNote: (([Pitch]) -> ())?
    
    var estimator = HPSEstimator()
    
    override init() {
        super.init()
        
        microphone = EZMicrophone(microphoneDelegate: self)
        fft = EZAudioFFTRolling(windowSize: 4096, sampleRate: Float(microphone!.audioStreamBasicDescription().mSampleRate), delegate: self)
    }
    
    func start() {
        microphone?.startFetchingAudio()
    }
    
    func stop() {
        microphone?.stopFetchingAudio()
    }
    
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        let maxFrequency = fft.frequencyAtIndex(estimator.estimateLocation({ fft.frequencyMagnitudeAtIndex(UInt($0)) }, numBins: Int(bufferSize)))
        
        // histFrequencies?.append(maxFrequency)
        
        print(maxFrequency)
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        // perform FFT calculation
        fft?.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
        // plot audio here
    }
}
