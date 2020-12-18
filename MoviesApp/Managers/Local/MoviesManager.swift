//
//  MovieManager.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 02.10.2020.
//

import Foundation
import CoreData
import UIKit

class MoviesManager {
    enum MoviesManagerError: LocalizedError {
        case parseError
        
        var errorDescription: String? {
            return "Data hasn't been parsed or has been parsed incorrectly"
        }
    }
    
    let dataParser = DataParser()
    let networkManager = NetworkManager()
    var moviesPreview: [MoviePreview]?
    var genres = [Genre]()
    var genreName: String?
    
    private let popularListName = "Popular"
    private let upcomingListName = "Upcoming"
    private let nowPlayingListName = "Now playing"
    
    
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistentStoreCoordinator = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator
    
    
    func getPopularMovies(_ page: Int? = nil, _ completion: @escaping ((Result<([MoviePreviewCellModel],Int?),Error>) -> Void)) {
        
        getListOfMovies(endpoint: ApiEndpoint.getPopularMovies(page: page ?? 1), page: page, listName: popularListName, completion: completion)
    }
    
    func getUpcomingMovies(_ page: Int? = nil, _ completion: @escaping ((Result<([MoviePreviewCellModel],Int?),Error>) -> Void)) {
        
        getListOfMovies(endpoint: ApiEndpoint.getUpcomingMovies(page: page ?? 1), page: page, listName: upcomingListName, completion: completion)
    }
    
    func getNowPlayingMovies(_ page: Int? = nil, _ completion: @escaping ((Result<([MoviePreviewCellModel],Int?),Error>) -> Void)) {
        
        getListOfMovies(endpoint: ApiEndpoint.getNowPlayingMovies(page: page ?? 1), page: page, listName: nowPlayingListName, completion: completion)
    }
    
    func getGenres(_ completion: @escaping ((Result<[Genre],Error>)) -> Void) {
        networkManager.getData(with: ApiEndpoint.getGenres) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                guard let genresData = self.dataParser.parse(withData: data, to: GenreListData.self) else {
                    completion(.failure(MoviesManagerError.parseError))
                    return
                }
                self.genres = genresData.genres
            }
        }
    }
    
    private func getListOfMovies(endpoint: ApiEndpoint, page: Int? = nil, listName: String, completion: @escaping ((Result<([MoviePreviewCellModel],Int?),Error>) -> Void)) {
        
        networkManager.getData(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                guard let moviesListData = self.dataParser.parse(withData: data, to: MoviesListData.self) else {
                    completion(.failure(MoviesManagerError.parseError))
                    return
                }
                if page == 1 {
//                    self.deletePreviousData()
                }
                
                // MARK: - Saving movies Data to DB
                let movies = self.saveMovies(listName: listName, moviesListData.results)
                completion(.success((self.createMoviePreviewCellModel(from: movies), moviesListData.page)))
            }
        }
    }
    
    
    //MARK: - Create lists which will store movies previews
    private func createMoviesLists() {
        let popularList = List(context: context)
        popularList.name = "Popular"
        
        let upcomingList = List(context: context)
        upcomingList.name = "Upcoming"
        
        let nowPlayingList = List(context: context)
        nowPlayingList.name = "Now Playing"
    }
    
    private func saveMovies(listName: String, _ movies: [Movie]) -> [MoviePreview] {
        
        let list = List(context: context)
        list.name = listName
        
        // Create a movie object
        for movie in movies {
            let newMovie = MoviePreview(context: self.context)
            
            newMovie.title = movie.title
            newMovie.genreId = Int64(movie.genreIds.first ?? 0)
            matchGenres(newMovie)
            newMovie.posterPath = movie.posterPath
            newMovie.genreName = genreName ?? ""
            newMovie.voteAverage = Double(movie.voteAverage)
            
            list.addToMovies(newMovie)
        }
        
        //Save the data
        do {
            try self.context.save()
        }
        catch {
            
        }
        
        // Re-fetch
        return self.fetchMovies(listName: listName)
    }
    
    private func fetchMovies(listName: String) -> [MoviePreview] {
        
        do {
            let request = List.fetchRequest() as NSFetchRequest<List>
            
            let predicate = NSPredicate(format: "name CONTAINS %@", listName)
            request.predicate = predicate
            
            let moviesSet = try context.fetch(request)
            return moviesSet.first?.movies?.allObjects as? [MoviePreview] ?? []
        }
        catch {
            return []
        }
    }
    
    //MARK: - Сreate cell model from CoreData Model
    private func createMoviePreviewCellModel(from moviesData: [MoviePreview]) -> [MoviePreviewCellModel] {
        return moviesData.map { movie -> MoviePreviewCellModel in
            
            return MoviePreviewCellModel(
                title: movie.title,
                voteAverage: movie.voteAverage,
                genreName: movie.genreName,
                posterPath: movie.posterPath
            )
        }
    }
    
    private func matchGenres(_ movie: MoviePreview) {
        let filteredArray = genres.filter { $0.id == movie.genreId }
        filteredArray.forEach { genre in
            genreName = genre.name
        }
    }
    
    
    private func deletePreviousData() {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MoviePreview")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print(error, error.localizedDescription)
        }
    }
}
