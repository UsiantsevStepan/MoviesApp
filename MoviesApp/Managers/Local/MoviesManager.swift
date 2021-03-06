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
    private var moviesDetails: MoviesDetailsData?
    private var videos = [VideoData?]()
    private var searchData = [SuitableMovie]()
    private var searchingTotalPages = 0
    
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
    
    func getVideoDetails(movieId: Int?) -> [VideoCellModel]? {
        guard let movieId = movieId else { return nil }
        let fetchVideos = fetchVideo(by: movieId)
        return createVideoCellModel(from: fetchVideos)
    }
    
    public func loadSearchdMovies(with searchText: String, page: Int, completion: @escaping ((Result<(Int,[MoviePreviewCellModel]),Error>)) -> Void) {
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
            self.networkManager.getData(with: ApiEndpoint.searchMovie(text: searchText, page: page)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    group.leave()
                case let .success(data):
                    guard let searchData = self.dataParser.parse(withData: data, to: SearchData.self) else {
                        completion(.failure(MoviesManagerError.parseError))
                        return
                    }
                    self.searchData = searchData.results
                    guard let totalPages = searchData.totalPages else {
                        completion(.failure(MoviesManagerError.parseError))
                        return
                    }
                    self.searchingTotalPages = totalPages
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            completion(.success((self.searchingTotalPages, self.createSearchedMoviePreviewCellModel(from: self.searchData))))
        }
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
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .background)
        
        group.enter()
        queue.async {
            self.networkManager.getData(with: ApiEndpoint.getMovieDetails(movieId: movieId)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    group.leave()
                case let .success(data):
                    guard let moviesDetailsData = self.dataParser.parse(withData: data, to: MoviesDetailsData.self) else {
                        completion(.failure(MoviesManagerError.parseError))
                        return
                    }
                    self.moviesDetails = moviesDetailsData
                    group.leave()
                }
            }
        }
        
        group.enter()
        queue.async {
            self.networkManager.getData(with: ApiEndpoint.getVideos(movieId: movieId)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    group.leave()
                case let .success(data):
                    guard let videosData = self.dataParser.parse(withData: data, to: VideosData.self) else {
                        completion(.failure(MoviesManagerError.parseError))
                        return
                    }
                    self.videos = videosData.results
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            guard let moviesDetails = self.moviesDetails else {
                completion(.failure(MoviesManagerError.parseError))
                return
            }
            self.saveDetails(movieId: movieId, details: moviesDetails, videos: self.videos)
            completion(.success(moviesDetails))
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
    
    private func saveDetails(movieId: Int?, details: MoviesDetailsData, videos: [VideoData?]) {
        guard let movieId = movieId else { return }
        
        if let movie = fetchMovieById(movieId: movieId) {
            updateManagedObject(with: movie, details: details, videos: videos)
        }
        else {
            createManagedObject(with: movieId, details: details, videos: videos)
        }
    }
    
    private func updateManagedObject(with movie: MoviePreview, details: MoviesDetailsData, videos: [VideoData?]) {
        movie.adult = details.adult
        let genres = Array(details.genres.map {$0.name as NSString})
        movie.genreName = genres
        movie.originalTitle = details.originalTitle
        movie.country = details.countries.first?.name
        movie.releaseDate = details.releaseDate
        if let movieRuntime = details.runtime {
            movie.runtime = Int64(movieRuntime)
        }
        movie.overview = details.overview
        movie.budget = Int64(details.budget)
        movie.revenue = Int64(details.revenue)
        
        // MARK: - Saving videos to DB
        for video in videos {
            let newVideo = Video(context: self.context)
            
            guard video?.site == "YouTube" else { continue }
            newVideo.key = video?.key
            newVideo.site = video?.site
            newVideo.type = video?.type
            
            movie.addToVideos(newVideo)
        }
        
        //MARK: - Saving data
        do {
            try context.save()
        }
        catch let error as NSError {
            print(error, error.localizedDescription)
        }
    }
    
    private func createManagedObject(with movieId: Int, details: MoviesDetailsData, videos: [VideoData?]) {
        let newMovie = MoviePreview(context: context)
        newMovie.title = details.title
        newMovie.movieId = Int64(movieId)
        newMovie.voteAverage = details.voteAverage
        newMovie.posterPath = details.posterPath
        newMovie.adult = details.adult
        let genres = Array(details.genres.map {$0.name as NSString})
        newMovie.genreName = genres
        newMovie.originalTitle = details.originalTitle
        newMovie.country = details.countries.first?.name
        newMovie.releaseDate = details.releaseDate
        if let movieRuntime = details.runtime {
            newMovie.runtime = Int64(movieRuntime)
        }
        newMovie.overview = details.overview
        newMovie.budget = Int64(details.budget)
        newMovie.revenue = Int64(details.revenue)
        
        // MARK: - Saving videos to DB
        for video in videos {
            let newVideo = Video(context: self.context)
            
            guard video?.site == "YouTube" else { continue }
            newVideo.key = video?.key
            newVideo.site = video?.site
            newVideo.type = video?.type
            
            newMovie.addToVideos(newVideo)
        }
        
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
        for movie in movies {
            let newMovie = MoviePreview(context: self.context)
            
            newMovie.popularity = movie.popularity
            newMovie.title = movie.title
            newMovie.genreId = Int64(movie.genreIds.first ?? 0)
            matchGenresForStoredMovie(newMovie)
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
        } catch {
            return nil
        }
    }
    
    private func fetchVideo(by movieId: Int) -> [Video] {
        do {
            let request = MoviePreview.fetchRequest() as NSFetchRequest<MoviePreview>
            let predicate = NSPredicate(format: "movieId = %@", NSNumber(value: movieId))
            request.predicate = predicate
            
            let moviesSet = try context.fetch(request)
            let videos = moviesSet.first?.videos?.allObjects as? [Video] ?? []
            return videos
        } catch {
            return []
        }
    }
    
    private func fetchMovies(listName: String) -> [MoviePreview] {
        
        do {
            let request = List.fetchRequest() as NSFetchRequest<List>
            
            let predicate = NSPredicate(format: "name CONTAINS %@", listName)
            request.predicate = predicate
            
            let moviesList = try context.fetch(request)
            let moviesSet = moviesList.first?.movies?.allObjects as? [MoviePreview] ?? []
            let sortedMovies = moviesSet.sorted { $0.popularity > $1.popularity }
            return sortedMovies
        }
        catch {
            return []
        }
    }
    
    //MARK: - Сreating cell models from CoreData Models
    
    private func createMoviePreviewCellModel(from moviesData: [MoviePreview]) -> [MoviePreviewCellModel] {
        return moviesData.map { movie -> MoviePreviewCellModel in
            
            return MoviePreviewCellModel(
                title: movie.title,
                voteAverage: movie.voteAverage,
                genreName: String(movie.genreName.first ?? ""),
                posterPath: movie.posterPath,
                movieId: Int(truncatingIfNeeded: movie.movieId),
                popularity: movie.popularity
            )
        }
    }
    
    private func createSearchedMoviePreviewCellModel(from moviesData: [SuitableMovie]) -> [MoviePreviewCellModel] {
        return moviesData.map { movie -> MoviePreviewCellModel in
            return MoviePreviewCellModel(
                title: movie.title,
                voteAverage: movie.voteAverage,
                genreName: matchGenresForSearchedMovies(movie),
                posterPath: movie.posterPath,
                movieId: movie.id,
                popularity: movie.popularity
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
    
    private func createVideoCellModel(from videoData: [Video]) -> [VideoCellModel] {
        return videoData.map { video -> VideoCellModel in
            return VideoCellModel(
                key: video.key ?? "",
                site: video.site ?? "",
                type: video.type ?? ""
            )
        }
    }
    
    private func matchGenresForStoredMovie(_ movie: MoviePreview) {
        let filteredArray = genres.filter { $0.id == movie.genreId }
        filteredArray.forEach { genre in
            genreName = genre.name
        }
    }
    
    private func matchGenresForSearchedMovies(_ movie: SuitableMovie) -> String {
        let filteredArray = genres.filter { $0.id == movie.genreIds.first }
        var name = ""
        filteredArray.forEach { genre in
            name = genre.name
        }
        return name
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
