import XCTest
@testable import MarvelHeros

class MockMarvelHerosService: MarvelHerosServicing {
    var shouldReturnError = false
    var herosToReturn: [Hero] = []
    func fetchHeros() async throws -> [Hero] {
        if shouldReturnError {
            throw MarvelHerosError.noData
        }
        return herosToReturn
    }
}

extension HerosViewModelTests {
    func testFetchHerosSuccess() async {
        let mockService = MockMarvelHerosService()
        let expectedHeros = [Hero(name: "Spider-Man", teamName: "Avengers", realName: "Peter Parker", imageURL: "", createdBy: "Stan Lee", publisher: "Marvel", firstAppearance: "1962")]
        mockService.herosToReturn = expectedHeros
        let viewModel = HerosViewModel(service: mockService)
        await viewModel.fetchHeros()
        XCTAssertEqual(viewModel.heros, expectedHeros)
    }

    func testFetchHerosFailure() async {
        let mockService = MockMarvelHerosService()
        mockService.shouldReturnError = true
        let viewModel = HerosViewModel(service: mockService)
        await viewModel.fetchHeros()
        XCTAssertTrue(viewModel.heros.isEmpty)
        
        if case .error(let errorMsg) = viewModel.state {
            XCTAssertEqual(errorMsg, "No data received")
        }
    }

    func testLoadingState() async {
        // Optionally, you can add an isLoading property to HerosViewModel and test it here
    }
}
