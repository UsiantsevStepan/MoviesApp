//
//  ListViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 01.01.2021.
//

import UIKit

class ListViewController: UIViewController {
    private let moviesManager = MoviesManager()
    private var isRefreshing = false
    private var isListFull = false
    private var pageNumber = 1
    private var movieId: Int?
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
    var isLoading = false
    var listName: ListName?
    var movies: [MoviePreviewCellModel] {
        // MARK: - Check the listName
        //        print("Tapped on " + (listName?.rawValue ?? "NOT"))
        
        guard let listName = listName else { return [] }
        let movies = self.moviesManager.getCategories(listName: listName)
        return movies.1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = listName?.rawValue ?? "List"
        view.backgroundColor = .clear
        
        addSubviews()
        setConstraints()
        configureSubviews()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > 0,
           offsetY > contentHeight - scrollView.frame.height - 100 {
            loadPage()
        }
    }
    
    func loadPage() {
        
        if isLoading || isListFull { return }
        
        isLoading = true
        guard let listName = listName else { return }
        self.moviesManager.loadList(page: pageNumber, listName: listName, { [weak self] result in
            print("page number: \(self?.pageNumber ?? 000)")
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self.showError(error)
                    self.isLoading = false
                    self.pageNumber = 0
                    return
                case let .success(page):
                    if page == nil {
                        self.isLoading = false
                        self.isListFull = true
                    }
                    self.pageNumber += 1
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    private func setConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }
    
    private func configureSubviews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
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
    }
}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.cellId, for: indexPath) as! MoviesCollectionViewCell
        cell.configure(with: movies[indexPath.row])
        
        return cell
    }
}

extension ListViewController: UICollectionViewDelegate {
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
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
        let movie = movies[indexPath.row]
        controller.movieId = movie.movieId
        controller.movieTitle = movie.title
        controller.movieRating = movie.voteAverage
        controller.moviePosterPath = movie.posterPath
    }
}
