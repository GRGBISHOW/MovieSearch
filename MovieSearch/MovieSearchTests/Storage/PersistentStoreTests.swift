//
//  PersistentStoreTests.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import XCTest
import Combine
@testable import MovieSearch

class PersistentStoreTests: XCTestCase {

    private var disposeBag: Set<AnyCancellable>!
    private var sut: PersistentStore!
    private let testDirectory: FileManager.SearchPathDirectory = .cachesDirectory
    private let dbVersion = PersistentStore.Version(version)
    private static var version: UInt {
       return 1
    }
    
    private var dbURL: URL {
        guard let url = dbVersion.dbFileURL(testDirectory, .userDomainMask)
            else { fatalError() }
        return url
    }
    
    override func setUp() {
        super.setUp()
        sut = PersistentStore(directory: testDirectory, version: Self.version)
        disposeBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        flushData { [weak self] in
            guard let self else { return }
            self.disposeBag = nil
            self.sut = nil
            
        }
        super.tearDown()
    }
    
    private func flushData(completion: @escaping ()-> Void) {
        sut.update { context in
            try MovieMO.delete(in: context)
        }.sink { _ in
        } receiveValue: { _ in
            completion()
        }
        .store(in: &disposeBag)
    }
    
    
    func test_init() {
        let exp = XCTestExpectation(description: #function)
        let request = MovieMO.newFetchRequest()
        request.fetchLimit = 1
        sut.fetch(request) {
            Movie(managedObject: $0)
        }.sink(receiveCompletion: { sate in
            print(sate)
        }, receiveValue: { value in
            XCTAssertTrue(value.isEmpty)
            exp.fulfill()
        }).store(in: &disposeBag)
       
        wait(for: [exp], timeout: 1)
    }
    
    func test_store_and_count() {
        let movies = Movie.mockedData
        let exp = XCTestExpectation(description: #function)
        let request = MovieMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        sut.update { context in
            movies.forEach {
                $0.store(in: context)
            }
        }.flatMap { _ in
            self.sut.count(request)
        }.sink(receiveCompletion: { _ in }, receiveValue: { value in
            XCTAssertEqual(value, movies.count)
            exp.fulfill()
        }).store(in: &disposeBag)
            
        wait(for: [exp], timeout: 1)
    }
    
      
    func test_storing_exception() {
        let exp = XCTestExpectation(description: #function)
        sut.update { context in
            throw NSError.test
        }.sink(receiveCompletion: { state in
            if case let .failure(err) = state {
                XCTAssertEqual(err.localizedDescription, NSError.test.localizedDescription)
                exp.fulfill()
            }
        }, receiveValue: { _ in })
        .store(in: &disposeBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_fetching() {
        let movies = Movie.mockedData
        let exp = XCTestExpectation(description: #function)
        sut.update { context in
            movies.forEach {
                    $0.store(in: context)
                }
            }
            .flatMap { _ -> AnyPublisher<[Movie], Error> in
                let request = MovieMO.newFetchRequest()
                request.predicate = NSPredicate(format: "id == %d", movies[0].id)
                return self.sut.fetch(request) {
                    Movie(managedObject: $0)
                }
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                XCTAssertEqual(movies[0].id, value[0].id)
                exp.fulfill()
            }).store(in: &disposeBag)
        wait(for: [exp], timeout: 1)
    }
}
