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
    var listName: ListName?
    var categories: [(ListName, [MoviePreviewCellModel])] {
        ListName.allCases.map {
            self.moviesManager.getCategories(listName: $0)
        }
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Movies"
        
        tableView.register(MoviesTableViewCell.self, forCellReuseIdentifier: MoviesTableViewCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.moviesManager.loadMovies(1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        listName = movies.0
        cell.delegate = self
        cell.configureList(with: movies.0, movies: movies.1)
        
        return cell
        
        //                cell0.headerButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
}

extension MoviesViewController: MoviesTableViewCellDelegate {
    
    func showFullList(with name: ListName) {
        let controller = ListViewController()
        controller.listName = name
        navigationController?.pushViewController(controller, animated: true)
    }
}
