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
}
