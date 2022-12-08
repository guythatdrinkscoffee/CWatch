//
//  ViewController.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import UIKit

class CTMainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration
        configureScreens()
    }
}

// MARK: - Configuration
private extension CTMainTabViewController {
    private func configureScreens () {
        tabBar.tintColor = .label
        
        viewControllers = [
            configureSearchScreen(),
            configureWatchlistScreen()
        ]
    }
    
    private func configureSearchScreen() -> UINavigationController {
        let searchScreen = CWMarketScreen()
        searchScreen.tabBarItem = UITabBarItem(title: "Market", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 0)
        searchScreen.title = "Market"
        
        let navController = UINavigationController(rootViewController: searchScreen)
        return navController
    }
    
    private func configureWatchlistScreen() -> UINavigationController {
        let watchlistScreen = CWWatchlistScreen()
        watchlistScreen.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(systemName: "eyeglasses"), tag: 1)
        watchlistScreen.title = "Watchlist"
        
        let navController = UINavigationController(rootViewController: watchlistScreen)
        return navController
    }
}

