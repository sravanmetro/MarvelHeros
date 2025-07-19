//
//  MarvelHerosTests.swift
//  MarvelHerosTests
//
//  Created by Sravan on 16/07/2025.
//

import XCTest
@testable import MarvelHeros

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
    
    func testHerosFetchSuccess() async throws {
        let sut = try XCTUnwrap(self.sut)
        XCTAssertEqual(sut.state, .idle)
        await sut.fetchHeros()
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.state, .loaded)
        XCTAssertFalse(sut.heros.isEmpty)
        XCTAssertEqual(sut.heros.count, 5)
        // Verify hero data
        let firstHero = try XCTUnwrap(sut.heros.first)
        XCTAssertEqual(firstHero.name, "Captain America")
        XCTAssertEqual(firstHero.teamName, "Avengers")
        XCTAssertEqual(firstHero.realName, "Steve Rogers")
    }
    
    func testHerosEmptyResponse() async throws {
        let emptyService = EmptyHerosService()
        sut = HerosViewModel(service: emptyService)
        let sut = try XCTUnwrap(self.sut)
        XCTAssertEqual(sut.state, .idle)
        await sut.fetchHeros()
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.state, .empty)
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosNetworkError() async throws {
        let errorService = ErrorHerosService()
        sut = HerosViewModel(service: errorService)
        let sut = try XCTUnwrap(self.sut)
        XCTAssertEqual(sut.state, .idle)
        await sut.fetchHeros()
        XCTAssertNotNil(sut)
        if case .error(let msg) = sut.state {
            XCTAssertEqual(msg, "Invalid URL")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosCancelFetch() async throws {
        // Create a service that simulates a long operation
        let delayedService = DelayedHerosService()
        sut = HerosViewModel(service: delayedService)
        let sut = try XCTUnwrap(self.sut)
        XCTAssertEqual(sut.state, .idle)
        // Start the fetch operation
        let task = Task { 
            await sut.fetchHeros()
        }
        // Give it a moment to start
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        // Cancel the task
        task.cancel()
        // Wait for completion
        _ = await task.result
        // Verify the cancellation effects
        XCTAssertTrue(sut.heros.isEmpty)
        if case .error(let msg) = sut.state {
            XCTAssertEqual(msg, "An unknown error occurred")
        } else {
            XCTFail("Expected error state after cancellation")
        }
    }
    func testAppStateIdle() {
        let sut = HerosViewModel(service: OfflineHerosService())
        XCTAssertEqual(sut.state, .idle)
    }
    
    func testHeroModelCodable() throws {
        let heroJSON = """
        {
            "name": "Iron Man",
            "team": "Avengers",
            "realname": "Tony Stark",
            "firstappearance": "1963",
            "createdby": "Stan Lee",
            "publisher": "Marvel Comics",
            "imageurl": "https://example.com/ironman.jpg"
        }
        """
        
        let data = try XCTUnwrap(heroJSON.data(using: .utf8))
        let hero = try JSONDecoder().decode(Hero.self, from: data)
        
        XCTAssertEqual(hero.name, "Iron Man")
        XCTAssertEqual(hero.teamName, "Avengers")
        XCTAssertEqual(hero.realName, "Tony Stark")
        XCTAssertEqual(hero.imageURL, "https://example.com/ironman.jpg")
    }
    
    func testHeroModelDecodingFailures() throws {
        // Test missing required field
        let missingFieldJSON = """
        {
            "name": "Iron Man",
            "realname": "Tony Stark",
            "firstappearance": "1963",
            "createdby": "Stan Lee",
            "publisher": "Marvel Comics",
            "imageurl": "https://example.com/ironman.jpg"
        }
        """
        
        let missingFieldData = try XCTUnwrap(missingFieldJSON.data(using: .utf8))
        XCTAssertThrowsError(try JSONDecoder().decode(Hero.self, from: missingFieldData)) { error in
            guard let decodingError = error as? DecodingError else {
                XCTFail("Expected DecodingError")
                return
            }
            
            if case .keyNotFound(let key, _) = decodingError {
                XCTAssertEqual(key.stringValue, "team")
            } else {
                XCTFail("Expected .keyNotFound error")
            }
        }
        
        // Test invalid type
        let invalidTypeJSON = """
        {
            "name": "Iron Man",
            "team": 42,
            "realname": "Tony Stark",
            "firstappearance": "1963",
            "createdby": "Stan Lee",
            "publisher": "Marvel Comics",
            "imageurl": "https://example.com/ironman.jpg"
        }
        """
        
        let invalidTypeData = try XCTUnwrap(invalidTypeJSON.data(using: .utf8))
        XCTAssertThrowsError(try JSONDecoder().decode(Hero.self, from: invalidTypeData)) { error in
            guard let decodingError = error as? DecodingError else {
                XCTFail("Expected DecodingError")
                return
            }
            
            if case .typeMismatch = decodingError {
                // Success
            } else {
                XCTFail("Expected .typeMismatch error")
            }
        }
        
        // Test malformed JSON
        let malformedJSON = "{ invalid json }"
        let malformedData = try XCTUnwrap(malformedJSON.data(using: .utf8))
        XCTAssertThrowsError(try JSONDecoder().decode(Hero.self, from: malformedData)) { error in
            XCTAssertTrue(error is DecodingError, "Expected DecodingError for malformed JSON")
        }
        
        // Test empty data
        let emptyData = Data()
        XCTAssertThrowsError(try JSONDecoder().decode(Hero.self, from: emptyData)) { error in
            XCTAssertTrue(error is DecodingError, "Expected DecodingError for empty data")
        }
    }
}
