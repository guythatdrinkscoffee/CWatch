//
//  CWCoinHeaderView.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/3/22.
//

import UIKit
import SwiftUI
import PINRemoteImage

class CWCoinHeaderView: UIView {
    // MARK: - UI
    private lazy var coinThumbnailImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "photo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var coinNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Bitcoin"
        return label
    }()
    
    private lazy var coinSymbolLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .black)
        label.textColor = .systemGray
        label.text = "BTC"
        return label
    }()
    
    private lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var labelsStackView : UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                coinSymbolLabel,
                coinNameLabel,
                priceLabel
            ]
        )
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var numberFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - Life Cycle
    convenience init(_ coin: Coin?) {
        self.init(frame: .zero)
        configure(for: coin)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configuration
    public func configure(for coin: Coin?){
        guard let coin = coin else { return }
        
        coinNameLabel.text = coin.name
        coinSymbolLabel.text = coin.symbol
        priceLabel.text =  numberFormatter.string(from: NSNumber(value: coin.currentPrice))
        coinThumbnailImageView.pin_setImage(from: URL(string: coin.iconUrlPNG))
        
        layoutIfNeeded()
    }
    
    // MARK: - Layout
    private func layoutViews() {
        addSubview(labelsStackView)
        addSubview(coinThumbnailImageView)
        
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            labelsStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            labelsStackView.trailingAnchor.constraint(equalTo: coinThumbnailImageView.leadingAnchor),
            
            coinThumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            coinThumbnailImageView.heightAnchor.constraint(equalToConstant: 60),
            coinThumbnailImageView.centerYAnchor.constraint(equalTo: labelsStackView.centerYAnchor),
            
            trailingAnchor.constraint(equalToSystemSpacingAfter: coinThumbnailImageView.trailingAnchor, multiplier: 1.5)
        ])
    }
}

#if canImport(SwiftUI) && DEBUG
struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    func makeUIView(context: Context) -> some UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
#endif

struct CWCoinHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let coin = CoinResponse.coinsReponse?.data.coins![2]
            let headerView = CWCoinHeaderView(coin)
            return headerView
        }
    }
}
