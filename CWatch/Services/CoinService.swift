//
//  CoinService.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import Foundation
import Combine

enum TimePeriod: String {
    case twentyFourHours = "24h"
}

struct CoinService {
    func getCoins(endpoint: Endpoint) -> Future<Response,Error> {
        Future { promise in
            guard let url = endpoint.url else {
                return promise(.failure(URLError(.badURL)))
            }
            
            let request = buildRequestWithHeaders(for: url)
            
            URLSession.shared.dataTask(with: request) { data, res, err in
                guard err == nil, let data = data,  let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                    return promise(.failure(URLError(.badServerResponse)))
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let response = try decoder.decode(Response.self, from: data)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                    print(error)
                }
            }.resume()
        }
    }
    
    private func buildRequestWithHeaders(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(Secrets.apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(Secrets.apiHost, forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue("Content-Type", forHTTPHeaderField: "application/json")
        return request
    }
}

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
}
