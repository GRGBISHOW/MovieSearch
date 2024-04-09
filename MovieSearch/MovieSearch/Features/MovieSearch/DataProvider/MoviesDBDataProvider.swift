//
//  MoviesDBDataProvider.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Foundation
import Combine
import CoreData

protocol MoviesDBDataRepository {
    func store(movies: [Movie]) -> AnyPublisher<Void, Error>
    func deleteMovies() -> AnyPublisher<Void, Error>
    func movies(search: String, loadType: LoadType, dataAmount: DataAmount) -> AnyPublisher<[Movie], Error>
    func hasLoadedMovies() -> AnyPublisher<Bool, Error>
}

class MoviesDBDataProvider: MoviesDBDataRepository {
    private let persistentStore: PersistentStoreProvider
    private(set) var lastOffset = 0
    
    init(persistentStore: PersistentStoreProvider) {
        self.persistentStore = persistentStore
    }
    
    func store(movies: [Movie]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                movies.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    func deleteMovies() -> AnyPublisher<Void, Error>  {
        return persistentStore
            .update { context in
                try MovieMO.delete(in: context)
            }
    }

    
    func movies(search: String = "" , loadType: LoadType, dataAmount: DataAmount) -> AnyPublisher<[Movie], Error> {
        if dataAmount == .paginated {
            lastOffset = loadType == .initial ? 0 : lastOffset
        }
        let fetchRequest = MovieMO.movies(search: search, offSet: lastOffset, limit: dataAmount.rawValue)
        return persistentStore
            .fetch(fetchRequest) {
                Movie(managedObject: $0)
            }.map { [weak self] movies in
                guard let self else { return movies }
                if dataAmount == .paginated {
                    self.lastOffset = self.lastOffset + movies.count
                }
                return movies
            }
            .eraseToAnyPublisher()
    }
    
    func hasLoadedMovies() -> AnyPublisher<Bool, Error> {
        let fetchRequest = MovieMO.justOneMovie()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }

}

extension MovieMO {
    static func movies(search: String, offSet: Int, limit: Int) -> NSFetchRequest<MovieMO> {
        let request = newFetchRequest()
        if !search.isEmpty {
            let nameMatch = NSPredicate(format: "title CONTAINS[cd] %@", search)
            request.predicate = nameMatch
        }
        request.fetchOffset = offSet
        request.fetchLimit = limit
        return request
    }
    
    static func justOneMovie() -> NSFetchRequest<MovieMO> {
        let request = newFetchRequest()
        request.fetchLimit = 1
        return request
    }
    
    @discardableResult
    static func delete(in context: NSManagedObjectContext) throws -> [MovieMO]? {
        let fetchRequest = MovieMO.newFetchRequest()
        do {
            let objs = try context.fetch(fetchRequest)
            for case let obj as NSManagedObject in objs {
                context.delete(obj)
            }
            return objs
        } catch {
            throw error
        }
    }
}
