//
//  NetworkMonitor.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 14/4/2024.
//

import Combine
import Foundation
import Network

struct NetworkMonitoring {
    var publisher: () -> AnyPublisher<Bool, Never> = {
        instance.publisher()
    }
    
    var isOnline: () -> Bool = {
        instance.isOnline
    }
}

private let instance = NetworkMonitor()
final private class NetworkMonitor {
    let monitor = NWPathMonitor()
    private var subject = CurrentValueSubject<Bool, Never>(false)
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isOnline: Bool {
        subject.value
    }
   
    
    
    init() {
        monitor.pathUpdateHandler = {[weak self] path in
            guard let self else { return }
            subject.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
    
    func publisher() -> AnyPublisher<Bool, Never> {
        return subject.eraseToAnyPublisher()
    }
}


