//
//  Mocked+Utils.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Foundation
@testable import MovieSearch
extension Movie {
    static let mockedData: [Movie] = [
        Movie(id: 123, title: "What you", overview: "What you are doing", releaseDate: "2012-11-11", posterImage: nil),
        Movie(id: 456, title: "I am alive", overview: "What you are doing being alive", releaseDate: "2012-11-11", posterImage: nil)
    ]
}

extension NSError {
    static var test: NSError {
        return NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
    }
}

extension URL {
    static var mock: URL {
        return URL(string: "https://example.com/mock")!
    }
}
