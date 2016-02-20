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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let hyp = Hyphenator()
        print(hyp.hyphenate_word("supercalifragilisticexpialidocious"))
        XCTAssert(hyp.hyphenate_word("supercalifragilisticexpialidocious") == ["su", "per", "cal", "ifrag", "ilis", "tic", "ex", "pi", "ali", "do", "cious"])
    }
    
}
