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
    
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getPopularMoviesData(_ page: Int? = nil, _ completion: @escaping ((Result<([MoviePreviewCellModel],Int?),Error>) -> Void)) {
        networkManager.getData(with: ApiEndpoint.getPopularMovies(page: page ?? 1)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                guard let moviesListData = self.dataParser.parse(withData: data, to: MoviesListData.self) else {
                    completion(.failure(MoviesManagerError.parseError))
                    return
                }
                // MARK: - Saving popular movies data to DB
                let movies = self.savePopularMovies(moviesListData.results)
                completion(.success((self.createMoviePreviewCellModel(from: movies),moviesListData.page)))
            }
        }
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
    
    func savePopularMovies(_ movies: [Movie]) -> [MoviePreview] {
        
        // Create a movie object
        for movie in movies {
            let newPopularMovie = MoviePreview(context: self.context)
            
            
            newPopularMovie.title = movie.title
            newPopularMovie.genreId = Int64(movie.genreIds.first ?? 0)
            matchGenres(newPopularMovie)
            newPopularMovie.posterPath = movie.posterPath
            newPopularMovie.genreName = genreName ?? ""
        }
        
        //Save the data
        do {
            try self.context.save()
        }
        catch {
            
        }
        
        // Re-fetch
        return self.fetchMovies()
    }
    
    func fetchMovies() -> [MoviePreview] {
        
        // Fetch the data from Core Data to display in the tableview
        do {
            return try context.fetch(MoviePreview.fetchRequest())
        }
        catch {
            return []
        }
    }
    
    //MARK: - Create cell model from CoreData Model
    private func createMoviePreviewCellModel(from moviesData: [MoviePreview]) -> [MoviePreviewCellModel] {
        return moviesData.map { movie -> MoviePreviewCellModel in
            
            return MoviePreviewCellModel(
                title: movie.title,
                genreName: movie.genreName,
                posterPath: movie.posterPath
            )
        }
    }
    
    private func matchGenres(_ movie: MoviePreview) {
        let filteredArray = genres.filter { $0.id == movie.genreId }
        filteredArray.map { id -> () in
            genreName = id.name
            return
        }
    }
}
