//
//  CSWatchlistScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import UIKit
import CoreData
import Combine

class CWWatchlistScreen: UIViewController {
    // MARK: - Properties
    private var watchlistManager: CWWatchlistManager
        
    private var serviceCancellable: AnyCancellable?
    
    private var timerCancellable: AnyCancellable?
    
    private var coinService = CoinService()
    
    private var symbols: [String]? = []
    
    private var pollTime = 15.0
    
    private var updatedCoins: [Coin] = [] {
        didSet {
            DispatchQueue.main.async {
                self.watchlistTableView.reloadData()
            }
 
        }
    }
    
    private lazy var numberFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    private lazy var fetchResultsController : NSFetchedResultsController<CWCoin> = {
        let fetchRequest : NSFetchRequest<CWCoin> = CWCoin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: watchlistManager.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    // MARK: - UI
    private lazy var watchlistTableView : UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CWCoinCell.self, forCellReuseIdentifier: CWCoinCell.resuseIdentifier)
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

        // Configuration
        configureViewController()
        configureNavigationBar()
        
        // Layout
        layoutViews()
        
        // Fetch the watchlist
        fetch()
        
        //
        fetchPrices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        endPoll()
    }
}

// MARK: - Layout
private extension CWWatchlistScreen {
    private func layoutViews() {
        view.addSubview(watchlistTableView)
    }
}

// MARK: - Methods
private extension CWWatchlistScreen {
    private func fetch() {
        do {
            try fetchResultsController.performFetch()
            
            symbols = fetchResultsController.fetchedObjects?.compactMap({$0.uuid})
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func startPoll() {
        guard timerCancellable == nil else {
            return
        }
        
        timerCancellable = Timer.publish(every: pollTime, on: .current, in: .default)
            .autoconnect()
            .map({ (_) -> [String] in
                return self.symbols ?? []
            })
            .flatMap({ symb -> AnyPublisher<CoinResponse, Error> in
                guard !symb.isEmpty else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return self.coinService
                    .getCoins(endpoint: .coins(for: .now, uuids: symb))
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveOutput: { coinResp in
                        self.updatedCoins = coinResp.data.coins ?? []
                    })
                    .eraseToAnyPublisher()
            })
            .replaceError(with: CoinResponse(status: "failure", data: CoinData(stats: nil, coins: nil, coin: nil)))
            .sink(receiveValue: { _ in
                print("Prices fetched")
            })
    }
    
    private func endPoll() {
        timerCancellable = nil
    }
    
    private func fetchPrices() {
        serviceCancellable =  self.coinService
            .getCoins(endpoint: .coins(for: .now, uuids: self.symbols))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.startPoll()
            }, receiveValue: { res in
                self.updatedCoins = res.data.coins ?? []
            })
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

// MARK: - UITableViewDelegate
extension CWWatchlistScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCoin = fetchResultsController.object(at: indexPath)
        let detailScreen = CWCoinDetailScreen(coin: selectedCoin, watchlistManager: watchlistManager)
        
        navigationController?.pushViewController(detailScreen, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CWWatchlistScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatedCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CWCoinCell.resuseIdentifier, for: indexPath) as? CWCoinCell else {
            fatalError("failed to dequeue a table view cell")
        }
        
        let coin = updatedCoins[indexPath.row]
        cell.configure(for: coin, formatter: numberFormatter, hideChart: true)
        
        return cell
    }
}

// MARK: - NSFetchResultsControllerDelegate
extension CWWatchlistScreen: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller:
      NSFetchedResultsController<NSFetchRequestResult>) {
        watchlistTableView.reloadData()
        
        symbols = fetchResultsController.fetchedObjects?.compactMap({$0.uuid})
    }
}
