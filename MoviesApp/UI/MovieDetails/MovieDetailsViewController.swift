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
    
    var moviePreviewData: MovieDetailsTransferData?
    var movie: MovieDetailsModel? {
        self.moviesManager.getMovieDetails(movieId: moviePreviewData?.movieId)
    }
    var videos: [VideoCellModel]? {
        self.moviesManager.getVideoDetails(movieId: moviePreviewData?.movieId)
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
        
        moviesManager.getMoviesDetails(movieId: moviePreviewData?.movieId) { [weak self] result in
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
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func configureSubviews() {
        self.view.backgroundColor = .white
        tableView.register(MoviesMainInfoCell.self, forCellReuseIdentifier: MoviesMainInfoCell.reuseId)
        tableView.register(MoviesOverviewCell.self, forCellReuseIdentifier: MoviesOverviewCell.reuseId)
        tableView.register(MoviesRatingCell.self, forCellReuseIdentifier: MoviesRatingCell.reuseId)
        tableView.register(MoviesBudgetAndRevenueCell.self, forCellReuseIdentifier: MoviesBudgetAndRevenueCell.reuseId)
        tableView.register(VideosTableViewCell.self, forCellReuseIdentifier: VideosTableViewCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension MovieDetailsViewController: UITableViewDelegate {
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
            if moviePreviewData?.rating != nil && moviePreviewData?.rating != 0 {
                return headerView
            } else {
                return nil
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movie?.revenue != nil && movie?.revenue != 0) {
                return headerView
            } else {
                return nil
            }
        case 4:
            if (videos ?? []).isEmpty || videos == nil {
                return nil
            } else {
                return headerView
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
            if moviePreviewData?.rating != nil && moviePreviewData?.rating != 0 {
                return 20
            } else {
                return 0
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movie?.revenue != nil && movie?.revenue != 0) {
                return 20
            } else {
                return 0
            }
        case 4:
            if (videos ?? []).isEmpty || videos == nil {
                return 0
            } else {
                return 20
            }
        default:
            fatalError()
        }
    }
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
            if moviePreviewData?.rating != nil && moviePreviewData?.rating != 0 {
                return 1
            } else {
                return 0
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movie?.revenue != nil && movie?.revenue != 0) {
                return 1
            } else {
                return 0
            }
        case 4:
            if (videos ?? []).isEmpty || videos == nil {
                return 0
            } else {
                return 1
            }
        default:
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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
            if moviePreviewData?.rating != nil && moviePreviewData?.rating != 0 {
                return "Rating"
            } else {
                return ""
            }
        case 3:
            if (movie?.budget != nil && movie?.budget != 0) && (movie?.revenue != nil && movie?.revenue != 0) {
                return "Budget & Revenue"
            } else {
                return ""
            }
        case 4:
            if (videos ?? []).isEmpty || videos == nil {
                return ""
            } else {
                return "Videos"
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
                posterPath: moviePreviewData?.posterPath,
                title: moviePreviewData?.title,
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
            ratingCell.configure(with: moviePreviewData?.rating, tableViewWidth: tableView.frame.width)
            return ratingCell
        case 3:
            let moviesBudgetAndRevenueCell = tableView.dequeueReusableCell(
                withIdentifier: MoviesBudgetAndRevenueCell.reuseId,
                for: indexPath
            ) as! MoviesBudgetAndRevenueCell
            moviesBudgetAndRevenueCell.configure(budget: movie?.budget, revenue: movie?.revenue)
            return moviesBudgetAndRevenueCell
        case 4:
            let videosCell = tableView.dequeueReusableCell(
                withIdentifier: VideosTableViewCell.reuseId,
                for: indexPath
            ) as! VideosTableViewCell
            guard let videos = videos else { return videosCell }
            videosCell.configure(with: videos)
            return videosCell
        default:
            fatalError()
        }
    }
}
