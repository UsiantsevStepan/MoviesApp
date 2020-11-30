//
//  MoviePreview+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 28.11.2020.
//
//

import Foundation
import CoreData


extension MoviePreview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviePreview> {
        return NSFetchRequest<MoviePreview>(entityName: "MoviePreview")
    }

    @NSManaged public var posterPath: String?
    @NSManaged public var genreId: Int64
    @NSManaged public var title: String?

}
