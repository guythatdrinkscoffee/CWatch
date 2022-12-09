//
//  ViewController.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import UIKit

class CTMainTabViewController: UITabBarController {
    // MARK: - Properties
    private var watchlistManager: CWWatchlistManager
    
    // MARK: - Life Cycle
    init(watchlistManager: CWWatchlistManager){
        self.watchlistManager = watchlistManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let marketScreen = CWMarketScreen(watchlistManager: watchlistManager)
        marketScreen.tabBarItem = UITabBarItem(title: "Market", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 0)
        marketScreen.title = "Market"
        
        let navController = UINavigationController(rootViewController: marketScreen)
        return navController
    }
    
    private func configureWatchlistScreen() -> UINavigationController {
        let watchlistScreen = CWWatchlistScreen(watchlistManager: watchlistManager)
        watchlistScreen.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(systemName: "eyeglasses"), tag: 1)
        watchlistScreen.title = "Watchlist"
        
        let navController = UINavigationController(rootViewController: watchlistScreen)
        return navController
    }
}

