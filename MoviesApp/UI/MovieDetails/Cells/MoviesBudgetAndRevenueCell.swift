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
    private let numberFormatter = NumberFormatter()
    
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
        
        movieBudgetLabel.text = nil
        movieRevenueLabel.text = nil
    }
    
    func configure(budget: Int?, revenue: Int?) {
        guard let budget = budget, let revenue = revenue else { return }
        numberFormatter.numberStyle = .decimal
        let formattedBudget = numberFormatter.string(from: NSNumber(value: budget))
        let formattedRevenue = numberFormatter.string(from: NSNumber(value: revenue))
        
        if budget == 0 && revenue != 0 {
            movieRevenueLabel.text = "$" + (formattedRevenue ?? "") + " - revenue"
            movieBudgetLabel.text = nil
        } else if budget != 0 && revenue == 0{
            movieBudgetLabel.text = "$" + (formattedBudget ?? "") + " - budget"
            movieRevenueLabel.text = nil
        } else {
            movieBudgetLabel.text = "$" + (formattedBudget ?? "") + " - budget"
            movieRevenueLabel.text = "$" + (formattedRevenue ?? "") + " - revenue"
        }
        
    }
    
    private func addSubviews() {
        [movieBudgetLabel, movieRevenueLabel].forEach(self.addSubview)
    }
    
    private func setConstraints() {
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
    
    private func configureSubviews() {
        movieBudgetLabel.font = UIFont.systemFont(ofSize: 16)
        movieRevenueLabel.font = UIFont.systemFont(ofSize: 16)
    }
}
