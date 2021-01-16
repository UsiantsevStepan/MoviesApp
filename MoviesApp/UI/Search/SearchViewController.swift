//
//  SearchViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 13.01.2021.
//

import UIKit

class SearchViewController: UIViewController {
    private let moviesManager = MoviesManager()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())    
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchText = ""
    private var moviesIds = [Int]()
    private var movies: [MoviePreviewCellModel] = []
    private var totalPages: Int?
    private var currentPage = 1
    private var currentSearchText = ""
    private var isRefreshing = false
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationItem.searchController = searchController
        
        addSubviews()
        setConstraints()
        configureSubviews()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > 0,
           offsetY > contentHeight - scrollView.frame.height - 100 {
            loadPage(with: currentSearchText, currentPage)
        }
    }
    
    private func loadPage(with text: String, _ page: Int) {
        if isLoading || currentPage > (totalPages ?? 10) { return }
        isLoading = true
        
        moviesManager.loadSearchdMovies(with: text, page: page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self.showError(error)
                    self.isLoading = false
                    return
                case let .success((pages, movies)):
                    self.totalPages = pages
                    self.movies += movies
                    
                    if self.currentPage == self.totalPages {
                        self.isLoading = false
                    }
                    self.currentPage += 1
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    private func setConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }
    
    private func configureSubviews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.estimatedItemSize = .zero
        collectionView.contentInset.top = 16
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(MoviesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesCollectionViewCell.cellId)
        collectionView.register(
            FooterCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: FooterCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.searchBar.clipsToBounds = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a movie..."
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.cellId, for: indexPath) as! MoviesCollectionViewCell
        let sortedMovies = movies.sorted { ($0.popularity ?? 1) > ($1.popularity ?? 0) }
        let movies = sortedMovies[indexPath.row]
        cell.configure(with: movies)
        
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] () -> UIViewController? in
            guard let self = self else { return nil }
            let sortedMovies = self.movies.sorted { ($0.popularity ?? 1) > ($1.popularity ?? 0) }
            let movie = sortedMovies[indexPath.item]

            let detailsViewController = MovieDetailsViewController()
            detailsViewController.movieId = movie.movieId
            detailsViewController.moviePosterPath = movie.posterPath
            detailsViewController.movieTitle = movie.title
            detailsViewController.movieRating = movie.voteAverage
            
            return detailsViewController
        }, actionProvider: nil)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 129, height: 222)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: (collectionView.frame.size.width / 2 - 129) / 1.5,
            bottom: 0,
            right: (collectionView.frame.size.width / 2 - 129) / 1.5
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: FooterCollectionReusableView.identifier,
            for: indexPath
        ) as! FooterCollectionReusableView
        
        footer.configure(isLoading: isRefreshing)
        if isRefreshing { isRefreshing.toggle() }
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        var size = CGSize()

        if self.isLoading {
            size = CGSize(width: view.frame.size.width, height: 36)
            isLoading = false
            isRefreshing = true
        } else {
            size = CGSize(width: 0, height: 0)
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MovieDetailsViewController()
        navigationController?.pushViewController(controller, animated: true)
        let sortedMovies = movies.sorted { ($0.popularity ?? 1) > ($1.popularity ?? 0) }
        let movie = sortedMovies[indexPath.row]
        controller.movieId = movie.movieId
        controller.movieTitle = movie.title
        controller.movieRating = movie.voteAverage
        controller.moviePosterPath = movie.posterPath
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if currentSearchText != searchText {
            currentSearchText = searchText
            movies = []
            currentPage = 1
        }
        loadPage(with: currentSearchText, currentPage)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
