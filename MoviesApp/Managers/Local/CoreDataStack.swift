//
//  CoreDataStack.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 02.10.2020.
//

//import Foundation
//import CoreData
//
//class CoreDataStack {
//    
//  static let shared = CoreDataStack(modelName: "MoviesApp")
//  
//  private let modelName: String
//  
//  init(modelName: String) {
//    self.modelName = modelName
//  }
//  
//  lazy var managedContext: NSManagedObjectContext = {
//    return self.storeContainer.viewContext
//  }()
//  
//  private lazy var storeContainer: NSPersistentContainer = {
//    
//    let container = NSPersistentContainer(name: self.modelName)
//    container.loadPersistentStores { (storeDescription, error) in
//      if let error = error as NSError? {
//        print("Error \(error), \(error.userInfo)")
//      }
//    }
//    return container
//  }()
//  
//  func saveContext() {
//    guard managedContext.hasChanges else { return }
//    
//    do {
//      try managedContext.save()
//    } catch let error as NSError {
//      print(error, error.userInfo)
//    }
//  }
//}
