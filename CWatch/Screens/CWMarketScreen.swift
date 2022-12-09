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
    private let coinService = CoinService()
    private var pageLimit = 25
    private var page = 1
    private var cancellable: AnyCancellable?
    private var isFetching: Bool = false
    private var coins: [Coin] = []
    private var watchlistManager: CWWatchlistManager
    private lazy var numberFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private lazy var activityIndicator : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: -  UI
    private lazy var coinsTableView : UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(CWCoinCell.self, forCellReuseIdentifier: CWCoinCell.resuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshCoinsData(_:)), for: .valueChanged)
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching Prices ...", attributes: nil)
        return tableView
    }()
    
    // MARK: - Life Cycle
    init(watchlistManager: CWWatchlistManager) {
        self.watchlistManager = watchlistManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Object Initialization
        

        // Configuration
        configureViewController()
        
        // Layout
        layoutViews()
        
        // Start the activity indicator
        activityIndicator.startAnimating()
    }
}

// MARK: - Configuration
private extension CWMarketScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.backButtonTitle = ""
    }
    
 
}

// MARK: - Layout
private extension CWMarketScreen {
    private func layoutViews() {
        view.addSubview(coinsTableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Methods
private extension CWMarketScreen {
    private func fetch() {
        isFetching = true
        
        cancellable = coinService
            .getCoins(endpoint: .coins(for: .twentyFourHours, limit: pageLimit, page: page))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error) : print(error)
                case .finished:
                    // Set isFetching to false to allow further fetching.
                    self.isFetching = false
              
                    // Increase the page count to ensure the offset calculation is correct.
                    self.page += 1
                    
                    if (self.coinsTableView.refreshControl?.isRefreshing ?? false) {
                        self.coinsTableView.refreshControl?.endRefreshing()
                    }
                    
                }
            } receiveValue: { response in
                self.coins.append(contentsOf: response.data.coins ?? [])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.activityIndicator.isAnimating {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    self.coinsTableView.reloadData()
                }
            }
    }
            
    @objc
    private func refreshCoinsData(_ sender: Any) {
        // Start animating the activity indicator
        activityIndicator.startAnimating()
        
        // Reset the fetch page
        page = 1
        
        // Remove all of the current coins in the array
        coins.removeAll()
        
        // Reload the table view
        coinsTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension CWMarketScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get a reference to the selected coin
        let selectedCoin = coins[indexPath.row]
        
        // Navigate to the coin detail screen
        let coinDetailScreen = CWCoinDetailScreen(coin: selectedCoin, watchlistManager: watchlistManager)
        
        // Navigate to the detail screen
        navigationController?.pushViewController(coinDetailScreen, animated: true)
    }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       let lastSectionIndex = tableView.numberOfSections - 1
        
       let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        let spinnerView = UIActivityIndicatorView(style: .medium)
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

