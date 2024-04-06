//
//  Movie+CoreData.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import CoreData
import Foundation

extension MovieMO: ManagedEntity { }

extension Movie {
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> MovieMO? {
        guard let movie = MovieMO.insertNew(in: context)
        else { return nil }
        movie.id = id
        movie.title = title
        movie.overview = overview
        movie.releaseDate = releaseDate
        movie.posterImage = posterImage
        return movie
    }
    
    init?(managedObject: MovieMO) {
        let id = managedObject.id
        guard let title = managedObject.title else { return nil }
        let overview = managedObject.overview ?? "No overview"
        let releaseDate = managedObject.releaseDate ?? "No Release date Published Yet"
        let posterImage = managedObject.posterImage ?? ""
        
        self.init(id: id, title: title, overview: overview , releaseDate: releaseDate , posterImage: posterImage )
    }
}

