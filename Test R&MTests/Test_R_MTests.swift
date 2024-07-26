//
//  Test_R_MTests.swift
//  Test R&MTests
//
//  Created by Michael Grigoryan on 26.07.24.
//

import XCTest
import Foundation
@testable import Test_R_M // Replace with your actual module name

class MockAPIManager: APIManagerProtocol {
    var resultData: Data?
    var resultResponse: URLResponse?
    var resultError: Error?
    
    func fetch<T: Decodable>(urlString: String,
                             queryItems: [URLQueryItem],
                             reloadIgnoringLocalCacheData: Bool) async throws -> T {
        if let error = resultError {
            throw error
        }
        guard let data = resultData else {
            fatalError("MockAPIManager: resultData is nil")
        }
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    }
}

class EpisodesServiceTests: XCTestCase {

    var episodesService: EpisodesService!
    var mockAPIManager: MockAPIManager!

    override func setUp() {
        super.setUp()
        mockAPIManager = MockAPIManager()
        episodesService = EpisodesService(apiManager: mockAPIManager)
    }

    func testGetEpisodesSuccess() async throws {
        let episodes = [RMEpisode(id: 0, name: "", characters: [])]
        mockAPIManager.resultData = try JSONEncoder().encode(episodes)
        mockAPIManager.resultError = nil
        
        let ids: [String] = ["1", "2"]
        
        let result = try await episodesService.getEpisodes(ids: ids)
        
        XCTAssertEqual(result, episodes)
    }

    func testGetEpisodesFailure() async throws {
        mockAPIManager.resultData = nil
        mockAPIManager.resultError = URLError(.badURL) // Simulating a network error
        
        let ids: [String] = ["1", "2"]

        do {
            _ = try await episodesService.getEpisodes(ids: ids)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, URLError.Code.badURL)
        }
    }

    func testGetOnlyEpisodeSuccess() async throws {
        let episode = RMEpisode(id: 0, name: "", characters: [])
        mockAPIManager.resultData = try JSONEncoder().encode(episode)
        mockAPIManager.resultError = nil
        
        let id = "1"
        
        let result = try await episodesService.getOnlyEpisode(id: id)
        
        XCTAssertEqual(result, episode)
    }

    func testGetOnlyEpisodeFailure() async throws {
        mockAPIManager.resultData = nil
        mockAPIManager.resultError = URLError(.badURL) // Simulating a network error
        
        let id = "1"
        
        do {
            _ = try await episodesService.getOnlyEpisode(id: id)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, URLError.Code.badURL)
        }
    }
}
