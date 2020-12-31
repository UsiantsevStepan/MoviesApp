//
//  ListName.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 28.12.2020.
//

import Foundation

enum ListName: String, CaseIterable {
    var searchPath: String {
        switch self {
        case .popular:
            return "popular"
        case .upcoming:
            return "upcoming"
        case .nowPlaying:
            return "now_playing"
        }
    }
    
    case popular = "Popular"
    case upcoming = "Upcoming"
    case nowPlaying = "Now playing"
}
