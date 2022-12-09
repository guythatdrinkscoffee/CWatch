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
        limit: Int? = nil,
        page: Int? = nil,
        uuids: [String]? = nil,
        currencyRef: String = "yhjMzLPhuIDl"
    ) -> Endpoint {
        
        var queryItems = [
            URLQueryItem(name: "timePeriod", value: timePeriod.rawValue),
            URLQueryItem(name: "referenceCurrencyUuid", value: currencyRef)
        ]
        
        if let limit = limit, let page = page {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String((page - 1) * limit))
            ])
        }
        
        if let uuids = uuids, !uuids.isEmpty {
            queryItems.append(contentsOf: uuids.map( { URLQueryItem(name: "uuids[]", value: $0)}))
        }
       
        return Endpoint(
            path: "/coins",
            queryItems: queryItems
        )
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
