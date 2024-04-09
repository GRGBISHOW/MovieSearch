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
                        
                    }
                }
                Spacer()
            }
            .padding(Dimension.points16)
            
        }
        
    }
}
