//
//  MoviesCollectionViewCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit
import Kingfisher

class MoviesCollectionViewCell: UICollectionViewCell {
    static let cellId = "CollectionViewCell"
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private let posterImageView = UIImageView()
    private let movieTitleLabel = UILabel()
    private let movieGenreLabel = UILabel()
    private let movieRatingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configureSubviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //        posterImageView.image = nil
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    func configure(with popularMovieModel: MoviePreviewCellModel) {
        movieTitleLabel.text = popularMovieModel.title
        //        requiredHeight(text: movieTitleLabel.text!)
        movieGenreLabel.text = popularMovieModel.genreName
        let labelNumberOfLines = countLabelLines(label: movieTitleLabel)
        if labelNumberOfLines <= 2 {
            movieTitleLabel.numberOfLines = labelNumberOfLines
            movieTitleLabel.lineBreakMode = .byWordWrapping
        } else {
            print("\(movieTitleLabel.frame.size.height)")
            movieTitleLabel.numberOfLines = 0
            movieTitleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        }
        
//        posterImageView.kf.indicatorType = .activity
        let posterUrl = URL(string: "https://image.tmdb.org/t/p/w300" + (popularMovieModel.posterPath ?? ""))
        // TODO: - Create placeholder
        posterImageView.kf.setImage(with: posterUrl)
        
        guard let movieRating = popularMovieModel.voteAverage, popularMovieModel.voteAverage != 0 else {
            movieRatingLabel.isHidden = true
            return
        }
        
        if movieRating >= 7 {
            movieRatingLabel.backgroundColor = .systemGreen
        } else if movieRating < 5 {
            movieRatingLabel.backgroundColor = .systemRed
        } else {
            movieRatingLabel.backgroundColor = .systemGray
        }
        
        movieRatingLabel.text = "\(movieRating)"
    }
    
    private func addSubviews() {
        [
            posterImageView,
            movieTitleLabel,
            movieGenreLabel,
            movieRatingLabel
        ].forEach(self.addSubview)
    }
    
    private func setConstraints() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = true
        posterImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
        posterImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        posterImageView.widthAnchor.constraint(equalToConstant: 121).isActive = true
        
        movieRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        movieRatingLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        movieRatingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        movieRatingLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        movieRatingLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
        
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4).isActive = true
        movieTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = true
        movieTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
        
        movieGenreLabel.translatesAutoresizingMaskIntoConstraints = false
        movieGenreLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor).isActive = true
        movieGenreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = true
        movieGenreLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
        
        if let lastSubview = contentView.subviews.last {
            contentView.bottomAnchor.constraint(equalTo: lastSubview.bottomAnchor, constant: 4).isActive = true            
        }
    }
    
    private func configureSubviews() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.cornerRadius = 8.0
        posterImageView.clipsToBounds = true
//        posterImageView.image = UIImage(named: "Poster")
        
        movieRatingLabel.font = UIFont.boldSystemFont(ofSize: 12)
        movieRatingLabel.textColor = .white
        movieRatingLabel.layer.cornerRadius = 4
        movieRatingLabel.clipsToBounds = true
        movieRatingLabel.textAlignment = .center
        self.bringSubviewToFront(movieRatingLabel)
        
        movieTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        
        movieGenreLabel.font = UIFont.systemFont(ofSize: 8)
        movieGenreLabel.textColor = .gray
    }
    
    // MARK: - Temporary func for searching UILabel frame height
    //    func requiredHeight(text: String) {
    //        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: .max))
    //        label.numberOfLines = 0
    //        label.lineBreakMode = .byWordWrapping
    //        label.font = UIFont.boldSystemFont(ofSize: 10)
    //        label.text = text
    //        label.sizeToFit()
    //        print(label.frame.height)
    //    }
    
    // MARK: - Counting lines of specific UILabel
    func countLabelLines(label: UILabel) -> Int {
        self.layoutIfNeeded()
        let labelText = label.text! as NSString
        
        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = labelText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : label.font!], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
}
