//
//  ScoresmithTests.swift
//  ScoresmithTests
//
//  Created by Yifei Teng on 1/30/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import XCTest
import Pitcher
import MusicKit
@testable import Scoresmith

class ScoresmithTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleTranscribe() {
        print(ScoreEngine().notesToLiliTex([
            (MusicElement.Play(Chroma.G * 2), Duration.Quarter),
            (MusicElement.Play(Chroma.A * 2), Duration.Quarter),
            (MusicElement.Play(Chroma.B * 2), Duration.Quarter),
            (MusicElement.Play(Chroma.C * 3), Duration.Quarter),
            (MusicElement.Play(Chroma.D * 3), Duration.Whole),
            (MusicElement.Rest, Duration.Whole),
        ]))
    }
    
}
