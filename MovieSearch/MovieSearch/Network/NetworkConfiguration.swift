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

