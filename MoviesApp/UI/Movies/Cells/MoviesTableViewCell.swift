//
//  MoviesTableViewCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit

protocol MoviesTableViewCellDelegate: class {
    func showFullList(with name: ListName)
    func showMovieDetails(with indexPath: IndexPath, movies: [MoviePreviewCellModel])
    func showPreview(for movie: MoviePreviewCellModel) -> UIViewController?
}

class MoviesTableViewCell: UITableViewCell {
    static let reuseId = "MoviesTableViewCellReuseId"
    
    private let stackView = UIStackView()
    
    private let headerView = UIView()
    private let headerLabel = UILabel()
    private var movies = [MoviePreviewCellModel]()
    
    private var listName: ListName?
    private var movieId: Int?
    
    weak var cellDelegate: MoviesTableViewCellDelegate?
    
    var onDidSelectItem: ((IndexPath) -> ())?
    
    let headerButton = UIButton()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = false
        
        addSubviews()
        setConstraints()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movies = []
        headerLabel.text = nil
    }
    
    private func addSubviews() {
        self.addSubview(stackView)
        
        [headerView, collectionView].forEach(stackView.addArrangedSubview)
        [headerLabel, headerButton].forEach(headerView.addSubview)
    }
    
    private func setConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12).isActive = true
        headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        headerButton.translatesAutoresizingMaskIntoConstraints = false
        headerButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8).isActive = true
        headerButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4).isActive = true
        headerButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: 220).isActive = true
    }
    
    private func configureSubviews() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        stackView.frame = contentView.bounds
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        headerView.clipsToBounds = true
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        headerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        headerButton.setTitle("All", for: .normal)
        headerButton.setTitleColor(.orange, for: .normal)
        headerButton.clipsToBounds = true
        headerButton.addTarget(self, action: #selector(showFullList(_:)), for: .touchUpInside)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(MoviesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesCollectionViewCell.cellId)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureList(with name: ListName, movies: [MoviePreviewCellModel]) {
        headerLabel.text = name.rawValue
        self.movies = movies
        self.listName = name
        
        collectionView.reloadData()
    }
    
    @objc func showFullList(_ sender: UIButton) {
        guard let listName = listName else { return }
        cellDelegate?.showFullList(with: listName)
    }
}

extension MoviesTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.cellId, for: indexPath) as! MoviesCollectionViewCell
        cell.configure(with: movies[indexPath.row])
        
        return cell
    }
}

extension MoviesTableViewCell: UICollectionViewDelegate {
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] () -> UIViewController? in
            guard let self = self else { return nil }
            let movie = self.movies[indexPath.item]
            
            return self.cellDelegate?.showPreview(for: movie)
        }, actionProvider: nil)
    }
}

extension MoviesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 129, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellDelegate?.showMovieDetails(with: indexPath, movies: movies)
    }
}
