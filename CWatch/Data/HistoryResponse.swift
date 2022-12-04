//
//  HistoryResponse.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/1/22.
//

import Foundation

struct HistoryResponse: Decodable {
    let status: String
    let data: HistoryData
}

struct HistoryData: Decodable {
    let history: [History]
}

struct History: Decodable {
    let price: String?
    let timestamp: TimeInterval
    
    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    var pricePoint : Double {
        if let currentPrice = price, let price = Double(currentPrice) {
            return price
        }
        
        return 0.0
    }
}

extension HistoryResponse {
    static var mockResponse : HistoryResponse? {
        guard let filePathUrl = Bundle.main.url(forResource: "coinhistory", withExtension: "json") else {
            return nil
        }
        
        let responseData = try?  Data(contentsOf: filePathUrl)
        
        do {
            if let responseData {
                let response = try JSONDecoder().decode(HistoryResponse.self, from: responseData)
                return response
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}

