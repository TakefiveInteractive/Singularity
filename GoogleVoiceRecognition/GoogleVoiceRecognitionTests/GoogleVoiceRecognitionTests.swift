//
//  GoogleVoiceRecognitionTests.swift
//  GoogleVoiceRecognitionTests
//
//  Created by Yifei Teng on 1/30/16.
//  Copyright © 2016 Yifei Teng. All rights reserved.
//

import XCTest
import AVFoundation
@testable import GoogleVoiceRecognition

class GoogleVoiceRecognitionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVoiceRecognitionNoMeizi() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print(NSBundle.mainBundle().description)
        let url = NSBundle(forClass: self.dynamicType).URLForResource("test-speech-meizi", withExtension: "wav")
        let file = try! AVAudioFile(forReading: url!)
        let format = AVAudioFormat(commonFormat: .PCMFormatInt16, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false)
        
        let buf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: 44100 * 4)
        try! file.readIntoBuffer(buf)
        
        let asyncExpectation = expectationWithDescription("waiting for Google API")
        
        let bla : UnsafePointer<AudioTimeStamp> = UnsafePointer<AudioTimeStamp>(calloc(1, Int(sizeof(AudioTimeStamp))))
        VoiceRecognition.recognize(buf, atTime: AVAudioTime(audioTimeStamp: bla, sampleRate: 44100.0))
        .then { (hh: String) -> Void in
            print(hh)
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { print($0) })
    }
    
}
