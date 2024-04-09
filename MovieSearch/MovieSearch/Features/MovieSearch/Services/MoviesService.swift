//
//  MoviesService.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 8/4/2024.
//

import Combine
import Foundation
import MinimalNetworking

struct MovieService {
    
    private let webDataProvider: MoviesWebDataProvider
    private let dbDataProvider: MoviesDBDataProvider
    private var disposebag = Set<AnyCancellable>()
    
    init(webDataProvider: MoviesWebDataProvider = MoviesWebDataProvider(), dbDataProvider: MoviesDBDataProvider = MoviesDBDataProvider(persistentStore: Dependencies.database)) {
        self.webDataProvider = webDataProvider
        self.dbDataProvider = dbDataProvider
        
    }
    
    func load(loadType: LoadType) -> AnyPublisher<PaginationData<Movie>, Error> {
        if Dependencies.networkMonitor.isOnline() {
            return webDataProvider
                .loadMovies(loadType: loadType)
                .flatMap{ [dbDataProvider] result in
                    if loadType == .initial {
                        return dbDataProvider.deleteMovies()
                            .map{_ in result }
                            .eraseToAnyPublisher()
                    } else {
                        return Just(result)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                }
                .flatMap { [dbDataProvider] result -> AnyPublisher<PaginationData<Movie>, Error>  in
                    dbDataProvider.store(movies: result.models)
                        .map {_ in result }.eraseToAnyPublisher()
                }.flatMap{ result in
                    return self.loadLocalData(searchText:
                                                String.empty,
                                              loadType: loadType,
                                              dataAmount: .paginated,
                                              pageInfo: result.info
                    )
                }.eraseToAnyPublisher()
        } else {
            return self.loadLocalData(searchText:
                                        String.empty,
                                      loadType: loadType,
                                      dataAmount: .offlineLimit,
                                      pageInfo: .noMore
            )
            
        }
        
    }
    
    func searchMovies(searchText: String) -> AnyPublisher<PaginationData<Movie>, Never> {
        return self.loadLocalData(searchText:
                                    searchText,
                                  loadType: .initial,
                                  dataAmount: .unlimited,
                                  pageInfo: .noMore)
        .catch{ _ in
            return Just(([], .noMore))
        }.eraseToAnyPublisher()
    }
    
    private func loadLocalData(searchText: String,
                               loadType: LoadType,
                               dataAmount: DataAmount,
                               pageInfo: PageInfo) -> AnyPublisher<PaginationData<Movie>, Error> {
        return dbDataProvider.hasLoadedMovies()
            .flatMap { _ in
                dbDataProvider.movies(search: searchText, loadType: loadType, dataAmount: .unlimited)
            }
            .flatMap { movies  in
                return Just((movies, pageInfo))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
