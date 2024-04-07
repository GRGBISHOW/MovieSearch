//
//  MoviesDBDataProvider.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Foundation
import Combine
import CoreData

struct MoviesDBDataProvider {
    let persistentStore: PersistentStoreProvider
    
    func store(movies: [Movie]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                movies.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    func movies(search: String) -> AnyPublisher<[Movie], Error> {
        let fetchRequest = MovieMO.movies(search: search)
        return persistentStore
            .fetch(fetchRequest) {
                Movie(managedObject: $0)
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
    static func movies(search: String) -> NSFetchRequest<MovieMO> {
        let request = newFetchRequest()
        if !search.isEmpty {
            let nameMatch = NSPredicate(format: "title CONTAINS[cd] %@", search)
            request.predicate = nameMatch
        }
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.fetchBatchSize = 10
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

