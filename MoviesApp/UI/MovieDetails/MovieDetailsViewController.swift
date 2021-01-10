//
//  MovieDetailsViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 05.01.2021.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let moviesManager = MoviesManager()
    private var refreshControl = UIRefreshControl()
    
    var movieId: Int?
    var movieTitle: String?
    var moviePosterPath: String?
    var movieRating: Double?
    var movie: MovieDetailsModel? {
        self.moviesManager.getMovieDetails(movieId: movieId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        addSubviews()
        setConstraints()
        configureSubviews()
        
        refreshControl.beginRefreshing()
        loadDetails()
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        loadDetails()
    }
    
    private func loadDetails() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        moviesManager.getMoviesDetails(movieId: movieId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl.endRefreshing()
                switch result {
                case let .failure(error):
                    self.showError(error)
                    return
                case .success:
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func addSubviews() {
        self.view.addSubview(tableView)
    }
    
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    private func configureSubviews() {
        self.view.backgroundColor = .white
        tableView.register(MoviesMainInfoCell.self, forCellReuseIdentifier: MoviesMainInfoCell.reuseId)
        tableView.register(MoviesOverviewCell.self, forCellReuseIdentifier: MoviesOverviewCell.reuseId)
        tableView.register(MoviesRatingCell.self, forCellReuseIdentifier: MoviesRatingCell.reuseId)
        tableView.register(MoviesBudgetAndRevenueCell.self, forCellReuseIdentifier: MoviesBudgetAndRevenueCell.reuseId)
    }
}

extension MovieDetailsViewController: UITableViewDelegate {
    
}

extension MovieDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if movie?.overview != nil && movie?.overview != "" {
                return 1
            } else {
                return 0
            }
        case 2:
            if movieRating != nil && movieRating != 0 {
                return 1
            } else {
                return 0
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movieRating != nil && movieRating != 0) {
                return 1
            } else {
                return 0
            }
        default:
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .gray
        label.frame = CGRect(x: 16, y: 0, width: 150, height: 20)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(label)
        headerView.backgroundColor = .white
        
        switch section {
        case 0:
            return nil
        case 1:
            if movie?.overview != nil && movie?.overview != "" {
                return headerView
            } else {
                return nil
            }
        case 2:
            if movieRating != nil && movieRating != 0 {
                return headerView
            } else {
                return nil
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movieRating != nil && movieRating != 0) {
                return headerView
            } else {
                return nil
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            if movie?.overview != nil && movie?.overview != "" {
                return 20
            } else {
                return 0
            }
        case 2:
            if movieRating != nil && movieRating != 0 {
                return 20
            } else {
                return 0
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movieRating != nil && movieRating != 0) {
                return 20
            } else {
                return 0
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            if movie?.overview != nil && movie?.overview != "" {
                return "Overview"
            } else {
                return ""
            }
        case 2:
            if movieRating != nil && movieRating != 0 {
                return "Rating"
            } else {
                return ""
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movieRating != nil && movieRating != 0) {
                return "Budget & Revenue"
            } else {
                return ""
            }
        default:
            fatalError()
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let moviesMainInfoCell = tableView.dequeueReusableCell(
                withIdentifier: MoviesMainInfoCell.reuseId,
                for: indexPath
            ) as! MoviesMainInfoCell
            moviesMainInfoCell.configure(
                posterPath: moviePosterPath,
                title: movieTitle,
                originalName: movie?.originalTitle,
                year: movie?.releaseDate,
                genres: movie?.genresNames,
                country: movie?.country,
                runtime: movie?.runtime,
                adult: movie?.adult
            )
            return moviesMainInfoCell
        case 1:
            let moviesOverviewCell = tableView.dequeueReusableCell(
                withIdentifier: MoviesOverviewCell.reuseId,
                for: indexPath
            ) as! MoviesOverviewCell
            moviesOverviewCell.configure(with: movie?.overview)
            return moviesOverviewCell
        case 2:
            let ratingCell = tableView.dequeueReusableCell(
                withIdentifier: MoviesRatingCell.reuseId,
                for: indexPath
            ) as! MoviesRatingCell
            ratingCell.configure(with: movieRating)
            return ratingCell
        case 3:
            let moviesBudgetAndRevenueCell = tableView.dequeueReusableCell(
                withIdentifier: MoviesBudgetAndRevenueCell.reuseId,
                for: indexPath
            ) as! MoviesBudgetAndRevenueCell
            moviesBudgetAndRevenueCell.configure(budget: movie?.budget, revenue: movie?.revenue)
            return moviesBudgetAndRevenueCell
        default:
            fatalError()
        }
    }
}
