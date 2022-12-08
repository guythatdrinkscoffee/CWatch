//
//  CSWatchlistScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import UIKit

class CWWatchlistScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuration
        configureViewController()
        configureNavigationBar()
    }
}

// MARK: - Configuration
private extension CWWatchlistScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}
