//
//  MoviesMainInfoCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 06.01.2021.
//

import UIKit

class MoviesMainInfoCell: UITableViewCell {
    static let reuseId = "MoviesMainInfoCellReuseId"
    
    private let titleStackView = UIStackView()
    private let genreStackView = UIStackView()
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
        
        moviePosterImage.image = nil
        movieTitleLabel.text = nil
        movieOriginalNameAndYearLabel.text = nil
        movieGenresLabel.text = nil
        movieCountryAndRuntimeLabel.text = nil
        movieAdultImageView.image = nil
    }
    
    func configure(posterPath: String?, title: String?, originalName: String?, year: String?, genres: [String]?, country: String?, runtime: Int?, adult: Bool?) {
        movieTitleLabel.text = title
        movieTitleLabel.numberOfLines = min(countLabelLines(label: movieTitleLabel), 2)
        
        var originalTitleAndYear: [String] = []
        
        if let originalTitle = originalName, !originalTitle.isEmpty {
            originalTitleAndYear.append(originalTitle)
        }
        if let releaseYear = year, !releaseYear.isEmpty {
            originalTitleAndYear.append("(\(releaseYear))")
        }
        
        if originalTitleAndYear.isEmpty {
            movieOriginalNameAndYearLabel.isHidden = true
        } else {
            movieOriginalNameAndYearLabel.isHidden = false
            movieOriginalNameAndYearLabel.text = originalTitleAndYear.joined(separator: " ")
            movieOriginalNameAndYearLabel.numberOfLines = min(countLabelLines(label: movieOriginalNameAndYearLabel), 2)
        }
        
        if let genresNames = genres {
            let formattedGenres = genresNames.joined(separator: ", ")
            movieGenresLabel.text = formattedGenres
        } else {
            movieGenresLabel.isHidden = true
        }
       
        var countryAndRuntimeInfo: [String] = []
        
        if let countryName = country, !countryName.isEmpty {
            countryAndRuntimeInfo.append(countryName)
        }
        if let runtime = runtime, runtime != 0 {
            countryAndRuntimeInfo.append("\(runtime) min")
        }
        
        if countryAndRuntimeInfo.isEmpty {
            movieOriginalNameAndYearLabel.isHidden = true
        } else {
            movieCountryAndRuntimeLabel.text = countryAndRuntimeInfo.joined(separator: ", ")
        }
        
        if adult ?? false {
            movieAdultImageView.image = #imageLiteral(resourceName: "Adult")
        } else {
            movieAdultImageView.isHidden = true
        }
        
        guard let posterPath = posterPath else {
            moviePosterImage.image = #imageLiteral(resourceName: "Poster")
            return
        }
        let posterUrl = URL(string: "https://image.tmdb.org/t/p/w300" + posterPath)
        moviePosterImage.kf.setImage(with: posterUrl, placeholder: #imageLiteral(resourceName: "Poster"))
    }
    
    func addSubviews() {
        [titleStackView, genreStackView, moviePosterImage].forEach(self.addSubview)
        [movieTitleLabel, movieOriginalNameAndYearLabel].forEach(titleStackView.addArrangedSubview)
        [movieGenresLabel, movieCountryAndRuntimeLabel, movieAdultImageView].forEach(genreStackView.addArrangedSubview)
        
    }
    
    func setConstraints() {
        moviePosterImage.translatesAutoresizingMaskIntoConstraints = false
        moviePosterImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        moviePosterImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        moviePosterImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        moviePosterImage.heightAnchor.constraint(equalToConstant: 180).isActive = true
        moviePosterImage.widthAnchor.constraint(equalToConstant: 121).isActive = true
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        titleStackView.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        titleStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        genreStackView.translatesAutoresizingMaskIntoConstraints = false
        genreStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24).isActive = true
        genreStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8).isActive = true
        genreStackView.leadingAnchor.constraint(equalTo: moviePosterImage.trailingAnchor, constant: 16).isActive = true
        genreStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true

        movieAdultImageView.translatesAutoresizingMaskIntoConstraints = false
        movieAdultImageView.leadingAnchor.constraint(equalTo: genreStackView.leadingAnchor).isActive = true
        movieAdultImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        movieAdultImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func configureSubviews() {
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 4
        
        genreStackView.alignment = .leading
        genreStackView.axis = .vertical
        genreStackView.distribution = .equalSpacing
        genreStackView.spacing = 4
        
        movieTitleLabel.lineBreakMode = .byWordWrapping
        movieTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        movieOriginalNameAndYearLabel.lineBreakMode = .byWordWrapping
        
        moviePosterImage.contentMode = .scaleAspectFill
        moviePosterImage.layer.cornerRadius = 8.0
        moviePosterImage.clipsToBounds = true
        
        movieOriginalNameAndYearLabel.font = UIFont.systemFont(ofSize: 12)
        
        movieGenresLabel.font = UIFont.systemFont(ofSize: 12)
        movieGenresLabel.textColor = .gray
        
        movieCountryAndRuntimeLabel.font = UIFont.systemFont(ofSize: 12)
        movieCountryAndRuntimeLabel.textColor = .gray
        
        movieAdultImageView.contentMode = .scaleAspectFit
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
