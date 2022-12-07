//
//  String+Ext.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import Foundation

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

