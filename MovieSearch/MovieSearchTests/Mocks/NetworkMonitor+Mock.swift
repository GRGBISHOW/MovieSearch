//
//  NetworkMonitor+Mock.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
@testable import MovieSearch

extension NetworkMonitor {
    static let mock: Self = .init {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

