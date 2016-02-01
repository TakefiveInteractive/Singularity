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
        let format = AVAudioFormat(commonFormat: .PCMFormatInt16, sampleRate: 44100.0, channels: 1, interleaved: false)
        let file = try! AVAudioFile(forReading: url!, commonFormat: AVAudioCommonFormat.PCMFormatInt16, interleaved: false)
        
        let buf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: UInt32(file.length))
        try! file.readIntoBuffer(buf)
        
        let asyncExpectation = expectationWithDescription("waiting for Google API")
        
        let bla : UnsafePointer<AudioTimeStamp> = UnsafePointer<AudioTimeStamp>(calloc(1, Int(sizeof(AudioTimeStamp))))
        VoiceRecognition.recognize(buf, atTime: AVAudioTime(audioTimeStamp: bla, sampleRate: 44100.0), lang: .Mandarin)
        .then { (hh: String) -> Void in
            XCTAssert(hh.containsString("妹子") && hh.containsString("我未来的"))
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { print($0) })
    }
    
}
