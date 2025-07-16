//
//  MarvelHerosTests.swift
//  MarvelHerosTests
//
//  Created by Sravan on 16/07/2025.
//

import Testing
@testable import MarvelHeros

struct MarvelHerosTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

import XCTest
class HerosViewModelTests: XCTestCase {
    var sut: HerosViewModel?
    
    override func setUp() {
        super.setUp()
        sut = HerosViewModel(service: OfflineHerosService())
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testHeros() async throws {
        let sut = try XCTUnwrap(self.sut)
        await sut.fetchHeros()
        
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.heros.isEmpty)
        XCTAssertEqual(sut.heros.count, 5)
    }
}
