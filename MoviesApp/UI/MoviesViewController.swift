//
//  MoviesViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit
import CoreData

class MoviesViewController: UITableViewController {
    
    let moviesManager = MoviesManager()
    
    var categories: [(ListName, [MoviePreviewCellModel])] {
        ListName.allCases.map {
            self.moviesManager.getCategories(listName: $0)
        }
    }
    
    private let moviesTableViewCell = MoviesTableViewCell()
    
    override func viewDidLoad() {
        
        tableView.register(MoviesTableViewCell.self, forCellReuseIdentifier: MoviesTableViewCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        loadData()
    }
    
    private func loadData() {
        var movieDataError: Error?
        var genreDataError: Error?
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .background)
        
        group.enter()
        queue.async {
            self.moviesManager.getGenres() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    genreDataError = error
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
        group.enter()
        queue.async {
            self.moviesManager.getPopularMovies(1) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    movieDataError = error
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
        group.enter()
        queue.async {
            self.moviesManager.getUpcomingMovies(1) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    movieDataError = error
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
        group.enter()
        queue.async {
            self.moviesManager.getNowPlayingMovies(1) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    movieDataError = error
                    group.leave()
                case .success:
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if let unwrappedMovieDataError = movieDataError {
                self.showError(unwrappedMovieDataError)
            } else if let unwrappedGenreDataError = genreDataError {
                self.showError(unwrappedGenreDataError)
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
        
        //        let key = ListName.allCases[indexPath.row].rawValue
        let movies = categories[indexPath.row]
        cell.configureList(with: movies.0, movies: movies.1)
        
        return cell
        
        //                cell0.headerButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    
    // MARK: - Add functions to all buttons
    @objc func buttonAction(_ sender: UIButton) {
        print("Tapped")
    }
}
