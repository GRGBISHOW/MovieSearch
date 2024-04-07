//
//  Combine+Helpers.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//
import Combine
import Foundation
@testable import MovieSearch

extension AnyPublisher where Output == PaginationState {
    func mapPagination() -> AnyPublisher<(Int, PaginationState.PageInfo), Error> {
        return tryMap { state -> (Int, PaginationState.PageInfo) in
            switch state {
            case let .loaded(data: data, info: pageInfo):
                return (data.count, pageInfo)
            default:
                throw NSError.test
            }
        }.eraseToAnyPublisher()
    }
}


// Extension for publisher to connect TestableSubscriber
extension Publisher {
    func testableSubscriber() -> TestableSubscriber<Output, Failure> {
        let testSubscriber = TestableSubscriber<Output,Failure>()
        subscribe(testSubscriber)
        return testSubscriber
    }
}
