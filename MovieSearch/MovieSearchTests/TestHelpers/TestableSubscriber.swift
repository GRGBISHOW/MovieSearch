//
//  TestableSubscriber.swift
//  MovieSearchTests
//
//  Created by Bishow Gurung on 7/4/2024.
//

import Combine
import Foundation

final class TestableSubscriber<Input, Failure: Error>: Subscriber {
    typealias Input = Input
    typealias Failure = Failure
    
    private var subscription: Subscription?
    private var values: [Input] = []
    private var completion: Subscribers.Completion<Failure>?
   
    private var demand: Subscribers.Demand {
        didSet { subscription?.request(demand) }
    }
    
    init(demand: Subscribers.Demand = .unlimited) {
        self.demand = demand
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        values.append(input) // Emitted Values
        return demand
    }
    

    func receive(completion: Subscribers.Completion<Failure>) {
        self.completion = completion
    }
    
    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.unlimited)
    }
    
    func cancel() {
        subscription?.cancel()
        subscription = nil
    }
    
    var emittedValues: [Input] {
        values
    }
    
    var completionState: Subscribers.Completion<Failure>? {
        completion
    }
    
    deinit {
        cancel()
    }
}
