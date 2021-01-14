//
//  SearchData.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 13.01.2021.
//

import Foundation

struct SearchData: Decodable {
    let results: [SuitableMovie]
    let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
    }
}

struct SuitableMovie: Decodable {
    let id: Int?
    let genreIds: [Int]
    let title: String
    let voteAverage: Double
    let posterPath: String?
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case genreIds = "genre_ids"
        case title
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case popularity
    }
}
