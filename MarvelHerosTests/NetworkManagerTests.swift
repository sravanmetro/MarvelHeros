//
//  NetworkManagerTests.swift
//  MarvelHeros
//
//  Created by Sravan on 17/07/2025.
//


import XCTest
@testable import MarvelHeros

// MARK: - Network Tests
class NetworkManagerTests: XCTestCase {
    var sut: NetworkManager!
    
    override func setUp() {
        super.setUp()
        sut = NetworkManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInvalidURLError() async throws {
        // Create a network manager with an invalid base URL
        let networkManager = MockNetworkManager()
        networkManager.mockError = MarvelHerosError.invalidURL
        sut = networkManager
        
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected invalid URL error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.invalidURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNoDataError() async throws {
        // Create a network manager with no data
        let networkManager = MockNetworkManager()
        networkManager.mockError = MarvelHerosError.noData
        sut = networkManager
        
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected no data error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.noData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testParseError() async throws {
        // Create a network manager with invalid data
        let networkManager = MockNetworkManager()
        networkManager.mockData = "invalid json".data(using: .utf8)
        sut = networkManager
        
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected parse error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.parseError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSuccessfulDataFetch() async throws {
        // Given
        let networkManager = MockNetworkManager()
        let expectedHeros = [
            Hero(name: "Test Hero", teamName: "Test Team", realName: "Test Real Name", 
                 imageURL: "test.jpg", createdBy: "Test Creator", publisher: "Test Publisher", 
                 firstAppearance: "2025")
        ]
        let encodedData = try JSONEncoder().encode(expectedHeros)
        networkManager.mockData = encodedData
        sut = networkManager
        
        // When
        let result = try await sut.getData(endPoint: .heros, type: [Hero].self)
        
        // Then
        XCTAssertEqual(result.count, expectedHeros.count)
        XCTAssertEqual(result.first?.name, expectedHeros.first?.name)
        XCTAssertEqual(result.first?.teamName, expectedHeros.first?.teamName)
    }
    
    func testInvalidEndpoint() async {
        // Given
        let networkManager = MockNetworkManager()
        let invalidJSON = """
        {
            "invalid": "format",
            "notHeroData": true
        }
        """.data(using: .utf8)
        networkManager.mockData = invalidJSON
        sut = networkManager
        
        // Then
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected parse error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.parseError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testURLSessionError() async {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        sut = networkManager
        
        // Then
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected network error")
        } catch {
            XCTAssertEqual((error as NSError).domain, NSURLErrorDomain)
            XCTAssertEqual((error as NSError).code, NSURLErrorNotConnectedToInternet)
        }
    }
    
    func testHTTPResponseError() async {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockResponseCode = 404
        sut = networkManager
        
        // Then
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected HTTP error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.noData)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testServerError() async {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockResponseCode = 500
        sut = networkManager
        
        // Then
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected server error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.noData)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCancellation() async {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockDelay = 1.0 // 1 second delay
        sut = networkManager
        
        // When
        let task = Task {
            do {
                _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
                XCTFail("Expected cancellation")
            } catch {
                XCTAssertTrue(error is CancellationError)
            }
        }
        
        // Then
        task.cancel()
        _ = await task.result
    }
    
    func testEmptyResponseData() async {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockData = Data()
        sut = networkManager
        
        // Then
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected parse error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.parseError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testMalformedJSON() async {
        // Given
        let networkManager = MockNetworkManager()
        networkManager.mockData = "{malformed:json}".data(using: .utf8)
        sut = networkManager
        
        // Then
        do {
            _ = try await sut.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected parse error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.parseError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
