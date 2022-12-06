//
//  CWInfoRow.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/5/22.
//

import UIKit
import SwiftUI

class CWInfoRow: UIView {
    // MARK: - UI
    private lazy var symbolImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "triangle.fill"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    private lazy var descLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var additionalDescLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemGray
        return label
    }()
    
    
    private lazy var symbolAndLabelStack : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [symbolImageView, titleLabel])
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var rightSideStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [descLabel, additionalDescLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var rootStack : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [symbolAndLabelStack, UIView(), rightSideStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    convenience init(symbol: UIImage?, title: String?, description: String?, secondaryDescription: String? = "") {
        
        self.init(frame: .zero)
        symbolImageView.image = symbol
        titleLabel.text = title
        descLabel.text = description
        additionalDescLabel.text = secondaryDescription
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension CWInfoRow {
    private func layoutViews() {
        addSubview(rootStack)
        
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

struct CWInfoRow_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = CWInfoRow(symbol: UIImage(systemName: "crown.fill"), title: "Rank", description: "#\(1)")
            return view
        }
    }
}
