//
//  MoviesDetailsData.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 08.01.2021.
//

import Foundation

struct MoviesDetailsData: Decodable {
    let adult: Bool
    let genres: [Genre]
    let originalTitle: String
    let countries: [Country]
    let releaseDate: String
    let runtime: Int?
    let overview: String?
    let budget: Int
    let revenue: Int
    
    enum CodingKeys: String, CodingKey {
        case adult
        case genres
        case originalTitle = "original_title"
        case countries = "production_countries"
        case releaseDate = "release_date"
        case runtime
        case overview
        case budget
        case revenue
    }
}

struct Country: Decodable {
    let name: String
}
