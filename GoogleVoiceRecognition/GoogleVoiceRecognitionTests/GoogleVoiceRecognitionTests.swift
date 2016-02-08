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
    
    func helperTestWithFile(fileName: String, lang: VoiceLanguages, verifier: String -> ()) {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print(NSBundle.mainBundle().description)
        let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "wav")
        let file = try! AVAudioFile(forReading: url!, commonFormat: AVAudioCommonFormat.PCMFormatInt16, interleaved: false)
        let format = AVAudioFormat(commonFormat: .PCMFormatInt16, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false)
        
        let buf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: UInt32(file.length))
        try! file.readIntoBuffer(buf)
        
        let asyncExpectation = expectationWithDescription("waiting for Google API in " + fileName)
        
        VoiceRecognition.recognize(buf, sampleRate: Int(file.fileFormat.sampleRate), lang: lang)
            .then { (hh: String) -> Void in
                verifier(hh)
                asyncExpectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { print($0) })
    }
    
    func testVoiceRecognitionNoMeizi() {
        helperTestWithFile("test-speech-meizi", lang: .Mandarin) { hh in
            XCTAssert(hh.containsString("妹子") && hh.containsString("我未来的"))
        }
    }
    
    func testVoiceRecognitionEnglish() {
        helperTestWithFile("good-morning", lang: .English) { hh in
            XCTAssert(hh.containsString("good morning") && hh.containsString("Google"))
        }
    }
    
    func testVoiceRecognitionMoha() {
        helperTestWithFile("moha", lang: .Mandarin) { hh in
            XCTAssert(hh.containsString("总想着搞个大新闻"))
        }
    }
    
}
