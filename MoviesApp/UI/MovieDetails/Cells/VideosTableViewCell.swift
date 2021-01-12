//
//  VideosTableViewCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 12.01.2021.
//

import UIKit

class VideosTableViewCell: UITableViewCell {
    static let reuseId = "VideosTableViewCellReuseId"
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
    
    private var videoTypes: [String] = []
    
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
    }
    
    func configure(with videoTypes: [String]) {
        self.videoTypes = videoTypes
        
        collectionView.reloadData()
    }
    
//    func configure(with rating: Double?) {
//        guard let rating = rating else { return }
//        ratingLabel.text = "\(rating)"
//        starsView.rating = rating
//    }
    
    private func addSubviews() {
        self.addSubview(collectionView)
    }
    
    private func setConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 220).isActive = true
    }
    
    private func configureSubviews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellId)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension VideosTableViewCell: UICollectionViewDelegate {
    
}

extension VideosTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.cellId, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: videoTypes[indexPath.row])
        
        return cell
    }
    
    
}

extension VideosTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        cellDelegate?.showMovieDetails(with: indexPath, movies: movies)
//    }
}
