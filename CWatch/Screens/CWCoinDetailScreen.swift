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
    var coinService = CoinService()
    var coinCancellable: AnyCancellable?
    var historyCancellable: AnyCancellable?
    var history: [TimePeriod: HistoryResponse] = [:]
    
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
        return button
    }()
    private lazy var aboutStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [aboutLabel, bodyLabel, moreButton])
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Life Cycle
    init(coin: Coin){
        self.coinID = coin.uuid
        super.init(nibName: nil, bundle: nil)
        
        // Layout
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
        
        // Fetch the coin information
        fetchCoin()

        // Fetch the coin price history starting with the 3h endpoint.
        fetchHistoryForTimePeriod(timePeriod: .now)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Configuration
private extension CWCoinDetailScreen {
    private func configureViewController(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
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
            
            seperator.topAnchor.constraint(equalTo: timePeriodSelector.bottomAnchor, constant: 20),
            seperator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            seperator.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1),
            
            aboutStackView.topAnchor.constraint(equalTo: seperator.bottomAnchor, constant: 15),
            aboutStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            aboutStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            contentView.heightAnchor.constraint(equalToConstant: 1000),
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
            print(coin)
        coinHeader.configure(for: coin)
        aboutLabel.text = "About \(coin.name)"
        
  
        if let description = coin.description, let fixedString = String(htmlEncodedString: description) {
            bodyLabel.text = fixedString
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
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
}
