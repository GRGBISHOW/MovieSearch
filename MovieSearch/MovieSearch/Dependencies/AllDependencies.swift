//
//  AllDependencies.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 14/4/2024.
//

import Foundation
import MinimalNetworking
import CoreData

struct AllDependencies {
    lazy var database: PersistentStoreProvider = PersistentStore()
    lazy var networkMonitor = NetworkMonitoring()
    lazy var network: URLSessionProtocol = NetworkService.urlSession()
}

var Dependencies = AllDependencies()

