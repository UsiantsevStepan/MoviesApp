//
//  MoviesMainInfoCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 06.01.2021.
//

import UIKit

class MoviesMainInfoCell: UITableViewCell {
    static let reuseId = "MoviesMainInfoCellReuseId"
    
    private let moviePosterImage = UIImageView()
    private let movieTitleLabel = UILabel()
    private let movieOriginalNameAndYearLabel = UILabel()
    private let movieGenresLabel = UILabel()
    private let movieCountryAndRuntimeLabel = UILabel()
    private let movieAdultImageView = UIImageView()
    
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
        [
            moviePosterImage,
            movieTitleLabel,
            movieOriginalNameAndYearLabel,
            movieGenresLabel,
            movieCountryAndRuntimeLabel,
            movieAdultImageView
        ].forEach(self.addSubview)
        
    }
    
    func setConstraints() {
        moviePosterImage.translatesAutoresizingMaskIntoConstraints = false
        moviePosterImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        moviePosterImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        moviePosterImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        moviePosterImage.heightAnchor.constraint(equalToConstant: 180).isActive = true
        moviePosterImage.widthAnchor.constraint(equalToConstant: 121).isActive = true
        
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        movieTitleLabel.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        movieTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        movieOriginalNameAndYearLabel.translatesAutoresizingMaskIntoConstraints = false
        movieOriginalNameAndYearLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 4).isActive = true
        movieOriginalNameAndYearLabel.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        movieOriginalNameAndYearLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        movieGenresLabel.translatesAutoresizingMaskIntoConstraints = false
        movieGenresLabel.topAnchor.constraint(equalTo: movieOriginalNameAndYearLabel.bottomAnchor, constant: 16).isActive = true
        movieGenresLabel.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        movieGenresLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        movieCountryAndRuntimeLabel.translatesAutoresizingMaskIntoConstraints = false
        movieCountryAndRuntimeLabel.topAnchor.constraint(equalTo: movieGenresLabel.bottomAnchor, constant: 4).isActive = true
        movieCountryAndRuntimeLabel.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        movieCountryAndRuntimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        movieAdultImageView.translatesAutoresizingMaskIntoConstraints = false
        movieAdultImageView.topAnchor.constraint(equalTo: movieCountryAndRuntimeLabel.bottomAnchor, constant: 8).isActive = true
        movieAdultImageView.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        movieAdultImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        movieAdultImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func configureSubviews() {
        // Temporary
        moviePosterImage.image = #imageLiteral(resourceName: "Poster")
        movieTitleLabel.text = "Rascal does not dream of a Dreaming Girl"
        movieOriginalNameAndYearLabel.text = "青春ブタ野郎はゆめみる少女の夢を見ない (2019)"
        movieGenresLabel.text = "Anime, Drama, Fantasy"
        movieCountryAndRuntimeLabel.text = "Japan, 1:29"
        movieAdultImageView.image = #imageLiteral(resourceName: "Adult")
        
        movieTitleLabel.numberOfLines = min(countLabelLines(label: movieTitleLabel), 2)
        movieTitleLabel.lineBreakMode = .byWordWrapping
        movieOriginalNameAndYearLabel.numberOfLines = min(countLabelLines(label: movieTitleLabel), 2)
        movieOriginalNameAndYearLabel.lineBreakMode = .byWordWrapping
        
        moviePosterImage.contentMode = .scaleAspectFill
        moviePosterImage.layer.cornerRadius = 8.0
        moviePosterImage.clipsToBounds = true
        
        movieTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        movieOriginalNameAndYearLabel.font = UIFont.systemFont(ofSize: 12)
        
        movieGenresLabel.font = UIFont.systemFont(ofSize: 12)
        movieGenresLabel.textColor = .gray
        
        movieCountryAndRuntimeLabel.font = UIFont.systemFont(ofSize: 12)
        movieCountryAndRuntimeLabel.textColor = .gray
        
        movieAdultImageView.contentMode = .scaleAspectFill
        movieAdultImageView.clipsToBounds = true
    }
    
    // MARK: - Counting lines of specific UILabel
    private func countLabelLines(label: UILabel) -> Int {
        self.layoutIfNeeded()
        let labelText = label.text! as NSString
        
        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = labelText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : label.font!], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
}
