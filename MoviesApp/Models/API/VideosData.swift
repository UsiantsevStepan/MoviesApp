//
//  VideosData.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 12.01.2021.
//

import Foundation

struct VideosData: Decodable {
    let results: [Video?]
}

struct Video: Decodable {
    let key: String
    let site: String
    let type: String
}
