//
//  MoviesTableViewCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    static let reuseId = "MoviesTableViewCellReuseId"
    
    // MARK: - Temporary arrays
    let array = ["Domino qerqereq qereqrqer qerqer qereqqe", "Who", "Звездные войны: Скайуокер. Восход", "Hello", "Wish you were here"]
    let array1 = ["Hello","Hello","Hello","Hello","Hello"]
    
    private let stackView = UIStackView()
    
    private let headerView = UIView()
    private let headerLabel = UILabel()
    private var movies = [MoviePreviewCellModel]()
    
    let headerButton = UIButton()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setConstraints()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
//        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8).isActive = true
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
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(MoviesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesCollectionViewCell.cellId)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureHeaderLabel(with string: String?) {
        headerLabel.text = string
        
        collectionView.reloadData()
    }
    
    func configure(_ data: [MoviePreviewCellModel]) {
        movies = data
        collectionView.reloadData()
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
}

extension MoviesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 129, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
