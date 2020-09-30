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
    
    func configure(with text: String) {
        movieTitleLabel.text = text
        requiredHeight(text: movieTitleLabel.text!)
        let labelNumberOfLines = countLabelLines(label: movieTitleLabel)
        if labelNumberOfLines <= 2 {
            movieTitleLabel.numberOfLines = labelNumberOfLines
            movieTitleLabel.lineBreakMode = .byWordWrapping
        } else {
            print("\(movieTitleLabel.frame.size.height)")
            movieTitleLabel.numberOfLines = 0
            movieTitleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        }
    }
    
    private func addSubviews() {
        [posterImageView, movieTitleLabel, movieGenreLabel].forEach(self.addSubview)
    }
    
    private func setConstraints() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        posterImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        posterImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        posterImageView.widthAnchor.constraint(equalToConstant: 121).isActive = true
        
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4).isActive = true
        movieTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        movieTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        movieGenreLabel.translatesAutoresizingMaskIntoConstraints = false
        movieGenreLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor).isActive = true
        movieGenreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        movieGenreLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        if let lastSubview = contentView.subviews.last {
            contentView.bottomAnchor.constraint(equalTo: lastSubview.bottomAnchor, constant: 4).isActive = true            
        }
    }
    
    private func configureSubviews() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.image = UIImage(named: "Poster")
        
        movieTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        
        movieGenreLabel.font = UIFont.systemFont(ofSize: 8)
        movieGenreLabel.textColor = .gray
        movieGenreLabel.text = "Genre"
    }
    
    // MARK: - Temporary func for searching UILabel frame height
    func requiredHeight(text: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: .max))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = text
        label.sizeToFit()
        print(label.frame.height)
    }
    
    // MARK: - Counting lines of specific UILabel
    func countLabelLines(label: UILabel) -> Int {
        self.layoutIfNeeded()
        let labelText = label.text! as NSString
        
        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = labelText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : label.font!], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
}
