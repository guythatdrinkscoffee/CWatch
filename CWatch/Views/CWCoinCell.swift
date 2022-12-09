//
//  CWCoinCell.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/1/22.
//

import UIKit
import Charts
import PINRemoteImage

class CWCoinCell: UITableViewCell {
    // MARK: - Properties
    static let resuseIdentifier = String(describing: CWCoinCell.self)
    
    // MARK: - UI
    private lazy var thumbnailImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var coinNameLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var coinTickerLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var coinPriceLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var changeLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .right
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var coinPriceLabelContainer : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var labelStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [coinNameLabel, coinTickerLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var priceLabelsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(),coinPriceLabelContainer])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var rootStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelStackView, sparkLineChart, priceLabelsStackView])
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var sparkLineChart : LineChartView = {
        let chart = LineChartView()
        chart.isUserInteractionEnabled = false
        chart.xAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        return chart
    }()
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sparkLineChart.notifyDataSetChanged()
    }
    
    func setData(for coin: Coin) {
        
        var entries: [ChartDataEntry] = []
    
        for i in 0..<coin.sparklineData.count {
            let entry = ChartDataEntry(x: Double(i), y: coin.sparklineData[i])
            entries.append(entry)
        }
        
        let set = LineChartDataSet(entries: entries)
        set.drawCirclesEnabled = false
        set.lineWidth  = 1.2
        set.colors = [setColor(bool: coin.priceChange > 0.0)]
        
        let dataSet = LineChartData(dataSet: set)
        dataSet.setDrawValues(false)
        
       
        sparkLineChart.data = dataSet
        sparkLineChart.notifyDataSetChanged()
    }
    
    func setColor(bool: Bool, alpha: CGFloat = 1) -> UIColor {
        return bool ? UIColor.green.withAlphaComponent(alpha) : UIColor.red.withAlphaComponent(alpha)
    }
}

// MARK: - Configuration
extension CWCoinCell {
    public func configure(for coin: Coin?, formatter: NumberFormatter? = nil ) {
        guard let coin = coin else { return }
        
        coinNameLabel.text = coin.name
        coinTickerLabel.text = coin.symbol
        coinPriceLabel.text = formatter?.string(from: coin.currentPrice as NSNumber)
        coinPriceLabel.textColor = setColor(bool: coin.priceChange > 0.0)
        coinPriceLabelContainer.backgroundColor = setColor(bool: coin.priceChange > 0.0, alpha: 0.15)
        priceLabelsStackView.addArrangedSubview(UIView())
        
        setData(for: coin)
        
        layoutIfNeeded()
    }
    
    public func configure(for cwCoin: CWCoin?, formatter: NumberFormatter? = nil) {
        guard let coin = cwCoin else { return }
        coinNameLabel.text = coin.name
        coinTickerLabel.text = coin.symbol
        coinPriceLabel.text = formatter?.string(from: coin.currentPrice as NSNumber)
        coinPriceLabel.textColor = setColor(bool: coin.priceChange > 0.0)
        coinPriceLabelContainer.backgroundColor = setColor(bool: coin.priceChange > 0.0, alpha: 0.15)
        changeLabel.text = (cwCoin?.change ?? " ") + "%"
        priceLabelsStackView.addArrangedSubview(changeLabel)
        sparkLineChart.noDataText = " "
        layoutIfNeeded()
    }
}

// MARK: - Layout
extension CWCoinCell {
    private func layoutViews() {
        coinPriceLabelContainer.addSubview(coinPriceLabel)
        
        contentView.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            rootStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: rootStackView.trailingAnchor, multiplier: 2),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: rootStackView.bottomAnchor, multiplier: 1),
            
            coinPriceLabel.topAnchor.constraint(equalTo: coinPriceLabelContainer.topAnchor, constant: 6),
            coinPriceLabel.leadingAnchor.constraint(equalTo: coinPriceLabelContainer.leadingAnchor),
            coinPriceLabel.trailingAnchor.constraint(equalTo: coinPriceLabelContainer.trailingAnchor),
            coinPriceLabel.bottomAnchor.constraint(equalTo: coinPriceLabelContainer.bottomAnchor, constant: -6)
        ])
    }
}
