//
//  ApiEndpoint.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 30.09.2020.
//

import Foundation

public enum ApiEndpoint {
    case getPopularMovies(page: Int)
    case getGenres
    case getUpcomingMovies(page: Int)
    case getNowPlayingMovies(page: Int)
}

extension ApiEndpoint: EndpointProtocol {
    var baseURL: String {
        return "https://api.themoviedb.org/3"
    }
    
    var fullURL: String {
        switch self {
        case .getPopularMovies:
            return baseURL + "/movie/popular"
        case .getGenres:
            return baseURL + "/genre/movie/list"
        case .getUpcomingMovies:
            return baseURL + "/movie/upcoming"
        case .getNowPlayingMovies:
            return baseURL + "/movie/now_playing"
        }
    }
    
    var params: [String : String] {
        var queryParams = ["api_key" : "22bf250dbcfb7e944385997a96f93842", "language" : Locale.current.regionCode ?? "en"]
        switch self {
        case let .getPopularMovies(page):
            queryParams.updateValue("\(page)", forKey: "page")
            return queryParams
        case .getGenres:
            return queryParams
        case let .getUpcomingMovies(page: page):
            queryParams.updateValue("\(page)", forKey: "page")
            return queryParams
        case let .getNowPlayingMovies(page: page):
            queryParams.updateValue("\(page)", forKey: "page")
            return queryParams
        }
    }
}
