//
//  MockedRequestHandler.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//
import Combine
import Foundation
import MinimalNetworking
import XCTest
@testable import MovieSearch

class MockedRequestHandler: URLSessionProtocol {
    var mockResponse:[Stub] = []
    func response(request: URLRequest) -> AnyPublisher<APIResponse, URLError> {
        guard let url = request.url,
              let mockStub = getMockResponse(withPath: url.relativePath.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        else { return Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
       
        let response = mockStub.response ?? HTTPURLResponse (
                   url: url,
                   statusCode: 200,
                   httpVersion: nil,
                   headerFields: nil)!
        
        return Just((data: mockStub.data ?? Data(), response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
    
    private func getMockResponse(withPath path: String) -> Stub? {
        guard let stub = mockResponse.last(where: {$0.path == path}) else { return nil }
        return stub
    }
}

extension URLSessionProtocol {
    mutating func stubWebRequest(forPath path: String, fileName: String, response: HTTPURLResponse?) {
        guard let handler = self as? MockedRequestHandler else {
            XCTFail("falied to create mock handler")
            return
        }
    
        guard let mockPath = Bundle(for: MovieSearchBaseTestCase.self).url(forResource: fileName, withExtension: nil) else {
            XCTFail("couldnt find mock file path")
            return
        }
           
        var data: Data?
        if let responseData = try? Data(contentsOf: mockPath) {
            data = responseData
        }
        handler.mockResponse.append(Stub(path:path, fileName: fileName, data: data, response: response))
    }
}

struct Stub {
    let path:String
    let fileName: String
    let data: Data?
    let response: HTTPURLResponse?
}
