//
//  MoviesViewController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 29.09.2020.
//

import UIKit

class MoviesViewController: UITableViewController {
    
    private let moviesTableViewCell = MoviesTableViewCell()
    
    override func viewDidLoad() {
        
        tableView.register(MoviesTableViewCell.self, forCellReuseIdentifier: MoviesTableViewCell.reuseId)
        tableView.tableFooterView = UIView()
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 400
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell0 = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
                cell0.selectionStyle = .none
                cell0.configureHeaderLabel(with: "Popular")
                cell0.contentView.isUserInteractionEnabled = false
//                cell0.headerButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
                return cell0
            case 1:
                let cell1 = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
                cell1.configureHeaderLabel(with: "Upcoming")
                cell1.contentView.isUserInteractionEnabled = false
                cell1.selectionStyle = .none
                return cell1
            case 2:
                let cell2 = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.reuseId, for: indexPath) as! MoviesTableViewCell
                cell2.configureHeaderLabel(with: "Now playing")
                cell2.contentView.isUserInteractionEnabled = false
                cell2.selectionStyle = .none
                return cell2
            default:
                fatalError("something")
            }
        default:
            fatalError()
        }
    }
    
    // MARK: - Add functions to all buttons
    @objc func buttonAction(_ sender: UIButton) {
        print("Tapped")
    }
}
