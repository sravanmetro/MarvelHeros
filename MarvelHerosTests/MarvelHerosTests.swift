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
        await sut.fetchHeros()
        
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.error)
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
        
        await sut.fetchHeros()
        
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.error)
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosNetworkError() async throws {
        let errorService = ErrorHerosService()
        sut = HerosViewModel(service: errorService)
        let sut = try XCTUnwrap(self.sut)
        
        await sut.fetchHeros()
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, "Invalid URL")
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosCancelFetch() async throws {
        // Create a service that simulates a long operation
        let delayedService = DelayedHerosService()
        sut = HerosViewModel(service: delayedService)
        let sut = try XCTUnwrap(self.sut)
        
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
        XCTAssertEqual(sut.error, "An unknown error occurred")
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
    
    func testHerosInvalidURLError() async throws {
        // Given
        let errorService = ErrorHerosService()
        sut = HerosViewModel(service: errorService)
        let sut = try XCTUnwrap(self.sut)
        
        // When
        await sut.fetchHeros()
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, "Invalid URL")
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosNoDataError() async throws {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockError = MarvelHerosError.noData
        let service = MarvelHerosService(networkManager: networkManager)
        sut = HerosViewModel(service: service)
        let sut = try XCTUnwrap(self.sut)
        
        // When
        await sut.fetchHeros()
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, "No data received")
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosParseError() async throws {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockData = "invalid json".data(using: .utf8)
        let service = MarvelHerosService(networkManager: networkManager)
        sut = HerosViewModel(service: service)
        let sut = try XCTUnwrap(self.sut)
        
        // When
        await sut.fetchHeros()
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, "Failed to parse data")
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosCancelledOperation() async throws {
        // Given
        let delayedService = DelayedHerosService()
        sut = HerosViewModel(service: delayedService)
        let sut = try XCTUnwrap(self.sut)
        
        // When
        let task = Task {
            await sut.fetchHeros()
        }
        task.cancel()
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.heros.isEmpty)
    }
    
    func testHerosUnknownError() async throws {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockError = NSError(domain: "test", code: -1)
        let service = MarvelHerosService(networkManager: networkManager)
        sut = HerosViewModel(service: service)
        let sut = try XCTUnwrap(self.sut)
        
        // When
        await sut.fetchHeros()
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, "An unknown error occurred")
        XCTAssertTrue(sut.heros.isEmpty)
    }
}
