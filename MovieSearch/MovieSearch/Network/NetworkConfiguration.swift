//
//  NetworkConfiguration.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import Foundation
import MinimalNetworking

extension Requestable {
    static var host: MinimalNetworking.APIHostable {
        APIHost.development
    }
    
    static var session: URLSessionProtocol {
        Dependencies.network
    }
}

enum APIHost: APIHostable {
    case development
    var baseUrl: String {
        switch self {
        case .development:
            "https://api.themoviedb.org/"
        }
    }
}

enum ImageRepo {
    static private let baseUrl = "https://image.tmdb.org/t/p/"
    case small(String)
    case large(String)

    var path: String {
        switch self {
        case let .small(path):
            return Self.baseUrl + "w92/" + path
        case let .large(path):
            return Self.baseUrl + "w300/" + path
        }
    }
}
