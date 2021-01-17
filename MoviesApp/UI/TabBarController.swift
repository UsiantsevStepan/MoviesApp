//
//  TabBarController.swift
//  MoviesApp
//
//  Created by Степан Усьянцев on 13.01.2021.
//

import UIKit

final class TabBarController: UITabBarController {
    let moviesViewController = UINavigationController(rootViewController: MoviesViewController())
    let searchController = UINavigationController(rootViewController: SearchViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [moviesViewController, searchController]
        moviesViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        searchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
    }
}
