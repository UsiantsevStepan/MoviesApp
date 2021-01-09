//
//  MovieDetailsModel.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 08.01.2021.
//

import Foundation

struct MovieDetailsModel {
    let adult: Bool
    let genresNames: [String]
    let originalTitle: String
    let country: String
    let releaseDate: String
    let runtime: Int?
    let overview: String?
    let budget: Int
    let revenue: Int
}
