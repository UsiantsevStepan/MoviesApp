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
        starsView.text = "\(rating)"
        starsView.rating = rating
    }
    
    private func addSubviews() {
        self.addSubview(starsView)
    }
    
    private func setConstraints() {
        starsView.translatesAutoresizingMaskIntoConstraints = false
        starsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        starsView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        starsView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        starsView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
    }
    
    private func configureSubviews() {
        starsView.settings.updateOnTouch = false
        starsView.settings.fillMode = .precise
        starsView.settings.starSize = Double(self.frame.height)
        starsView.settings.textFont = UIFont.boldSystemFont(ofSize: starsView.frame.height)
        starsView.settings.textColor = .black
        starsView.settings.starMargin = 4
        starsView.settings.totalStars = 10
    }
}
