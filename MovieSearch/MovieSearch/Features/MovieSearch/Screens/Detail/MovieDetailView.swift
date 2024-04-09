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
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text(selectedMovie.title)
                                    .fontStyle(with: .title)
                                Text(selectedMovie.releaseDate)
                                    .fontStyle(with: .headline)
                            }
                            if let imageUrl = selectedMovie.posterImage {
                                AsyncImage(url: URL(string: imageUrl),
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
                                .frame(maxWidth: Dimension.points32, maxHeight: Dimension.points32)
                            }
                        }
                        Text(selectedMovie.overview)
                            .fontStyle(with: .body)
                    }
                }
                Spacer()
            }
            .padding(Dimension.points16)
            
        }
      
    }
}
