//
//  CWSearchScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import UIKit
import Combine
class CWSearchScreen: UIViewController {
    // MARK: - Properties
    let coinServive = CoinService()
    var pageLimit = 5
    var page = 1
    
    var cancellable: AnyCancellable?
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuratin
        configureViewController()
        
        print(Response.mockResponse)
    }
}

// MARK: - Configuration
private extension CWSearchScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
}
