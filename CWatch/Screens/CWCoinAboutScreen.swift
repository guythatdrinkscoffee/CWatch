//
//  CWCoinAboutScreen.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/5/22.
//

import UIKit
import SwiftSoup

class CWCoinAboutScreen: UIViewController {
    // MARK: - Properties
    private var coin: Coin
    
    // MARK: -  UI
    private lazy var textView : UITextView  = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
    }()
    
    
    // MARK: - Life Cycle
    init(coin: Coin){
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration
        configureViewController()
        
        // Layout
        layoutViews()
        
        
        setTextViewText(coin.description)
    }
}

// MARK: - Configuration
extension CWCoinAboutScreen {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "About \(coin.symbol)"
    }
}

// MARK: - Layout
extension CWCoinAboutScreen {
    private func layoutViews() {
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Methods
extension CWCoinAboutScreen {
    private func setTextViewText(_ htmlText: String?){
        guard let html = htmlText else { return }
        
        let data = Data(html.utf8)
        
        if let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) {
            
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttributes([.foregroundColor: UIColor.label], range: range)
            textView.attributedText = attributedString
        } else {
            textView.text = "No information about \(coin.name) is available."
        }
    }
}
