//
//  MoviesOverviewCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 06.01.2021.
//

import UIKit

class MoviesOverviewCell: UITableViewCell {
    static let reuseId = "MoviesOverviewCellReuseId"
    
    private let movieOverviewLabel = UILabel()
    
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
        
        movieOverviewLabel.text = nil
    }
    
    func configure(with overview: String?) {
        guard let movieOverview = overview else { return }
        movieOverviewLabel.text = movieOverview
    }
    
    private func addSubviews() {
        self.addSubview(movieOverviewLabel)
    }
    
    private func setConstraints() {
        movieOverviewLabel.translatesAutoresizingMaskIntoConstraints = false
        movieOverviewLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        movieOverviewLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        movieOverviewLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        movieOverviewLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
    }
    
    private func configureSubviews() {
        movieOverviewLabel.numberOfLines = 0
        movieOverviewLabel.font = UIFont.systemFont(ofSize: 16)
    }
}
