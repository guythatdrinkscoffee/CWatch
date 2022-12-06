//d
//  Response.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import Foundation

struct CoinResponse: Decodable {
    let status: String
    let data: CoinData
   
}

struct CoinData: Decodable {
    let stats: Stats?
    let coins: [Coin]?
    let coin: Coin?
}

struct Stats: Decodable {
    let totalCoins: Int
}

struct Coin: Decodable {
    let uuid: String
    let symbol: String
    let name: String
    let iconUrl: String
    let marketCap: String
    let price: String
    let change: String
    let rank: Int
    let sparkline: [String?]
    
    //Additional properties from the GetCoin API route
    let websiteUrl: String?
    let numberOfMarkets: Int?
    let numberOfExchanges: Int?
    let description: String?
    let allTimeHigh: AllTimeHigh?
    let supply: Supply?
    
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

struct AllTimeHigh: Decodable {
    let price: String?
    let timestamp: TimeInterval
    
    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }
}

struct Supply: Decodable {
    let max: String?
    let supplyAt: Int?
    let total: String? 
    let circulating: String?
    
    var exhaustedSupplyPercentage: Double {
        if let maxString = max,
           let circulatingString = total,
           let max = Double(maxString),
           let circulating = Double(circulatingString) {
            return circulating / max
        }
        
        return 0.0
    }
}
