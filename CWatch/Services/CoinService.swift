//
//  CoinService.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 11/30/22.
//

import Foundation
import Combine

enum TimePeriod: String, CaseIterable{
    case now = "3h"
    case twentyFourHours = "24h"
    case oneWeek = "7d"
    case oneYear = "1y"
    case threeYears = "3y" 
    case fiveYears = "5y"
}

struct CoinService {
    func getCoins(endpoint: Endpoint) -> AnyPublisher<CoinResponse, Error>{
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
                    let response = try decoder.decode(CoinResponse.self, from: data)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                    print(error)
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
    
    func getCoinsData(endpoint: Endpoint) -> AnyPublisher<Data, Error>{
        Future { promise in
            guard let url = endpoint.url else {
                return promise(.failure(URLError(.badURL)))
            }
            
            let request = buildRequestWithHeaders(for: url)
            
            URLSession.shared.dataTask(with: request) { data, res, err in
                guard err == nil, let data = data,  let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                    return promise(.failure(URLError(.badServerResponse)))
                }
                
                promise(.success(data))
            }.resume()
        }
        .eraseToAnyPublisher()
    }
    
    func getCoinHistory(endpoint: Endpoint) -> AnyPublisher<HistoryResponse, Error> {
        Future { promise in
            guard let url = endpoint.url else {
                return promise(.failure(URLError(.badURL)))
            }
            
            let request = buildRequestWithHeaders(for: url)
            
            URLSession.shared.dataTask(with: request) { data, res, err in
                guard err == nil, let data = data, let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                    return promise(.failure(URLError(.badServerResponse)))
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
            
                do {
                    let history = try decoder.decode(HistoryResponse.self, from: data)
                    promise(.success(history))
                } catch {
                    promise(.failure(error))
                    print(error)
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
    
    func getCoin(endpoint: Endpoint) -> AnyPublisher<CoinResponse, Error> {
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
                    let response = try decoder.decode(CoinResponse.self, from: data)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                    print(error)
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
    
    
    private func buildRequestWithHeaders(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(Secrets.apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(Secrets.apiHost, forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue("Content-Type", forHTTPHeaderField: "application/json")
        return request
    }
}
