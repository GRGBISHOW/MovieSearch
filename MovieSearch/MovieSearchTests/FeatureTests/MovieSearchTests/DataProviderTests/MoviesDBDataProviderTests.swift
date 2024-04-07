//
//  MoviesDBDataProviderTests.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
import Foundation
import XCTest
@testable import MovieSearch

final class MoviesDBDataProviderTests: MovieSearchBaseTestCase {
    private var dbDataProvider: MoviesDBDataProvider!
    private var mockDatabase: PersistentStoreProvider!
    private var disposeBag: Set<AnyCancellable>!
    override func setUp() {
        super.setUp()
        mockDatabase = Dependencies.database
        dbDataProvider = MoviesDBDataProvider(persistentStore: mockDatabase)
        disposeBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        dbDataProvider = nil
        mockDatabase = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func test_store() {
        let exp = XCTestExpectation(description: #function)
        dbDataProvider
            .store(movies: Movie.mockedData)
            .sink { state in
                if case .finished = state {
                    exp.fulfill()
                } else {
                    XCTFail()
                }
            } receiveValue: { _ in
            }
            .store(in: &disposeBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_hasLoaded() {
        let exp = XCTestExpectation(description: #function)
        dbDataProvider
            .hasLoadedMovies()
            .sink { _ in
            } receiveValue: { hasLoaded in
                XCTAssertFalse(hasLoaded)
                exp.fulfill()
            }.store(in: &disposeBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_movies() {
        let exp = XCTestExpectation(description: #function)
        dbDataProvider
            .store(movies: Movie.mockedData)
            .flatMap{ [weak self] _ -> AnyPublisher<[Movie], Error> in
                guard let self else  {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return dbDataProvider.movies(search: "alive")
            }
            .sink { _ in
            } receiveValue: { result in
                XCTAssertEqual(result.count, 1)
                exp.fulfill()
            }.store(in: &disposeBag)
        wait(for: [exp], timeout: 0.5)
    }
    
}

