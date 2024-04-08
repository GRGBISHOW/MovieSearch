//
//  Combine+Helpers.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//
import Combine
import Foundation
@testable import MovieSearch

// Extension for publisher to connect TestableSubscriber
extension Publisher {
    func testableSubscriber() -> TestableSubscriber<Output, Failure> {
        let testSubscriber = TestableSubscriber<Output,Failure>()
        subscribe(testSubscriber)
        return testSubscriber
    }
}
