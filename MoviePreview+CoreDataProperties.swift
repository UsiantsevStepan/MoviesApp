//
//  MoviePreview+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 17.12.2020.
//
//

import Foundation
import CoreData


extension MoviePreview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviePreview> {
        return NSFetchRequest<MoviePreview>(entityName: "MoviePreview")
    }

    @NSManaged public var genreId: Int64
    @NSManaged public var genreName: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var list: List?

}
