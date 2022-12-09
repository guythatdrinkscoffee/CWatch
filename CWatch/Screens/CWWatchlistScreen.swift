//
//  CSWatchlistScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import UIKit
import CoreData
    
class CWWatchlistScreen: UIViewController {
    // MARK: - Properties
    private var watchlistManager: CWWatchlistManager
    
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
        } catch {
            fatalError(error.localizedDescription)
        }
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
    
}

// MARK: - UITableViewDataSource
extension CWWatchlistScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CWCoinCell.resuseIdentifier, for: indexPath) as? CWCoinCell else {
            fatalError("failed to dequeue a table view cell")
        }
        
        let coin = fetchResultsController.object(at: indexPath)
        cell.configure(for: coin)
        
        return cell
    }
    
    
}

// MARK: - NSFetchResultsControllerDelegate
extension CWWatchlistScreen: NSFetchedResultsControllerDelegate {
    
}
