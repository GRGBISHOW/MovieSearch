//
//  MovieSearchBaseTestCase.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 6/4/2024.
//

import Combine
import XCTest
@testable import MovieSearch

class MovieSearchBaseTestCase: XCTestCase {
    private var disposeBag: Set<AnyCancellable>!
    override func setUp() {
        super.setUp()
        Dependencies = .mock
        disposeBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        flushData()
        disposeBag = nil
        super.tearDown()
    }
    
    private func flushData() {
        Dependencies.database.update { context in
            try MovieMO.delete(in: context)
        }.sink { state in
            if case .finished = state {
                print("Data flushed")
            } else {
                print("Data not flushed")
            }
        } receiveValue: { _ in }
            .store(in: &disposeBag)
    }
}
