//
//  MovieDetailView.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 9/4/2024.
//

import SwiftUI
import DesignSystem

struct MovieDetailsView: View {
    var selectedMovie: Movie
    @State var showError: (Bool, String) = (false, "")
    var body: some View {
        ContainerView {
            VStack {
                CardView {
                    VStack(alignment: .leading) {
                        if let imageUrl = selectedMovie.wallPoster {
                            AsyncCachedImage(url: URL(string: imageUrl),
                                             content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            },
                                             placeholder: {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .aspectRatio(contentMode: .fit)
                                    .background(.clear)
                            }
                            )
                        }
                        VStack(alignment: .leading, spacing: Dimension.points16) {
                            Text(selectedMovie.title)
                                .fontStyle(with: .title)
                            Text(selectedMovie.releaseDate)
                                .fontStyle(with: .caption)
                            Text(selectedMovie.overview)
                                .fontStyle(with: .body)
                        }
                        HStack {
                            Button(title: "Rate this movie", type:.secondary) {
                                showError = (true, "Rating feature is comming in next version.")
                            }
                            Button(title: "Add to Favourites", type:.primary) {
                                showError = (true, "Favourites feature is comming in next version.")
                            }
                        }
                        
                    }
                }
                Spacer()
            }
            .padding(Dimension.points16)
        }.alert("Stay Tuned", isPresented: $showError.0, actions: {}) {
            Text(showError.1).fontStyle(with: .caption)
        }
        
    }
}
