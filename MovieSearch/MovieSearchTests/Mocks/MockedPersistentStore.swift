//
//  MockedPersistentStore.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
import CoreData
import Foundation
import MinimalNetworking
@testable import MovieSearch

final class MockedPersistentStore: PersistentStoreProvider {
    
    private lazy var container: NSPersistentContainer  = {
        let container = NSPersistentContainer(name: dbVersion.modelName)
        let store = NSPersistentStoreDescription(url: dbURL)
        store.type = NSInMemoryStoreType
        store.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [store]
        let group = DispatchGroup()
        group.enter()
        container.loadPersistentStores { (desc, error) in
            precondition( desc.type == NSInMemoryStoreType )
            if let error = error {
                fatalError("\(error)")
            }
            group.leave()
        }
        group.wait()
        container.viewContext.mergePolicy = NSOverwriteMergePolicy
        container.viewContext.undoManager = nil
        return container
    }()
    
   
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> where T : NSFetchRequestResult {
        do {
            let count = try container.viewContext.count(for: fetchRequest)
            return Just(count).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail<Int, Error>(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>, map: @escaping (T) throws -> V?) -> AnyPublisher<[V], Error> where T : NSFetchRequestResult {
        do {
            let context = container.viewContext
            context.reset()
            let managedObjects = try context.fetch(fetchRequest)
            let results = try managedObjects.compactMap { object -> V? in
                do {
                    let mapped = try map(object)
                    if let mo = object as? NSManagedObject {
                        context.refresh(mo, mergeChanges: false)
                    }
                    return mapped
                } catch {
                    throw error
                }
            }
            return Just(results).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail<[V], Error>(error: error).eraseToAnyPublisher()
        }
    }
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        do {
            let context = container.viewContext
            let result = try operation(context)
            save()
            return Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail<Result, Error>(error: error).eraseToAnyPublisher()
        }
    }
    
   
    private let dbVersion = PersistentStore.Version(1)
    private var dbURL: URL {
        guard let url = dbVersion.dbFileURL(.cachesDirectory, .userDomainMask)
            else { fatalError() }
        return url
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        }  catch {
            print("create fakes error \(error)")
        }
    }
    
}

