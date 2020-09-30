//
//  EndpointProtocol.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 30.09.2020.
//

import Foundation

protocol EndpointProtocol {
    var baseURL: String { get }
    var fullURL: String { get }
    var params: [String: String] { get }
}
