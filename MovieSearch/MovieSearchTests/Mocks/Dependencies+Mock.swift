//
//  Dependencies+Mock.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

@testable import MovieSearch

extension AllDependencies {
    static var mock: AllDependencies {
        Self(database: MockedPersistentStore(),
             networkMonitor: .mock,
             network: MockedRequestHandler()
        )
    }
}

