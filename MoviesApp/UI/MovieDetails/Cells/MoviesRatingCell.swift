//
//  MoviesRatingCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 07.01.2021.
//

import UIKit
import Cosmos

class MoviesRatingCell: UITableViewCell {
    static let reuseId = "MoviesRatingCellReuseId"
    
    private let starsView = CosmosView()
    private let ratingLabel = UILabel()
    
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
    
    func configure(with rating: Double?) {
        guard let rating = rating else { return }
        ratingLabel.text = "\(rating)"
        starsView.rating = rating
    }
    
    private func addSubviews() {
        [starsView, ratingLabel].forEach(self.addSubview)
    }
    
    private func setConstraints() {
        starsView.translatesAutoresizingMaskIntoConstraints = false
        starsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        starsView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        starsView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        starsView.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -8).isActive = true
        starsView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        ratingLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        ratingLabel.leadingAnchor.constraint(equalTo: starsView.trailingAnchor, constant: 8).isActive = true
        ratingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        ratingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        ratingLabel.widthAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    private func configureSubviews() {
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 24)
        ratingLabel.textAlignment = .center
        
        starsView.frame.size.height = 24
        starsView.settings.updateOnTouch = false
        starsView.settings.fillMode = .precise
        starsView.settings.starSize = 24
        starsView.settings.starMargin = 4
        starsView.settings.totalStars = 10
    }
}
