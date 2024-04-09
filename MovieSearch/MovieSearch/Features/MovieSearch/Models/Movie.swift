//
//  Movie.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import Foundation

struct Movie: Codable, Identifiable, Hashable {
    let id: Int64
    let title: String
    let overview: String
    let releaseDate: String
    let posterImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case posterImage = "poster_path"
    }
}
