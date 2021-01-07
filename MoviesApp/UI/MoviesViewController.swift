//
//  MoviesViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit
import CoreData

class MoviesViewController: UITableViewController {
    
    private let moviesTableViewCell = MoviesTableViewCell()
    
    let moviesManager = MoviesManager()
    var listName: ListName?
    var categories: [(ListName, [MoviePreviewCellModel])] {
        ListName.allCases.map {
            self.moviesManager.getCategories(listName: $0)
        }
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Movies"
        
        tableView.register(MoviesTableViewCell.self, forCellReuseIdentifier: MoviesTableViewCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
        
        refreshControl.beginRefreshing()
        loadData()
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        loadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
        
        let movies = categories[indexPath.row]
        listName = movies.0
        cell.cellDelegate = self
        cell.configureList(with: movies.0, movies: movies.1)
        
        return cell
    }
    
    private func loadData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.moviesManager.loadMovies(page: 1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl?.endRefreshing()
                switch result {
                case let .failure(error):
                    self.showError(error)
                case .success:
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension MoviesViewController: MoviesTableViewCellDelegate {
    func showFullList(with name: ListName) {
        let controller = ListViewController()
        controller.listName = name
        navigationController?.pushViewController(controller, animated: true)
        controller.isLoading = true
        controller.loadPage()
    }
    
    func showMovieDetails(with indexPath: IndexPath, movies: [MoviePreviewCellModel]) {
        let controller = MovieDetailsViewController()
        navigationController?.pushViewController(controller, animated: true)
        let movie = movies[indexPath.row]
        controller.movieId = movie.movieId
    }
}
