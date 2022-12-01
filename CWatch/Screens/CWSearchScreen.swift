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
    var coins = Response.mockResponse?.data.coins
    
    
    private lazy var numberFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    // MARK: -  UI
    private lazy var coinsTableView : UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(CWCoinCell.self, forCellReuseIdentifier: CWCoinCell.resuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuratin
        configureViewController()
        
        // Layout
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Configuration
private extension CWSearchScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
}

// MARK: - Layout
private extension CWSearchScreen {
    private func layoutViews() {
        view.addSubview(coinsTableView)
    }
}

// MARK: - UITableViewDelegate
extension CWSearchScreen: UITableViewDelegate {
 
}

// MARK: - UITableViewDataSource
extension CWSearchScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CWCoinCell.resuseIdentifier, for: indexPath) as? CWCoinCell else {
            fatalError("failed to dequeue a table view cell")
        }
        
        let coin = coins?[indexPath.row]
        cell.configure(for: coin, formatter: numberFormatter)
        
        return cell
    }
}
