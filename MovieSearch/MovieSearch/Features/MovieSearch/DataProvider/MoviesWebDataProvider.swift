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

class MoviesWebDataProvider {
    private var lastFetchedPage = 1
    func loadMovies(searchText: String, loadType: LoadType) -> AnyPublisher<PaginationState, Error> {
        MovieAPI.setQueryParams(with: searchText, page: nextpage(loadType: loadType))
        return MovieAPI.load()
            .map {[weak self] pagination in
                guard let self else { return .idle }
                self.lastFetchedPage = pagination.page
                return .loaded(data: pagination.results,
                               info: pagination.page < pagination.totalPages
                               ? .more : .noMore)
            }
            .mapError { error -> Error in
                error
            }
            .eraseToAnyPublisher()
    }
    
    private func nextpage(loadType: LoadType) -> Int {
        return loadType == .initial ? 1 : lastFetchedPage + 1
    }
}


extension MoviesWebDataProvider {

    enum MovieAPI: Requestable {
        typealias ResponseType = Pagination<Movie>
        typealias RequestType = EmptyRequest
        
        static var path: String { "3/search/movie" }
        static var queryParams: [String : Any]? {
            queryParameters()
        }
    }
    
    struct Pagination<T: Codable>: Codable {
        let page: Int
        let results: [T]
        let totalPages: Int
        let totalResults: Int
        
        enum CodingKeys: String, CodingKey {
            case page
            case results
            case totalPages = "total_pages"
            case totalResults = "total_results"
        }
        
        var pageDetails: (Int, Int) {
            (page, totalPages)
        }
    }
}

extension MoviesWebDataProvider.MovieAPI {
    static private var queryParameters:() -> [String : Any]? = { nil }
    static func setQueryParams(with searchText: String, page: Int) {
        queryParameters = {
            ["api_key": "05273ee9acd38d9c8fed54f19688c49b", // API Keys Should not be stored in local, doing it for temporary
             "sort_by": "popularity.desc",
             "language": "en",
             "include_adult": false,
             "include_video": false,
             "query": searchText,
             "page": page]
        }
    }
}

enum PaginationState {
    enum PageInfo {
        case more
        case noMore
    }
    case loaded(data: [Movie], info: PageInfo)
    case idle
    
}

enum LoadType {
    case initial
    case more
}

