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
    private var pageNumber: Int?
    
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
    
    func getMovieDetails(movieId: Int?) -> MovieDetailsModel? {
        guard let movieId = movieId else { return nil }
        guard let fetchedMovie = fetchMovieById(movieId: movieId) else { return nil }
        return createMovieDetailsModel(from: fetchedMovie)
    }
    
    public func loadMovies(page: Int? = nil, _ completion: @escaping ((Result<(Int?),Error>) -> Void)) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .background)
        
        group.enter()
        queue.async {
            self.getGenres() { result in
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
                        // MARK: - Deleting previous data
                        if page == 1 {
                            ListName.allCases.forEach { list in
                                self.deletePreviousData(for: list.rawValue)
                            }
                        }
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
            self.getGenres() { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
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
                        if data.0.isEmpty {
                            self.pageNumber = nil
                        } else {
                            self.pageNumber = page
                        }
                        // MARK: - Deleting previous data
                        if page == 1 {
                            self.deletePreviousData(for: listName.rawValue)
                        }
                        group.leave()
                    }
                }
            }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // MARK: - Saving movies Data to DB
            for movie in self.lists {
                self.saveMovies(listName: movie.0.rawValue, movie.1)
            }
            
            completion(.success(self.pageNumber))
        }
    }
    
    public func getMoviesDetails(movieId: Int?, completion: @escaping ((Result<MoviesDetailsData,Error>) -> Void)) {
        guard let movieId = movieId else { return }
        networkManager.getData(with: ApiEndpoint.getMovieDetails(movieId: movieId)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                guard let moviesDetailsData = self.dataParser.parse(withData: data, to: MoviesDetailsData.self) else {
                    completion(.failure(MoviesManagerError.parseError))
                    return
                }
                    self.saveDetails(movieId: movieId, details: moviesDetailsData)
                completion(.success(moviesDetailsData))
            }
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
                
                completion(.success((moviesListData.results, moviesListData.page)))
            }
        }
    }
    
    private func saveDetails(movieId: Int?, details: MoviesDetailsData) -> () {
        context.refreshAllObjects()
        
        guard let movieId = movieId else { return }
        let movie = fetchMovieById(movieId: movieId)
        movie?.setValue(details.adult, forKey: "adult")
        let genres = Array(details.genres.map {$0.name as NSString})
        movie?.setValue(genres, forKey: "genreName")
        movie?.setValue(details.originalTitle, forKey: "originalTitle")
        movie?.setValue(details.countries.first?.name, forKey: "country")
        movie?.setValue(details.releaseDate, forKey: "releaseDate")
        movie?.setValue(Int64(details.runtime ?? 0), forKey: "runtime")
        movie?.setValue(details.overview ?? "", forKey: "overview")
        movie?.setValue(Int64(details.budget), forKey: "budget")
        movie?.setValue(Int64(details.revenue), forKey: "revenue")
        
        //MARK: - Saving data
        do {
            try context.save()
        }
        catch let error as NSError {
            print(error, error.localizedDescription)
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
            let mainGenreName = (genreName ?? "") as NSString
            newMovie.genreName.append(mainGenreName)
            newMovie.voteAverage = Double(movie.voteAverage)
            newMovie.movieId = Int64(movie.id)
            
            list.addToMovies(newMovie)
        }
        
        //MARK: - Saving data
        do {
            try context.save()
        }
        catch let error as NSError {
            print(error, error.localizedDescription)
        }
    }
    
    private func fetchMovieById(movieId: Int) -> MoviePreview? {
        do {
            let request = MoviePreview.fetchRequest() as NSFetchRequest<MoviePreview>
            let predicate = NSPredicate(format: "movieId = %@", NSNumber(value: movieId))
            request.predicate = predicate
            
            let moviesSet = try context.fetch(request)
            guard let movie = moviesSet.first else { return nil }
            return movie
        }
        catch {
            return nil
        }
    }
    
    private func fetchMovies(listName: String) -> [MoviePreview] {
        
        do {
            let request = List.fetchRequest() as NSFetchRequest<List>
            
            let predicate = NSPredicate(format: "name CONTAINS %@", listName)
            request.predicate = predicate
            
            let moviesList = try context.fetch(request)
            let moviesSet = moviesList.first?.movies?.allObjects as? [MoviePreview] ?? []
            let sortedMovies = moviesSet.sorted { $0.title ?? "" < $1.title ?? "" }
            return sortedMovies
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
                genreName: String(movie.genreName.first ?? ""),
                posterPath: movie.posterPath,
                movieId: Int(truncatingIfNeeded: movie.movieId)
            )
        }
    }
    
    private func createMovieDetailsModel(from moviesData: MoviePreview) -> MovieDetailsModel {
        return MovieDetailsModel(
            adult: moviesData.adult,
            genresNames: moviesData.genreName as [String],
            originalTitle: moviesData.originalTitle ?? "",
            country: moviesData.country ?? "",
            releaseDate: dateFormat(with: moviesData.releaseDate ?? ""),
            runtime: Int(moviesData.runtime),
            overview: moviesData.overview,
            budget: Int(moviesData.budget),
            revenue: Int(moviesData.revenue)
        )
    }
    
    private func matchGenres(_ movie: MoviePreview) {
        let filteredArray = genres.filter { $0.id == movie.genreId }
        filteredArray.forEach { genre in
            genreName = genre.name
        }
    }
    
    
    private func deletePreviousData(for listName: String) {
        
        DispatchQueue.main.async {
            let fetchRequest = List.fetchRequest() as NSFetchRequest<List>
            let predicate = NSPredicate(format: "name CONTAINS %@", listName)
            fetchRequest.predicate = predicate
            
            do {
                let moviesSet = try self.context.fetch(fetchRequest)
                let movies = moviesSet.first?.movies?.allObjects as? [MoviePreview] ?? []
                for movie in movies {
                    self.context.delete(movie)
                }
                try self.context.save()
            } catch let error as NSError {
                print(error, error.localizedDescription)
            }
        }
    }
}

private extension MoviesManager {
    func dateFormat(with date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let formattedDate = dateFormatter.date(from: date) else { return "" }
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: formattedDate)
    }
}
