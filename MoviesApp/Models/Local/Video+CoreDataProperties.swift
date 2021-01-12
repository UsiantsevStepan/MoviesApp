//
//  Video+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 12.01.2021.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var key: String?
    @NSManaged public var site: String?
    @NSManaged public var type: String?
    @NSManaged public var movie: MoviePreview?

}
