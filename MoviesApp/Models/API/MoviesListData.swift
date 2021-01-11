//
//  MoviesListData.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 30.09.2020.
//

import Foundation

struct MoviesListData: Decodable {
    let page: Int
    let results: [Movie]
}

struct Movie: Decodable {
    let posterPath: String?
    let title: String
    let genreIds: [Int]
    let voteAverage: Double
    let id: Int
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case title
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case id
        case popularity
    }
}
