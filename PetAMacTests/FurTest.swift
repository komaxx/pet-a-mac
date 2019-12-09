//
//  FurTest.swift
//  PetAMacTests
//
//  Created by Matthias Schicker on 24.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import XCTest

class FurTest: XCTestCase {
    var sut : Fur!
    
    override func setUp() {
        super.setUp()
        sut = Fur()
    }
    
    func testZeroRuffling() {
        XCTAssertEqual(0, sut.ruffleAt(xPos: 0))
        XCTAssertEqual(0, sut.ruffleAt(xPos: 0.5))
        XCTAssertEqual(0, sut.ruffleAt(xPos: 1))
        XCTAssertEqual(0, sut.ruffleAt(xPos: -1))
        XCTAssertEqual(0, sut.ruffleAt(xPos: 3))
    }

    func testSmooting() {
        sut.petAt(xPos: 0.4, delta: 0.1)
        sut.petAt(xPos: 0.5, delta: 0.1)
        sut.petAt(xPos: 0.6, delta: 0.1)
        
        XCTAssertTrue(sut.ruffleAt(xPos: 0.5) > 0)
    }

    func testRuffling() {
        sut.petAt(xPos: 0.4, delta: -0.1)
        sut.petAt(xPos: 0.5, delta: -0.1)
        sut.petAt(xPos: 0.6, delta: -0.1)
        
        XCTAssertTrue(sut.ruffleAt(xPos: 0.5) < 0)
    }
    
    func testNeutralizing() {
        sut.petAt(xPos: 0.4, delta: 0.1)
        sut.petAt(xPos: 0.5, delta: 0.1)
        sut.petAt(xPos: 0.6, delta: 0.1)
        
        let beforeSmoothState = sut.ruffleAt(xPos: 0.5)
        sut.tick(timeDelta: 1)
        sut.tick(timeDelta: 1)
        sut.tick(timeDelta: 1)
        let afterSmoothState = sut.ruffleAt(xPos: 0.5)
        
        XCTAssertTrue(beforeSmoothState > afterSmoothState)
    }
}
