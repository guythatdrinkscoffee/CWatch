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
    var coinID: String
    var coin: Coin? {
        didSet {
            configure(for: coin)
        }
    }
    var coinCancellable: AnyCancellable?
    var historyCancellable: AnyCancellable?
    var history: [TimePeriod: HistoryResponse] = [:]
    var coinService: CoinService = CoinService()
    
    private lazy var numberFormatter : NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter
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
        chart.leftAxis.enabled        = false
        chart.legend.enabled          = false
        chart.pinchZoomEnabled        = false
        chart.doubleTapToZoomEnabled = false
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        
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
    init(coin: Coin){
        self.coinID = coin.uuid
        super.init(nibName: nil, bundle: nil)
        
        // Layout
        layoutViews()
        
        // Start animating the indicator
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration
        configureViewController()
        
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
    private func setChartData(history: [History]) {
        let sanitizedHistory = history.filter({ $0.price != nil })
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
        dataSet.colors = [.systemTeal]
        
        let chartData = LineChartData(dataSet: dataSet)
        
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
            setChartData(history: existingHistory.data.history)
        } else {
            historyCancellable = coinService
                .getCoinHistory(endpoint: .history(for: coinID, with: timePeriod))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error) : print(error)
                    case .finished: print(completion)
                    }
                }, receiveValue: { history in
                    let priceHistory = history.data.history
                    self.history[tp] = history
                    self.setChartData(history: priceHistory)
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
                supplyPercentageString = ""
            }
            
            addInfoRow(with: UIImage(systemName: "arrow.triangle.2.circlepath"), title: "Ciculating Supply", description: formatNumber(circulating, decimalPlaces: 0, numberStyle: .none), secodaryDescription: supplyPercentageString)
        }
    }
    
    func addInfoRow(with symbol: UIImage?, title: String?, description: String?, secodaryDescription: String? = ""){
        let infoRow = CWInfoRow(symbol: symbol, title: title, description: description, secondaryDescription: secodaryDescription)
        
        DispatchQueue.main.async {
            self.aboutStackView.addArrangedSubview(infoRow)
        }
    }
    
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
    
    
    func formatNumber(_ n: Int, decimalPlaces : Int = 1 , numberStyle : NumberFormatter.Style = .currency) -> String {
        let num = abs(Double(n))
        
        
        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: decimalPlaces)
            numberFormatter.numberStyle = numberStyle
            return (numberFormatter.string(from: NSNumber(value: formatted)) ?? " ") + "B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: decimalPlaces)
            numberFormatter.numberStyle = numberStyle
            return (numberFormatter.string(from: NSNumber(value: formatted)) ?? " ") + "M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: decimalPlaces)
            numberFormatter.numberStyle = numberStyle
            return (numberFormatter.string(from: NSNumber(value: formatted)) ?? " ") + "K"
            
        case 0...:
            return numberFormatter.string(from: NSNumber(value: n)) ?? " "
            
        default:
            return "\(n)"
        }
    }
}

// MARK: - ChartViewDelegate
extension CWCoinDetailScreen: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
}

extension String {
    init?(htmlEncodedString: String) {
        let data = Data(htmlEncodedString.utf8)
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
}
