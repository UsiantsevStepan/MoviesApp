//
//  MoviesBudgetAndRevenueCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 06.01.2021.
//

import UIKit

class MoviesBudgetAndRevenueCell: UITableViewCell {
    static let reuseId = "MoviesBudgetAndRevenueCellReuseId"
    
    private let movieBudgetLabel = UILabel()
    private let movieRevenueLabel = UILabel()
    
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
    
    func addSubviews() {
        [movieBudgetLabel, movieRevenueLabel].forEach(self.addSubview)
    }
    
    func setConstraints() {
        movieBudgetLabel.translatesAutoresizingMaskIntoConstraints = false
        movieBudgetLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        movieBudgetLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        movieBudgetLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        movieRevenueLabel.translatesAutoresizingMaskIntoConstraints = false
        movieRevenueLabel.topAnchor.constraint(equalTo: movieBudgetLabel.bottomAnchor, constant: 8).isActive = true
        movieRevenueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        movieRevenueLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        movieRevenueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
    }
    
    func configureSubviews() {
        // Temporary
        movieBudgetLabel.text = "Budget: $60 000 000"
        movieRevenueLabel.text = "Revenue: $100 853 753"

        movieBudgetLabel.font = UIFont.systemFont(ofSize: 16)
        movieRevenueLabel.font = UIFont.systemFont(ofSize: 16)
    }
}
