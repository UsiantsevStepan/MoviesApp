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
    
    private let moviesTableViewCell = MoviesTableViewCell()
    private var movieDataError: Error?
    //    private var firstPageData = [MoviePreviewCellModel]()
    var popularMovies = [MoviePreviewCellModel]()
    var upcomingMovies = [MoviePreviewCellModel]()
    var nowPlayingMovies = [MoviePreviewCellModel]()
    //    {
    //        didSet {
    //            tableView.reloadData()
    //        }
    //    }
    private var nextPage: Int?
    
    override func viewDidLoad() {
        
        tableView.register(MoviesTableViewCell.self, forCellReuseIdentifier: MoviesTableViewCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        self.moviesManager.getGenres() { [weak self] result in
            guard let self = self else { return }
        }
        
        self.moviesManager.getPopularMovies(1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self.movieDataError = error
                case let .success(data):
                    self.popularMovies.append(contentsOf: data.0)
                    self.nextPage = (data.1 ?? 1) + 1
                    self.tableView.reloadData()
                }
            }
        }
        
        self.moviesManager.getUpcomingMovies(1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self.movieDataError = error
                case let .success(data):
                    self.upcomingMovies.append(contentsOf: data.0)
                    self.nextPage = (data.1 ?? 1) + 1
                    self.tableView.reloadData()
                }
            }
        }
        
        self.moviesManager.getNowPlayingMovies(1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self.movieDataError = error
                case let .success(data):
                    self.nowPlayingMovies.append(contentsOf: data.0)
                    self.nextPage = (data.1 ?? 1) + 1
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let popularMoviesCell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
                popularMoviesCell.selectionStyle = .none
                popularMoviesCell.contentView.isUserInteractionEnabled = false
                popularMoviesCell.configureHeaderLabel(with: "Popular")
                popularMoviesCell.configure(popularMovies)
                //                cell0.headerButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
                return popularMoviesCell
            case 1:
                let upcomingMoviesCell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
                upcomingMoviesCell.selectionStyle = .none
                upcomingMoviesCell.contentView.isUserInteractionEnabled = false
                upcomingMoviesCell.configureHeaderLabel(with: "Upcoming")
                upcomingMoviesCell.configure(upcomingMovies)
                return upcomingMoviesCell
            case 2:
                let nowPlayingMoviesCell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
                nowPlayingMoviesCell.selectionStyle = .none
                nowPlayingMoviesCell.contentView.isUserInteractionEnabled = false
                nowPlayingMoviesCell.configureHeaderLabel(with: "Now playing")
                nowPlayingMoviesCell.configure(nowPlayingMovies)
                return nowPlayingMoviesCell
            default:
                fatalError("Something went wrong")
            }
        default:
            fatalError()
        }
    }
    
    // MARK: - Add functions to all buttons
    @objc func buttonAction(_ sender: UIButton) {
        print("Tapped")
    }
}
