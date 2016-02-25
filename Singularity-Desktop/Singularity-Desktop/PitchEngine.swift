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
import PromiseKit
import Scoresmith
import SingularityLib
import GoogleVoiceRecognition
import Hyphenator

infix operator >>= { associativity left precedence 140 }

class PitchEngine: NSObject, EZMicrophoneDelegate, EZAudioFFTDelegate {
    
    var microphone: EZMicrophone?
    var fft: EZAudioFFTRolling?
    
    var histFrequencies: [Frequency]?
    var onNewNote: ((NSImage) -> ())?
    var language: VoiceLanguages = .English
    var rateTracker: RateTracker?
    
    var estimator = HPSEstimator()
    var noteEngine = NoteEngine()
    var scoreEngine = ScoreEngine()
    var movingModeL1 = MovingMode<Float>(window: 27)
    var movingModeL2 = MovingMode<Float>(window: 51)
    
    let SampleRate: Double = 44100
    let FFTWindowSize: UInt = 8192
    let MinimumMagnitude: Float = 0.008
    var audioCounter = 0
    
    var bpm: Float?
    
    var rawMicData = NSMutableData()
    
    private let pitchProcessingQueue = dispatch_queue_create("pitch-worker", DISPATCH_QUEUE_CONCURRENT)
    
    override init() {
        super.init()
        
        // Enumerate Audio devices
        let devices = EZAudioDevice.inputDevices()
        let bestMicrophone = devices.filter({ ($0 as! EZAudioDevice).manufacturer.containsString("BADAAX") }).first ?? devices.first
        
        microphone = EZMicrophone(microphoneDelegate: self)
        microphone?.device = bestMicrophone! as! EZAudioDevice
        
        // Record 32-bit float PCM by default
        let audioFormat = AVAudioFormat(commonFormat: .PCMFormatFloat32, sampleRate: SampleRate, channels: 1, interleaved: false)
        var asbd = audioFormat.streamDescription.memory
        asbd.mSampleRate = SampleRate
        microphone!.setAudioStreamBasicDescription(asbd)
    }
    
    func start(bpm: Float) {
        histFrequencies = []
        rateTracker = RateTracker()
        self.bpm = bpm
        rawMicData = NSMutableData()
        audioCounter = 0
        estimator = HPSEstimator()
        
        fft = EZAudioFFTRolling(
            windowSize: FFTWindowSize,
            historyBufferSize: FFTWindowSize * 8,
            sampleRate: Float(microphone!.audioStreamBasicDescription().mSampleRate),
            delegate: self)
        
        microphone?.startFetchingAudio()
    }
    
    func stop() {
        microphone?.stopFetchingAudio()
    }
    
    var fftCounter = 0
    
    func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer {
        let audioFormat = AVAudioFormat(commonFormat: .PCMFormatInt16, sampleRate: SampleRate, channels: 1, interleaved: false)
        let PCMBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: UInt32(data.length) / audioFormat.streamDescription.memory.mBytesPerFrame)
        PCMBuffer.frameLength = PCMBuffer.frameCapacity
        let channels = UnsafeBufferPointer(start: PCMBuffer.int16ChannelData, count: Int(PCMBuffer.format.channelCount))
        data.getBytes(UnsafeMutablePointer<Void>(channels[0]), length: data.length)
        
        return PCMBuffer
    }
    
    var ourLyrics = ""
    let hyphenator = Hyphenator()
    
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        let maxLocation = estimator.estimateLocation(
            { fft.frequencyMagnitudeAtIndex(UInt($0)) },
            frequencyAt: { fft.frequencyAtIndex(UInt($0)) },
            numBins: Int(bufferSize))
        let magnitude = fft.frequencyMagnitudeAtIndex(maxLocation)
        let maxFrequency = maxLocation
            >>= { fft.frequencyAtIndex($0) }
            >>= { self.movingModeL1.update($0) }
            >>= { self.movingModeL2.update($0) }
        
        if magnitude > MinimumMagnitude {
            //print(maxFrequency)
            histFrequencies?.append(.Freq(maxFrequency))
        } else {
            histFrequencies?.append(.VolumeLow)
        }
        
        if let bpm = bpm, histFrequencies = histFrequencies, pitchPerSecond = rateTracker?.update(NSDate().timeIntervalSince1970) {
            fftCounter += 1
            let everyNSeconds = { n in self.fftCounter % (Int(pitchPerSecond) * n) == 0 }
            
            if everyNSeconds(6) {
                dispatch_promise(on: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    return self.noteEngine.pitchToNote(
                        histFrequencies,
                        bpm: bpm,
                        pitchPerSecond: Float(pitchPerSecond))
                    }
                    .then { self.scoreEngine.makeScore($0, lyrics: self.processLyrics(self.ourLyrics)) }
                    .then { self.onNewNote?($0) }
            }
            
            if everyNSeconds(4) {
                VoiceRecognition.recognize(toPCMBuffer(rawMicData), sampleRate: Int(SampleRate), lang: language)
                    .then { self.ourLyrics = $0 }
            }
        }
    }
    
    func processLyrics(lyrics: String) -> String {
        if language == .English {
            return lyrics.componentsSeparatedByString(" ") .map { self.hyphenator.hyphenate_word($0).joinWithSeparator(" -- ") }.joinWithSeparator(" ")
        } else {
            return lyrics.characters.map { x in String(x) }.joinWithSeparator(" ")
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        // perform FFT calculation.
        fft?.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
        // Resample 32-bit float to 16-bit int
        var intSlice = [Int16](count: Int(bufferSize), repeatedValue: 0)
        for i in 0..<Int(bufferSize) {
            intSlice[i] = Int16(max(-32768, min(32767, Int(buffer[0][i] * 32767))))
        }
        rawMicData.appendBytes(&intSlice, length: Int(bufferSize * 2))
        
        // plot audio here
    }
}
