//
//  NetworkMonitor+Mock.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
@testable import MovieSearch

extension NetworkMonitoring {
    static let mock: Self = .init(publisher:
                                    { Just(false).eraseToAnyPublisher() },
                                  isOnline: { false }
    )
}

