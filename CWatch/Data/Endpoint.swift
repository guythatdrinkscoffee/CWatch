//
//  Endpoint.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/4/22.
//

import Foundation


struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "coinranking1.p.rapidapi.com"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
    
    static func coins(
        for timePeriod: TimePeriod,
        limit: Int,
        page: Int,
        currencyRef: String = "yhjMzLPhuIDl"
    ) -> Endpoint {
        return Endpoint(
            path: "/coins",
            queryItems: [
                URLQueryItem(name: "timePeriod", value: timePeriod.rawValue),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String((page - 1) * limit)),
                URLQueryItem(name: "referenceCurrencyUuid", value: currencyRef)
            ])
    }
    
    static func coin(
        for uuid: String,
        currencyRef: String = "yhjMzLPhuIDl"
    ) -> Endpoint {
        return Endpoint(
            path: "/coin/\(uuid)",
            queryItems: [
                URLQueryItem(name: "referenceCurrencyUuid", value: currencyRef)
            ])
    }
    
    static func history(
        for uuid: String,
        with timePeriod: TimePeriod,
        currencyRef: String = "yhjMzLPhuIDl"
    ) -> Endpoint {
        return Endpoint(
            path: "/coin/\(uuid)/history",
            queryItems: [
                URLQueryItem(name: "timePeriod", value: timePeriod.rawValue),
                URLQueryItem(name: "referenceCurrencyUuid", value: currencyRef)
            ])
    }
}
