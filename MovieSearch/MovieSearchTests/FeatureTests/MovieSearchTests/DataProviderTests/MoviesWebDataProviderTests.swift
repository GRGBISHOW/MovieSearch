//
//  MoviesWebDataProviderTests.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
import Foundation
import MinimalNetworking
import XCTest
@testable import MovieSearch

final class MoviesWebDataProviderTests: MovieSearchBaseTestCase {
    private var webDataProvider: MoviesWebDataProvider!
    private var disposeBag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        webDataProvider = MoviesWebDataProvider()
        disposeBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        webDataProvider = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func test_loadMovies_success() throws {
        Dependencies.network.stubWebRequest(forPath: MoviesWebDataProvider.MovieAPI.path, fileName: "MovieSearchSuccessResponse.json", response: nil)
        let subs = webDataProvider
            .loadMovies(searchText: "", loadType: .initial)
            .mapPagination()
            .testableSubscriber()
        let count = try XCTUnwrap(subs.emittedValues.last?.0)
        let pageInfo = try XCTUnwrap(subs.emittedValues.last?.1)
        let searchQuery = try XCTUnwrap(MoviesWebDataProvider.MovieAPI.queryParams?["query"] as? String)
        let page = try XCTUnwrap(MoviesWebDataProvider.MovieAPI.queryParams?["page"] as? Int)
        XCTAssertTrue(searchQuery.isEmpty)
        XCTAssertEqual(page, 1)
        XCTAssertEqual(count, 3)
        XCTAssertEqual(pageInfo, .more)
    }
    
    func test_last_pagination() throws {
        Dependencies.network.stubWebRequest(forPath: MoviesWebDataProvider.MovieAPI.path, fileName: "MovieSearchLastPageResponse.json", response: nil)
        let subs = webDataProvider
            .loadMovies(searchText: "bis", loadType: .more)
            .mapPagination()
            .testableSubscriber()
        let count = try XCTUnwrap(subs.emittedValues.last?.0)
        let pageInfo = try XCTUnwrap(subs.emittedValues.last?.1)
        let searchQuery = try XCTUnwrap(MoviesWebDataProvider.MovieAPI.queryParams?["query"] as? String)
        let page = try XCTUnwrap(MoviesWebDataProvider.MovieAPI.queryParams?["page"] as? Int)
        XCTAssertEqual(searchQuery, "bis")
        XCTAssertEqual(page, 2)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(pageInfo, .noMore)
    }
    
    func test_loadMovies_failure() {
        let mockResponse = HTTPURLResponse (
            url: .mock,
                   statusCode: 498,
                   httpVersion: nil,
                   headerFields: nil)!
        Dependencies.network.stubWebRequest(forPath: MoviesWebDataProvider.MovieAPI.path, fileName: "MovieSearchSuccessResponse.json", response: mockResponse)
        let subs = webDataProvider
            .loadMovies(searchText: "", loadType: .initial)
            .testableSubscriber()
        switch subs.completionState {
        case let .failure(err):
            XCTAssertEqual(err.localizedDescription, "498")
        default:
            XCTFail("\(#function) test failed")
        }
    }
}
