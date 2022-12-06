//
//  UIStackView+Ext.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import UIKit


extension UIStackView {
    public func insertSpacer(at index: Int = 0) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .systemGray5
        
        self.insertArrangedSubview(view, at: index)
    }
}
