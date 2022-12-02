//d
//  Response.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import Foundation

struct Response: Codable {
    let status: String
    let data: CoinData
   
}

struct CoinData: Codable {
    let stats: Stats
    let coins: [Coin]
}

struct Stats: Codable {
    let totalCoins: Int
}

struct Coin: Codable {
    let uuid: String
    let symbol: String
    let name: String
    let iconUrl: String
    let marketCap: String
    let price: String
    let change: String
    let sparkline: [String?]
    
    var currentPrice: Double {
        return Double(price) ?? 0.0
    }
    
    var sparklineData: [Double] {
        return sparkline.compactMap { str in
            return Double(str ?? " ")
        }
    }
    
    var iconUrlPNG: String {
        let pngUrl = iconUrl.replacingOccurrences(of: "svg", with: "png")
        return pngUrl
    }
    
    var priceChange: Double {
        if change.hasPrefix("-"){
            let changeString = change.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
            return -1 * (Double(changeString) ?? 0.0)
        }
        
        return Double(change) ?? 0.0
    }
}

extension Response {
    static var mockResponse : Response? {
        guard let filePathUrl = Bundle.main.url(forResource: "response", withExtension: "json") else {
            return nil
        }
        
        let responseData = try?  Data(contentsOf: filePathUrl)
        
        do {
            if let responseData {
                let response = try JSONDecoder().decode(Response.self, from: responseData)
                return response
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
