//
//  MovieSearchView.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 9/4/2024.
//

import Combine
import DesignSystem
import SwiftUI

struct MovieSearchView: View {
    @ObservedObject var viewModel: MovieSearchViewModel
    @State var search = ""
    @State private var viewDidLoad = false
    private var searchResults: Set<Movie> {
        search.isEmpty ? viewModel.movies : viewModel.searchedMovies
    }
   
    var body: some View {
        NavigationStack {
            ZStack {
                SearchedView { isSearching in
                    VStack {
                        
                        ListView {
                            Section {
                                ForEach(Array(searchResults)) { item in
                                    ListItem(leftImageSrc: .system("pencil.tip.crop.circle.fill"), title: item.title, description: item.releaseDate, rightSystemImage: "chevron.right.circle")
                                        .background(
                                            NavigationLink("", destination:  MovieDetailsView(selectedMovie: item))
                                                .opacity(0)
                                        )
                                }
                            } footer: {
                                if viewModel.isMorePageAvailable && !isSearching {
                                    FooterItem {
                                        HStack(alignment: .center) {
                                            Spacer()
                                            Text("Loading more movies...")
                                                .fontStyle(with: .notes)
                                            Spacer()
                                        }
                                    }.task {
                                        viewModel.loadMovies(loadType: .more)
                                    }
                                }
                            }
                        }.refreshable {
                            viewModel.loadMovies(loadType: .initial)
                        }
                    }
                    
                }
                .navigationTitle("Mvoies")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Circle().foregroundColor(viewModel.isInternet ? .green : .red))
                
                .task {
                    if !viewDidLoad {
                        viewDidLoad = true
                        viewModel.loadMovies(loadType: .initial)
                    }
                   
                }
                .searchable(text: $search, prompt: "Search Movies")
                .onChange(of: search) { _, newValue in
                    viewModel.searchMovies(searchText: search)
                }
                
                if viewModel.movies.isEmpty {
                    Text("Loading Movies").fontStyle(with: .body)
                }
            }.alert("OOPS", isPresented: $viewModel.showError.0, actions: {}) {
                Text(viewModel.showError.1).fontStyle(with: .caption)
            }
        }
        .background(.clear)
    }
    
}


struct SearchedView<Content: View>: View {
    @Environment(\.isSearching) private var isSearching
    let content: (Bool) -> Content
    
    init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.content = content
    }

    var body: some View {
        content(isSearching)
    }
}

