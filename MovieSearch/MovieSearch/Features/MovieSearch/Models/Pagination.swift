//
//  Pagination.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 8/4/2024.
//

import Foundation

struct Pagination<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    var pageDetails: (Int, Int) {
        (page, totalPages)
    }
    
    
}

enum PageInfo {
    case more
    case noMore
}

typealias PaginationData<T> = (models: [T], info: PageInfo)

enum LoadType {
    case initial
    case more
}
