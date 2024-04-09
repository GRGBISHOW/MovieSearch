//
//  MoviesWebDataProvider.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
import Foundation
import MinimalNetworking
import Network

struct MoviesWebDataProvider {
    func loadMovies(loadType: LoadType) -> AnyPublisher<PaginationData<Movie>, Error> {
        MovieAPI.prepareLoad(loadType: loadType)
        return MovieAPI.load()
            .map { pagination in
                MovieAPI.lastPage = pagination.page
                return (models: pagination.results,
                               info: pagination.page < pagination.totalPages
                               ? .more : .noMore)
            }
            .mapError { error -> Error in
                error
            }
            .eraseToAnyPublisher()
    }
}


extension MoviesWebDataProvider {

    enum MovieAPI: Requestable {
        typealias ResponseType = Pagination<Movie>
        typealias RequestType = EmptyRequest
       
        static var path: String { "3/movie/popular" }
        static var queryParams: [String : Any]? {
            queryParameters()
        }
        
        static private func setQueryParams(page: Int) {
            queryParameters = {
                ["api_key": "05273ee9acd38d9c8fed54f19688c49b", // API Keys Should not be stored in local, doing it for temporary
                 "language": "en",
                 "sort_by": "popularity.desc",
                 "include_adult": false,
                 "page": page]
            }
        }
        static var lastPage = 1
        static private var queryParameters:() -> [String : Any]? = { nil }
        static func prepareLoad(loadType: LoadType) {
            setQueryParams(page:  loadType == .initial ? 1 : lastPage + 1)
        }
    }
}
