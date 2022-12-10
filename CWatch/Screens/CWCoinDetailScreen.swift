//
//  CWCoinDetailScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/1/22.
//

import UIKit
import Charts
import Combine
class CWCoinDetailScreen: UIViewController {
    // MARK: -  Properties
    private var coinID: String
    private var coin: Coin? {
        didSet {
            configure(for: coin)
        }
    }
    private var coinCancellable: AnyCancellable?
    private var historyCancellable: AnyCancellable?
    private var watchlistCancellable : AnyCancellable?
    private var history: [TimePeriod: HistoryResponse] = [:]
    private var coinService: CoinService = CoinService()
    private var watchlistManager: CWWatchlistManager
    private lazy var numberFormatter : NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 4
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    private lazy var chartDateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    // MARK: - UI
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isHidden = true
        return scrollView
    }()
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var coinHeader : CWCoinHeaderView = CWCoinHeaderView()
    
    private lazy var chartView : LineChartView = {
        let chart = LineChartView()
        chart.delegate = self
        chart.translatesAutoresizingMaskIntoConstraints = false
        
        chart.rightAxis.enabled       = false
        chart.legend.enabled          = false
        chart.pinchZoomEnabled        = false
        chart.doubleTapToZoomEnabled = false
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true

        return chart
    }()
    
    private lazy var timePeriodSelector : UISegmentedControl = {
        let control = UISegmentedControl(items: TimePeriod.allCases.map{$0.rawValue})
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(didSelectTimePeriod(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var activityIndicator : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var seperator : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var aboutLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var statsLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Stats"
        return label
    }()
    
    private lazy var bodyLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var moreButton : UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.setTitle("More", for: .normal)
        button.addTarget(self, action: #selector(moreButtonSelected(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private lazy var aboutStackView : UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                aboutLabel,
                bodyLabel,
                moreButton,
                statsLabel
            ])
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.insertSpacer(at: 0)
        stackView.insertSpacer(at: 4)
        return stackView
    }()
    
    // MARK: - Life Cycle
    init(coin: Coin, watchlistManager: CWWatchlistManager){
        self.coinID = coin.uuid
        self.watchlistManager = watchlistManager
        super.init(nibName: nil, bundle: nil)
        
        // Layout
        layoutViews()
        
        // Start animating the indicator
        activityIndicator.startAnimating()
        
    }
    
    init(coin: CWCoin, watchlistManager: CWWatchlistManager) {
        self.coinID = coin.uuid
        self.watchlistManager = watchlistManager
        super.init(nibName: nil, bundle: nil)
        
        layoutViews()
        
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration
        configureViewController()
        configureNavigationBar()
        
        // Fetch the coin information
        fetchCoin()
        
        // Fetch the coin price history starting with the 3h endpoint.
        fetchHistoryForTimePeriod(timePeriod: .now)
        
    }
    
}

// MARK: - Configuration
private extension CWCoinDetailScreen {
    private func configureViewController(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func configureNavigationBar(){
        if watchlistManager.isInWatchlist(uuid: coinID){
            removeFromWatchlistConfig()
        } else {
            addToWatchlistConfig()
        }
    }
    
    private func addToWatchlistConfig() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToWatchlist(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func removeFromWatchlistConfig() {
        let removeButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(removeFromWatchlist(_:)))
        navigationItem.rightBarButtonItem = removeButton
    }
}

// MARK: - Layout
private extension CWCoinDetailScreen {
    private func layoutViews(){
        view.addSubview(activityIndicator)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(coinHeader)
        contentView.addSubview(chartView)
        contentView.addSubview(timePeriodSelector)
        contentView.addSubview(seperator)
        contentView.addSubview(aboutStackView)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: scrollView.trailingAnchor, multiplier: 1),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            coinHeader.topAnchor.constraint(equalTo: contentView.topAnchor),
            coinHeader.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            coinHeader.heightAnchor.constraint(equalToConstant: 100),
            
            chartView.topAnchor.constraint(equalTo: coinHeader.bottomAnchor, constant: 10),
            chartView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            chartView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            timePeriodSelector.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
            timePeriodSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePeriodSelector.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            aboutStackView.topAnchor.constraint(equalTo: timePeriodSelector.bottomAnchor, constant: 15),
            aboutStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1.2),
            aboutStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            contentView.heightAnchor.constraint(equalToConstant: 1050),
        ])
    }
}

// MARK: - Methods
private extension CWCoinDetailScreen {
    private func setChartData(history: [History], with timePeriod: TimePeriod) {
        var dateFormat: String
        
        switch timePeriod {
        case .now, .twentyFourHours:
            chartView.xAxis.setLabelCount(5, force: true)
            dateFormat = "h:mm a"
        case .oneWeek:
            chartView.xAxis.setLabelCount(7, force: true)
            dateFormat = "EEE"
        case .oneYear:
            chartView.xAxis.setLabelCount(12, force: true)
            dateFormat = "MMM"
        case .threeYears:
            chartView.xAxis.setLabelCount(3, force: true)
            dateFormat = "yyyy"
        case .fiveYears:
            chartView.xAxis.setLabelCount(5, force: true)
            dateFormat = "yyyy"
        }
        
        let sanitizedHistory = Array(history.filter({ $0.price != nil }).reversed())
        var entries: [ChartDataEntry] = []
        
        for i in 0..<sanitizedHistory.count {
            let x = Double(i)
            let y = sanitizedHistory[i].pricePoint
            
            let entry = ChartDataEntry(x: x, y: y)
            
            entries.append(entry)
        }
        
        // The dataset that contains the x, y values.
        let dataSet = LineChartDataSet(entries: entries)
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 1.5
        dataSet.mode = .cubicBezier
        dataSet.colors = [.systemTeal.withAlphaComponent(0.8)]
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 2)
        let chartData = LineChartData(dataSet: dataSet)
        
        chartDateFormatter.dateFormat = dateFormat
        let xAxisFormatter = XAxisChartFormatter(dateFormatter: chartDateFormatter, dateValues: history.map{$0.timestamp}.reversed())
        
        numberFormatter.numberStyle = .currency
        let marker = ChartMarker(numberFormatter: numberFormatter, dateFormatter: chartDateFormatter)
        marker.chartView = chartView
        
        chartView.marker = marker
        
        chartView.xAxis.valueFormatter = xAxisFormatter
        chartView.data = chartData
        chartView.notifyDataSetChanged()
    }
    
    private func fetchCoin(){
        // Grab the coin
        coinCancellable = coinService
            .getCoin(endpoint: .coin(for: coinID))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.scrollView.isHidden = false
                }
            }, receiveValue: { coinResponse in
                self.coin = coinResponse.data.coin
            })
    }
    
    private func fetchHistoryForTimePeriod(timePeriod: TimePeriod) {
        let tp = timePeriod
        if let existingHistory = history[tp] {
            setChartData(history: existingHistory.data.history, with: tp)
        } else {
            historyCancellable = coinService
                .getCoinHistory(endpoint: .history(for: coinID, with: timePeriod))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error) : print(error)
                    case .finished: break
                    }
                }, receiveValue: { history in
                    let priceHistory = history.data.history
                    self.history[tp] = history
                    self.setChartData(history: priceHistory, with: tp)
                })
        }
    }
    
    private func configure(for coin: Coin?){
        
        guard let coin = coin else { return }
        
        coinHeader.configure(for: coin)
        aboutLabel.text = "About \(coin.name)"
        
        if let description = coin.description, let fixedString = String(htmlEncodedString: description) {
            bodyLabel.text = fixedString
        } else {
            bodyLabel.text =  "No information about \(coin.name) is available."
            moreButton.isHidden = true
        }
        
        // Add the rank info row
        addInfoRow(with: UIImage(systemName: "crown.fill"), title: "Rank", description: "#\(coin.rank)")
        addInfoRow(with: UIImage(systemName: "chart.bar.fill"), title: "Market Cap", description: formatNumber(Int(coin.marketCap)!))
        
        if let allTimeHigh = coin.allTimeHigh, let priceString = allTimeHigh.price {
            let price = Int(Double(priceString) ?? 0)
            
            addInfoRow(with: UIImage(
                systemName: "chart.line.uptrend.xyaxis"),
                       title: "All Time High",
                       description: formatNumber(price),
                       secodaryDescription: allTimeHigh.date.formatted(.dateTime.month().year()))
        }
        
        if let supply = coin.supply, let circulating = supply.circulating {
            let circulating = Int(Double(circulating) ?? 0)
            
            
            var supplyPercentageString: String?
            
            if supply.exhaustedSupplyPercentage != 0.0 {
                numberFormatter.numberStyle = .percent
                supplyPercentageString = (numberFormatter.string(from: NSNumber(value: supply.exhaustedSupplyPercentage)) ?? "") + " of total supply"
            } else {
                numberFormatter.numberStyle = .currency
                supplyPercentageString = ""
            }
            
            addInfoRow(with: UIImage(systemName: "arrow.triangle.2.circlepath"), title: "Ciculating Supply", description: formatNumber(circulating), secodaryDescription: supplyPercentageString)
        }
    }
    
    func addInfoRow(with symbol: UIImage?, title: String?, description: String?, secodaryDescription: String? = ""){
        let infoRow = CWInfoRow(symbol: symbol, title: title, description: description, secondaryDescription: secodaryDescription)
        
        DispatchQueue.main.async {
            self.aboutStackView.addArrangedSubview(infoRow)
        }
    }
    
    func formatNumber(_ n: Int, decimalPlaces : Int = 1) -> String {
        let num = abs(Double(n))
        
        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: decimalPlaces)
            return  "\(formatted)B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: decimalPlaces)
            return "\(formatted)M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: decimalPlaces)
            return "\(formatted)K"
            
        case 0...:
            return "\n"
            
        default:
            return "\(n)"
        }
    }
}

// MARK: - Selectors
extension CWCoinDetailScreen {
    @objc
    private func didSelectTimePeriod(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let value = sender.titleForSegment(at: selectedIndex)
        
        if let rawValue = value, let timePeriod = TimePeriod(rawValue: rawValue) {
            fetchHistoryForTimePeriod(timePeriod: timePeriod)
        }
    }
    
    @objc
    private func moreButtonSelected(_ sender: UIButton) {
        guard let coin = coin else { return }
        
        let aboutScreen = CWCoinAboutScreen(coin: coin)
        
        navigationController?.pushViewController(aboutScreen, animated: true)
    }
    
    @objc
    private func addToWatchlist(_ sender: UIBarButtonItem) {
        guard let coin = coin else { return }
        
        watchlistCancellable = watchlistManager
            .addToWatchlist(coin)
            .sink(receiveCompletion: { _ in
                DispatchQueue.main.async {
                    self.removeFromWatchlistConfig()
                }
            }, receiveValue: { successful in
                if successful {
                    print("Added to watchlist!")
                }
            })
    }
    
    @objc
    private func removeFromWatchlist(_ sender: UIBarButtonItem) {
        guard let coin = coin else { return }
        
        let alertController = UIAlertController(title: "Remove from watchlist.", message: "Are you sure you want to remove \(coin.name ) from your watchlist?", preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.watchlistCancellable = self.watchlistManager
                .removeFromWatchlist(with: coin.uuid)
                .sink(receiveCompletion: { completion in
                    DispatchQueue.main.async {
                        self.addToWatchlistConfig()
                    }
                }, receiveValue: { success in
                    if success {
                        print("Removed from watchlist.")
                    }
                })
        }
        
        let cancel   = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        
        alertController.addAction(removeAction)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true)
    }
}

// MARK: - ChartViewDelegate
extension CWCoinDetailScreen: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print(#function)
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
      
    }
}
