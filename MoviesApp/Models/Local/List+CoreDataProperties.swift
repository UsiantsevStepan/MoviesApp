//
//  List+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 12.01.2021.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var name: String?
    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
extension List {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MoviePreview)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MoviePreview)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}
