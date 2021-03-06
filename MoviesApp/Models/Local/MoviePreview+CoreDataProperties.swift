//
//  MoviePreview+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 12.01.2021.
//
//

import Foundation
import CoreData


extension MoviePreview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviePreview> {
        return NSFetchRequest<MoviePreview>(entityName: "MoviePreview")
    }

    @NSManaged public var adult: Bool
    @NSManaged public var budget: Int64
    @NSManaged public var country: String?
    @NSManaged public var genreId: Int64
    @NSManaged public var genreName: [NSString]
    @NSManaged public var movieId: Int64
    @NSManaged public var originalTitle: String?
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var revenue: Int64
    @NSManaged public var runtime: Int64
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var list: NSSet?
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for list
extension MoviePreview {

    @objc(addListObject:)
    @NSManaged public func addToList(_ value: List)

    @objc(removeListObject:)
    @NSManaged public func removeFromList(_ value: List)

    @objc(addList:)
    @NSManaged public func addToList(_ values: NSSet)

    @objc(removeList:)
    @NSManaged public func removeFromList(_ values: NSSet)

}

// MARK: Generated accessors for videos
extension MoviePreview {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: Video)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: Video)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
