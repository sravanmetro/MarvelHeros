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
    
    func testURLConstruction() async throws {
        // Given
        let expectedURL = URL(string: Constants.baseURL + NetworkManager.EndPoint.heros.rawValue)!
        let testData = "[]".data(using: .utf8)!
        
        // Set up URLProtocol mock
        URLProtocolMock.mockData = testData
        URLProtocolMock.mockResponse = HTTPURLResponse(
            url: expectedURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        
        let networkManager = NetworkManagerWithCustomSession(config: config)
        
        // When
        _ = try await networkManager.getData(endPoint: .heros, type: [Hero].self)
        
        // Then
        XCTAssertEqual(URLProtocolMock.lastRequest?.url, expectedURL)
    }
    
//    func testURLConstructionWithInvalidBaseURL() async throws {
//        // Given
//        let invalidBaseURLs = [
//            "",                    // Empty URL
//            "not a url",          // Invalid format
//            "http://.com",        // Missing host
//            "\\invalid\\path",    // Invalid characters
//            "ftp://invalid.com"   // Unsupported scheme
//        ]
//        
//        for invalidBaseURL in invalidBaseURLs {
//            // Create a copy of Constants for testing
//            let testConstants = TestConstants(baseURL: invalidBaseURL)
//            let testNetworkManager = NetworkManagerWithTestConstants(constants: testConstants)
//            
//            // When/Then
//            do {
//                _ = try await testNetworkManager.getData(endPoint: .heros, type: [Hero].self)
//                XCTFail("Expected invalid URL error for baseURL: \(invalidBaseURL)")
//            } catch let error as MarvelHerosError {
//                XCTAssertEqual(error, MarvelHerosError.invalidURL, "Expected invalidURL error for baseURL: \(invalidBaseURL)")
//            } catch {
//                XCTFail("Unexpected error type: \(error) for baseURL: \(invalidBaseURL)")
//            }
//        }
//    }
    
    func testResponseWithoutHTTPResponse() async throws {
        // Given
        let testURL = URL(string: Constants.baseURL + NetworkManager.EndPoint.heros.rawValue)!
        let testData = "[]".data(using: .utf8)!
        
        // Set up URLProtocol mock with non-HTTP response
        URLProtocolMock.mockData = testData
        URLProtocolMock.mockResponse = URLResponse(
            url: testURL,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        
        let networkManager = NetworkManagerWithCustomSession(config: config)
        
        // When/Then
        do {
            _ = try await networkManager.getData(endPoint: .heros, type: [Hero].self)
            XCTFail("Expected no data error")
        } catch let error as MarvelHerosError {
            XCTAssertEqual(error, MarvelHerosError.noData)
        }
    }
}

// Helper classes for testing
class URLProtocolMock: URLProtocol {
    static var mockResponse: URLResponse?
    static var mockData: Data?
    static var mockError: Error?
    static var lastRequest: URLRequest?
    
    override class func canInit(with request: URLRequest) -> Bool {
        lastRequest = request
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLProtocolMock.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = URLProtocolMock.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = URLProtocolMock.mockData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func reset() {
        mockResponse = nil
        mockData = nil
        mockError = nil
        lastRequest = nil
    }
}

// Test helpers
struct TestConstants {
    let baseURL: String
}

class NetworkManagerWithTestConstants: NetworkManager {
    private let constants: TestConstants
    
    init(constants: TestConstants) {
        self.constants = constants
        super.init()
    }
    
    override func getData<T>(endPoint: EndPoint, type: T.Type) async throws -> T where T: Decodable {
        guard let url = URL(string: constants.baseURL + endPoint.rawValue) else {
            throw MarvelHerosError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarvelHerosError.noData
        }
        
        do {
            let parsedResponse = try JSONDecoder().decode(T.self, from: data)
            return parsedResponse
        } catch {
            throw MarvelHerosError.parseError
        }
    }
}

class NetworkManagerWithCustomSession: NetworkManager {
    private let session: URLSession
    
    init(config: URLSessionConfiguration) {
        self.session = URLSession(configuration: config)
        super.init()
    }
    
    override func getData<T>(endPoint: EndPoint, type: T.Type) async throws -> T where T: Decodable {
        guard let url = URL(string: Constants.baseURL + endPoint.rawValue) else {
            throw MarvelHerosError.invalidURL
        }
        
        let (data, response) = try await session.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarvelHerosError.noData
        }
        
        do {
            let parsedResponse = try JSONDecoder().decode(T.self, from: data)
            return parsedResponse
        } catch {
            throw MarvelHerosError.parseError
        }
    }
}
