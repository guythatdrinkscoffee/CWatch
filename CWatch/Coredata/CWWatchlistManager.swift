//
//  CWWatchlistManager.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/7/22.
//

import Foundation
import Combine
import CoreData

final class CWWatchlistManager {
    // MARK: - Properties
    enum WatchlistError: Error {
        case saveError(String)
        case deleteError(String)
    }
    private var dataStore: CWDataStore
    
    // MARK: - Life Cycle
    init(dataStore: CWDataStore){
        self.dataStore = dataStore
    }
    
    // MARK: - Methods
    public var context: NSManagedObjectContext {
        return dataStore.managedContext
    }
    
    public func addToWatchlist(_ coin:  Coin) -> Future<Bool, WatchlistError> {
        let newCoin = CWCoin(context: dataStore.managedContext)
        newCoin.uuid = coin.uuid
        newCoin.name = coin.name
        newCoin.symbol = coin.symbol
        
        return Future { promise in
            do {
                let ok = try self.dataStore.save()
                promise(!ok ? .failure(.saveError("Failed to add \(coin.name) to your watchlist.")) : .success(ok))
            } catch {
                print(error.localizedDescription)
                promise(.failure(.saveError(error.localizedDescription)))
            }
        }
    }
    
    public func removeFromWatchlist(coin: CWCoin) -> Future<Bool, WatchlistError> {
        self.dataStore.managedContext.delete(coin)
        
        return Future { promise in
            do {
                let ok = try self.dataStore.save()
                promise(!ok ? .failure(.deleteError("Failed to remove \(coin.name) from your watchlist")) : .success(ok))
            } catch  {
                print(error.localizedDescription)
                promise(.failure(.deleteError(error.localizedDescription)))
            }
        }
    }
    
    
    public func removeFromWatchlist(with uuid: String) -> Future<Bool, WatchlistError> {
        return Future { promise in
            guard let coin = self.fetchCoin(with: uuid) else {
                promise(.failure(.deleteError("The coin does not exist in your watchlist.")))
                return
            }
            
            self.dataStore.managedContext.delete(coin)
            
            do {
                let ok = try self.dataStore.save()
                promise(!ok ? .failure(.deleteError("Failed to remove \(coin.name) from your watchlist")) : .success(ok))
            } catch  {
                print(error.localizedDescription)
                promise(.failure(.deleteError(error.localizedDescription)))
            }
        }
    }
    
    public func isInWatchlist(uuid: String) -> Bool {
        return fetchCoin(with: uuid) != nil
    }
    
    private func fetchCoin(with uuid: String) -> CWCoin? {
        let fetchRequest: NSFetchRequest<CWCoin> = CWCoin.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try dataStore.managedContext.fetch(fetchRequest)
            return result.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
