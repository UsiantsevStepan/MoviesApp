//
//  VideoCollectionViewCell.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 12.01.2021.
//

import UIKit
import youtube_ios_player_helper

class VideoCollectionViewCell: UICollectionViewCell {
    static let cellId = "VideoCollectionViewCellReuseId"
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private let videoTypeLabel = UILabel()
    private let playerView = YTPlayerView()
    
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
        
        videoTypeLabel.text = nil
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
//    func configure(with movieModel: MoviePreviewCellModel) {
//
//    }
    
    func configure(with name: String) {
        videoTypeLabel.text = name
        videoTypeLabel.numberOfLines = min(countLabelLines(label: videoTypeLabel), 2)
        
    }
    
    private func addSubviews() {
        self.addSubview(videoTypeLabel)
        self.addSubview(playerView)
    }
    
    private func setConstraints() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        videoTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        videoTypeLabel.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 8).isActive = true
        videoTypeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        videoTypeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        videoTypeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func configureSubviews() {
        playerView.load(withVideoId: "70gKWkz5nXs")
        
        videoTypeLabel.textAlignment = .center
        videoTypeLabel.font = UIFont.systemFont(ofSize: 16)
        
        //Temporary
        

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
