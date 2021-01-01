//
//  MovieManager.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 02.10.2020.
//

import CoreData
import UIKit

class MoviesManager {
    enum MoviesManagerError: LocalizedError {
        case parseError
        
        var errorDescription: String? {
            return "Data hasn't been parsed or has been parsed incorrectly"
        }
    }
    
    private var lists = [(ListName, [Movie])]()
    
    let dataParser = DataParser()
    let networkManager = NetworkManager()
    var genres = [Genre]()
    var genreName: String?
    
    //MARK: - Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistentStoreCoordinator = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator
    
    
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
                completion(.success(self.genres))
            }
        }
    }
    
    func getCategories(listName: ListName) -> (ListName, [MoviePreviewCellModel]) {
        let fetchedMovies = fetchMovies(listName: listName.rawValue)
        return (listName, createMoviePreviewCellModel(from: fetchedMovies))
    }
    
    public func loadMovies(_ page: Int? = nil, _ completion: @escaping ((Result<(Int?),Error>) -> Void)) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .background)
        
        group.enter()
        queue.async {
            self.getGenres() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
        ListName.allCases.forEach { list in
            group.enter()
            queue.async {
                self.getListOfMovies(endpoint: ApiEndpoint.getMovies(page: page ?? 1, path: list.searchPath), listName: list.rawValue) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        group.leave()
                    case let .success(data):
                        self.lists.append((list, data.0))
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // MARK: - Saving movies Data to DB
            for movie in self.lists {
                self.saveMovies(listName: movie.0.rawValue, movie.1)
            }
            completion(.success(page))
            
        }
    }
    
    public func loadList(page: Int? = nil, listName: ListName, _ completion: @escaping ((Result<(Int?),Error>) -> Void)) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .background)
        
        group.enter()
        queue.async {
            self.getGenres() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
//        ListName.allCases.forEach { list in
            group.enter()
            queue.async {
                self.getListOfMovies(endpoint: ApiEndpoint.getMovies(page: page ?? 1, path: listName.searchPath), listName: listName.rawValue) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                        group.leave()
                    case let .success(data):
                        self.lists.append((listName, data.0))
                        group.leave()
                    }
                }
            }
//        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // MARK: - Saving movies Data to DB
            for movie in self.lists {
                self.saveMovies(listName: movie.0.rawValue, movie.1)
            }
            completion(.success(page))
            
        }
    }
    
    private func getListOfMovies(endpoint: ApiEndpoint, page: Int? = nil, listName: String, completion: @escaping ((Result<([Movie],Int?),Error>) -> Void)) {
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
                    self.deletePreviousData(for: listName)
                }
                
                completion(.success((moviesListData.results, moviesListData.page)))
            }
        }
    }
    
    private func saveMovies(listName: String, _ movies: [Movie]) -> () {
        
        //MARK: - Creating lists which will store movies previews
        let list = List(context: context)
        list.name = listName
        
        //MARK: - Creating a movie object
        context.refreshAllObjects()
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
        
        //MARK: - Saving data
        do {
            try self.context.save()
        }
        catch let error as NSError {
            print(error, error.localizedDescription)
        }
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
    
    //MARK: - Сreating cell model from CoreData Model
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
    
    
    private func deletePreviousData(for listName: String) {
        let fetchRequest = List.fetchRequest() as NSFetchRequest<List>
        let predicate = NSPredicate(format: "name CONTAINS %@", listName)
        fetchRequest.predicate = predicate
        
        do {
            let moviesSet = try context.fetch(fetchRequest)
            let movies = moviesSet.first?.movies?.allObjects as? [MoviePreview] ?? []
            for movie in movies {
                context.delete(movie)
            }
            try context.save()
        } catch let error as NSError {
            print(error, error.localizedDescription)
        }
    }
}
