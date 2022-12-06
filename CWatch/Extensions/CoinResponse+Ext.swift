//
//  CoinResponse+Ext.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/6/22.
//

import Foundation


extension CoinResponse {
    static var coinsResponse : CoinResponse? {
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
    
    static var coinResponse : CoinResponse? {
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
