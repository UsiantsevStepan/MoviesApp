//
//  MoviesViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit
import CoreData

class MoviesViewController: UITableViewController {
    
    private let moviesTableViewCell = MoviesTableViewCell()
    
    let moviesManager = MoviesManager()
    var categories: [(ListName, [MoviePreviewCellModel])] {
        ListName.allCases.map {
            self.moviesManager.getCategories(listName: $0)
        }
    }
    
    override func viewDidLoad() {
        
        tableView.register(MoviesTableViewCell.self, forCellReuseIdentifier: MoviesTableViewCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        self.moviesManager.loadMovies(1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self.showError(error)
                case .success:
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
        
        let movies = categories[indexPath.row]
        cell.configureList(with: movies.0, movies: movies.1)
        
        return cell
        
        //                cell0.headerButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    
    // MARK: - Add functions to all buttons
    @objc func buttonAction(_ sender: UIButton) {
        print("Tapped")
    }
}
