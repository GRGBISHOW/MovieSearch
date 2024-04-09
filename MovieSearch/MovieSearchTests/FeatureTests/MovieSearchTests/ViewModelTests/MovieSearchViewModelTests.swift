//
//  MovieSearchViewModelTests.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 9/4/2024.
//

import Combine
import Foundation
import XCTest
@testable import MovieSearch

final class MovieSearchViewModelTests: MovieSearchBaseTestCase {
    private var movieServices: MovieService!
    private var dbDataProvider: MoviesDBDataProvider!
    var viewModel: MovieSearchViewModel!
    private var disposeBag: Set<AnyCancellable>!
    override func setUp() {
        super.setUp()
        dbDataProvider = MoviesDBDataProvider(persistentStore: Dependencies.database)
        movieServices = MovieService(dbDataProvider: dbDataProvider)
        viewModel = MovieSearchViewModel(movieService: movieServices)
        disposeBag = Set<AnyCancellable>()
       
    }
    
    override func tearDown() {
        dbDataProvider = nil
        movieServices = nil
        viewModel = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func test_LoadMovies() {
        Dependencies.networkMonitor.isOnline = { true }
        Dependencies.network.stubWebRequest(forPath: MoviesWebDataProvider.MovieAPI.path, fileName: "MovieSearchSuccessResponse.json", response: nil)
      
        let exp = XCTestExpectation(description: #function)
        viewModel.$movies.dropFirst().sink { movies in
            XCTAssertEqual(movies.count, 3)
            exp.fulfill()
        }.store(in: &disposeBag)
        viewModel.loadMovies(loadType: .initial)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_searchMovies() throws {
        _ = dbDataProvider.store(movies: Movie.mockedData).testableSubscriber()
        let exp = XCTestExpectation(description: #function)
        viewModel.$searchedMovies.dropFirst().sink { movies in
            XCTAssertEqual(movies.count, 1)
            exp.fulfill()
        }.store(in: &disposeBag)
        viewModel.searchMovies(searchText: "Alive")
        wait(for: [exp], timeout: 0.5)
    }
}

