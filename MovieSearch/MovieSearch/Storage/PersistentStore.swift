//
//  PersistentStore.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import Foundation
import CoreData
import Combine

protocol PersistentStoreProvider {
    typealias DBOperation<Result> = (NSManagedObjectContext) throws -> Result
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error>
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<[V], Error>
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error>
}

/// DataStack class
struct PersistentStore: PersistentStoreProvider {
    // MARK: - Properties
    
   private let persistentContainer: NSPersistentContainer
   private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    
    // MARK: Initializers
    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
         version vNumber: UInt = 1) {
        let version = Version(vNumber)
        persistentContainer = NSPersistentContainer(name: version.modelName)
        if let url = version.dbFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            persistentContainer.persistentStoreDescriptions = [store]
        }
        persistentContainer.loadPersistentStores { [isStoreLoaded, persistentContainer] (_, error) in
            if let error = error {
                isStoreLoaded.send(completion: .failure(error))
            } else {
                persistentContainer.viewContext.configureAsReadOnlyContext()
                isStoreLoaded.value = true
           }
        }
    }
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> where T : NSFetchRequestResult {
        return onStoreIsReady
            .flatMap { [weak persistentContainer] in
                Future<Int, Error> { promise in
                    do {
                        let count = try persistentContainer?.viewContext.count(for: fetchRequest) ?? 0
                        promise(.success(count))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>, map: @escaping (T) throws -> V?) -> AnyPublisher<[V], Error> where T : NSFetchRequestResult {
        let fetch = Future<[V], Error> { [weak persistentContainer] promise in
            guard let context = persistentContainer?.viewContext else { return }
                context.performAndWait {
                    do {
                            let managedObjects = try context.fetch(fetchRequest)
                            let results = try managedObjects.compactMap { object -> V? in
                                do {
                                    let mapped = try map(object)
                                    if let mo = object as? NSManagedObject {
                                        // Turning object into a fault
                                        context.refresh(mo, mergeChanges: false)
                                    }
                                    return mapped
                                } catch {
                                    throw error
                                }
                            }
                            promise(.success(results))
                        } catch {
                            promise(.failure(error))
                        }
                }
        }
        return onStoreIsReady
            .flatMap { fetch }
            .eraseToAnyPublisher()
    }
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        let update = Future<Result, Error> { [weak persistentContainer] promise in
            guard let context = persistentContainer?.newBackgroundContext() else { return }
            context.configureAsUpdateContext()
            context.performAndWait {
                do {
                    let result = try operation(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    context.reset()
                    promise(.success(result))
                } catch {
                    context.reset()
                    promise(.failure(error))
                }
            }
        }
        return onStoreIsReady
            .flatMap { update }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var onStoreIsReady: AnyPublisher<Void, Error> {
        return isStoreLoaded
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
   
}

extension PersistentStore {
    struct Version {
        private let number: UInt
        
        init(_ number: UInt) {
            self.number = number
        }
        
        var modelName: String {
            return "MovieSearch"
        }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "db.sql"
        }
    }
}
