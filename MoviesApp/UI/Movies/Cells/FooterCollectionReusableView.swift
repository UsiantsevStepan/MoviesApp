//
//  FooterCollectionReusableView.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 03.01.2021.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "FooterCollectionReusableView"
    
    private var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    public func configure(isLoading: Bool = false) {
        backgroundColor = .white
        addSubview(activityIndicator)
        
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.frame = bounds
    }
}
