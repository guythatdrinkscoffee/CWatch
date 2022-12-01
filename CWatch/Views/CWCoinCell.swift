//
//  CWCoinCell.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/1/22.
//

import UIKit
import Charts

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
        label.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private lazy var labelStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [coinNameLabel, coinTickerLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var rootStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelStackView, sparkLineChart, coinPriceLabel])
        stackView.distribution = .fill
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
        var time = 0.0
        
        sparkLineChart.xAxis.axisLineColor = .systemGreen
        
        for value in coin.sparklineData{
            let entry = ChartDataEntry(x: time, y: value)
            time += 1
            entries.append(entry)
        }
        
        let set = LineChartDataSet(entries: entries)
        set.drawCirclesEnabled = false
        set.lineWidth  = 1.2
        set.colors = [UIColor.systemGreen]
        
        let dataSet = LineChartData(dataSet: set)
        dataSet.setDrawValues(false)
        
        sparkLineChart.data = dataSet
        sparkLineChart.notifyDataSetChanged()
    }
}

// MARK: - Configuration
extension CWCoinCell {
    public func configure(for coin: Coin?, formatter: NumberFormatter? = nil ) {
        guard let coin = coin else { return }
        
        coinNameLabel.text = coin.name
        coinTickerLabel.text = coin.symbol
        coinPriceLabel.text = formatter?.string(from: coin.currentPrice as NSNumber)
        print(coin.iconUrlPNG)
        
        setData(for: coin)
        
        layoutIfNeeded()
    }
}

// MARK: - Layout
extension CWCoinCell {
    private func layoutViews() {
        contentView.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            rootStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: rootStackView.trailingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: rootStackView.bottomAnchor, multiplier: 1)
        ])
    }
}
