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
    
    func configure(with rating: Double?, tableViewWidth: CGFloat) {
        guard let rating = rating else { return }
        starsView.text = "\(rating)"
        starsView.rating = rating
        starsView.settings.starSize = Double((tableViewWidth - 16 - labelWidthCount(font: UIFont.boldSystemFont(ofSize: 32), text: "\(rating)")) / 10 - 4)
        starsView.update()
    }
    
    private func addSubviews() {
        addSubview(starsView)
    }
    
    private func setConstraints() {
        starsView.translatesAutoresizingMaskIntoConstraints = false
        starsView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        starsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        starsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        starsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        starsView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    private func configureSubviews() {
        starsView.settings.updateOnTouch = false
        starsView.settings.fillMode = .precise
        starsView.settings.textFont = UIFont.boldSystemFont(ofSize: starsView.frame.height)
        starsView.settings.textColor = .black
        starsView.settings.starMargin = 4
        starsView.settings.totalStars = 10
    }
    
    private func labelWidthCount(font: UIFont, text: String) -> CGFloat {
        let label = UILabel()
        
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.width
    }
}
