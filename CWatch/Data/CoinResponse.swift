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
}

extension CoinResponse {
    static var coinsReponse : CoinResponse? {
        guard let filePathUrl = Bundle.main.url(forResource: "response", withExtension: "json") else {
            return nil
        }
        
        let responseData = try?  Data(contentsOf: filePathUrl)
        
        do {
            if let responseData {
                let response = try JSONDecoder().decode(CoinResponse.self, from: responseData)
                return response
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    static var coinReponse : CoinResponse? {
        guard let filePathUrl = Bundle.main.url(forResource: "coinresponse", withExtension: "json") else {
            return nil
        }
        
        let responseData = try?  Data(contentsOf: filePathUrl)
        
        do {
            if let responseData {
                let response = try JSONDecoder().decode(CoinResponse.self, from: responseData)
                return response
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
