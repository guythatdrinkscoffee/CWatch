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
        viewControllers = [
            configureSearchScreen()
        ]
    }
    private func configureSearchScreen() -> UINavigationController {
        let searchScreen = CWSearchScreen()
        searchScreen.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        searchScreen.title = "Search"
        
        let navController = UINavigationController(rootViewController: searchScreen)
        return navController
    }
}

