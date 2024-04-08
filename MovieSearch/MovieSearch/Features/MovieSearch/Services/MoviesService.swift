//
//  MoviesService.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 8/4/2024.
//

import Combine
import Foundation
import MinimalNetworking

struct MovieServices {
    
    private let webDataProvider: MoviesWebDataProvider
    private let dbDataProvider: MoviesDBDataProvider
    private let disposebag = Set<AnyCancellable>()
    
    init(webDataProvider: MoviesWebDataProvider = MoviesWebDataProvider(), dbDataProvider: MoviesDBDataProvider = MoviesDBDataProvider(persistentStore: Dependencies.database)) {
        self.webDataProvider = webDataProvider
        self.dbDataProvider = dbDataProvider
    }
        
    func load(search: String, loadType: LoadType) -> AnyPublisher<PaginationData<Movie>, Error> {
        if Dependencies.networkMonitor.isOnline() {
            webDataProvider
                .loadMovies(searchText: search, loadType: loadType)
                .flatMap { result -> AnyPublisher<PaginationData, Error>  in
                    return dbDataProvider.store(movies: result.models)
                        .map { _ in
                            result }.eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        } else {
            dbDataProvider.hasLoadedMovies()
                .flatMap { [dbDataProvider] result -> AnyPublisher<PaginationData<Movie>, Error>  in
                    return dbDataProvider.movies(search: search)
                        .map{ movies in (models: movies, info: .noMore) }
                        .eraseToAnyPublisher()
                }.eraseToAnyPublisher()
        }
    }
}

