//
//  ApiEndpoint.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 30.09.2020.
//

import Foundation

public enum ApiEndpoint {
    case getGenres
    case getMovies(page: Int, path: String)
}

extension ApiEndpoint: EndpointProtocol {
    var baseURL: String {
        return "https://api.themoviedb.org/3"
    }
    
    var fullURL: String {
        switch self {
        case .getGenres:
            return baseURL + "/genre/movie/list"
        case let .getMovies(_ , path):
            return baseURL + "/movie/" + "\(path)"
        }
    }
    
    var params: [String : String] {
        var queryParams = ["api_key" : "22bf250dbcfb7e944385997a96f93842", "language" : Locale.current.regionCode ?? "en"]
        switch self {
        case .getGenres:
            return queryParams
        case let .getMovies(page, _):
            queryParams.updateValue("\(page)", forKey: "page")
            return queryParams
        }
    }
}
