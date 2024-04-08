//
//  MovieServiceTests.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 8/4/2024.
//

import Combine
import Foundation
import XCTest
@testable import MovieSearch

final class MovieServicesTests: MovieSearchBaseTestCase {
    private var movieServices: MovieServices!
    private var dbDataProvider: MoviesDBDataProvider!
    private var disposeBag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        dbDataProvider = MoviesDBDataProvider(persistentStore: Dependencies.database)
        movieServices = MovieServices(dbDataProvider: dbDataProvider)
        disposeBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        movieServices = nil
        disposeBag = nil
        dbDataProvider = nil
        super.tearDown()
    }
    
    func test_loadSearch_online() throws {
        Dependencies.networkMonitor.isOnline = {
            true
        }
        Dependencies.network.stubWebRequest(forPath: MoviesWebDataProvider.MovieAPI.path, fileName: "MovieSearchSuccessResponse.json", response: nil)
        let testSubscriber = movieServices.load(search: "", loadType: .initial)
            .map { result -> (Int, PageInfo) in
                (result.models.count, result.info)
            }
            .testableSubscriber()
        let count = try XCTUnwrap(testSubscriber.emittedValues.last?.0)
        let pageInfo = try XCTUnwrap(testSubscriber.emittedValues.last?.1)
        XCTAssertEqual(count, 3)
        XCTAssertEqual(pageInfo, .more)
    }
    
    func test_loadSearch_offline() throws {
        _ = dbDataProvider.store(movies: Movie.mockedData).testableSubscriber()
        Dependencies.networkMonitor.isOnline = {
            false
        }
        let testSubscriber = movieServices.load(search: "alive", loadType: .initial)
            .map { result -> (Int, PageInfo) in
                (result.models.count, result.info)
            }
            .testableSubscriber()
        let count = try XCTUnwrap(testSubscriber.emittedValues.last?.0)
        let pageInfo = try XCTUnwrap(testSubscriber.emittedValues.last?.1)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(pageInfo, .noMore)
    }
}

