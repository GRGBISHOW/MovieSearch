//
//  MovieSearchViewModel.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 9/4/2024.
//

import Combine
import Foundation

class MovieSearchViewModel: ObservableObject {
    
    private let service: MovieService
    @Published private(set)var movies: Set<Movie> = []
    @Published private(set) var isMorePageAvailable = false
    @Published var showError: (Bool, String) = (false, "")
    @Published private(set) var isInternet = false
    @Published private(set) var searchedMovies: Set<Movie> = []
    
    private var bag = Set<AnyCancellable>()
    
    init(movieService: MovieService = MovieService()) {
        self.service = movieService
        addObservers()
    }
    
    func loadMovies(loadType: LoadType) {
        service.load(loadType: loadType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                if case let .failure(err) = result {
                    self.showError = (true , err.localizedDescription)
                }
            } receiveValue: { [weak self] result in
                guard let self else { return }
                if loadType == .initial {
                    self.movies = Set(result.models)
                } else {
                    self.movies.formUnion(result.models)
                }
                self.isMorePageAvailable = result.info == .more
            }
            .store(in: &bag)
    }
    
    func searchMovies(searchText: String) {
        service.searchMovies(searchText: searchText)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self else { return }
                self.searchedMovies = Set(result.models)
            })
            .store(in: &bag)
    }
    
    
    private func addObservers() {
        Dependencies.networkMonitor.publisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isInternet, on: self)
            
            .store(in: &bag)
    }
    
    deinit {
        print("MovieListViewModel deinit")
    }
}
