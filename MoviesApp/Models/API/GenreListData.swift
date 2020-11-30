//
//  GenreListData.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 01.10.2020.
//

import Foundation

struct GenreListData: Decodable {
    let genres: [Genre]
}

struct Genre: Decodable {
    let id: Int
    let name: String
}
