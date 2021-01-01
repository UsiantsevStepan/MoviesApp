//
//  ListViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 01.01.2021.
//

import UIKit

class ListViewController: UIViewController {
    private let moviesManager = MoviesManager()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
    var listName: ListName?
    var movies: [MoviePreviewCellModel] {
        // MARK: - Check the listName
        print("Tapped on " + (listName?.rawValue ?? "NOT"))
        
        guard let listName = listName else { return [] }
        let movies = self.moviesManager.getCategories(listName: listName)
        return movies.1
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: - Make title change its name depending on list's name
        navigationItem.title = listName?.rawValue ?? "List"
        view.backgroundColor = .clear
        
        for page in 2...5 {
            guard let listName = listName else { continue }
            self.moviesManager.loadList(page: page, listName: listName, { [weak self] result in
                print("zhopa \(page)")
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case let .failure(error):
                        self.showError(error)
                    case .success:
                        self.collectionView.reloadData()
                    }
                }
            })
        }
        
        addSubviews()
        setConstraints()
        configureSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    private func setConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }
    
    private func configureSubviews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        collectionView.contentInset.top = 16
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(MoviesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesCollectionViewCell.cellId)
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
}
