//
//  CWSearchScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import UIKit
import Combine
class CWMarketScreen: UIViewController {
    // MARK: - Properties
    let coinServive = CoinService()
    var pageLimit = 30
    var page = 1
    var cancellable: AnyCancellable?
    var isFetching: Bool = false
    var coins: [Coin] = [] {
        didSet {
            coinsTableView.reloadData()
        }
    }
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
        tableView.bounces = false
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
}

// MARK: - Configuration
private extension CWMarketScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}

// MARK: - Layout
private extension CWMarketScreen {
    private func layoutViews() {
        view.addSubview(coinsTableView)
    }
}

// MARK: - Methods
private extension CWMarketScreen {
    private func fetch() {
        isFetching = true
        
        cancellable = coinServive
            .getCoins(endpoint: .coins(for: .twentyFourHours, limit: pageLimit, page: page))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error) : print(error)
                case .finished:
                    self.isFetching = false
                    self.page += 1
                }
            } receiveValue: { response in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self.coins.append(contentsOf: response.data.coins)
                }
            }
    }
}

// MARK: - UITableViewDelegate
extension CWMarketScreen: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension CWMarketScreen: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CWCoinCell.resuseIdentifier, for: indexPath) as? CWCoinCell else {
            fatalError("failed to dequeue a table view cell")
        }
        
        let coin = coins[indexPath.row]
        cell.configure(for: coin, formatter: numberFormatter)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let spinnerView = UIActivityIndicatorView(style: .large)
         spinnerView.startAnimating()
         spinnerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
         return spinnerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if coins.isEmpty {
            return 50
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       let lastSectionIndex = tableView.numberOfSections - 1
        
       let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
       let spinnerView = UIActivityIndicatorView(style: .large)
        spinnerView.startAnimating()
        spinnerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        
       if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
           tableView.tableFooterView = spinnerView
           tableView.tableFooterView?.isHidden = false
       }
   }
}

// MARK: - UIScrollViewDelegate
extension CWMarketScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pos = scrollView.contentOffset.y
        
        if pos > (coinsTableView.contentSize.height - 100 - (scrollView.frame.size.height)){
            if isFetching {
                return
            }
            
            self.fetch()
        }
    }
}

