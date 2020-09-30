//
//  MoviesListData.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 30.09.2020.
//

import Foundation

struct MoviesListData: Decodable {
    let page: Int
    let results: [Result]
}

struct Result: Decodable {
    let posterPath: String?
    let title: String
    let genreIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case title
        case genreIds = "genre_ids"
    }
}
