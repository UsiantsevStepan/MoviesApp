//
//  UIViewController+ErrorHandling.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.12.2020.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSearchResultsError(text: String) {
        let alert = UIAlertController(title: "No results found", message: "Unfortunately we couln't find a match for '\(text)'. Please try another search.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
