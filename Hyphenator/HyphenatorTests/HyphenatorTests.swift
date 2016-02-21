//
//  HyphenatorTests.swift
//  HyphenatorTests
//
//  Created by Yifei Teng on 1/30/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import XCTest
@testable import Hyphenator

class HyphenatorTests: XCTestCase {
    
    var hyp: Hyphenator?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        hyp = Hyphenator()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        hyp = nil
    }
    
    func testSupercali() {
        XCTAssert(hyp!.hyphenate_word("supercalifragilisticexpialidocious") == ["su", "per", "cal", "ifrag", "ilis", "tic", "ex", "pi", "ali", "do", "cious"])
    }
    
    func testException() {
        XCTAssert(hyp!.hyphenate_word("associate") == ["as", "so", "ciate"])
    }
    
    func testHyphenation() {
        XCTAssert(hyp!.hyphenate_word("hyphenation") == ["hy", "phen", "ation"])
    }
    
}
