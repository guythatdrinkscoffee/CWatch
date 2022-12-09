//
//  CWCoin+CoreDataClass.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/7/22.
//
//

import Foundation
import CoreData

@objc(CWCoin)
public class CWCoin: NSManagedObject, Decodable {
    enum CodingKeys: CodingKey {
        case uuid, name, symbol, price, change
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Miscofigured decoder")
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.price = try container.decode(String.self, forKey: .price)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.change = try container.decode(String.self, forKey: .change)
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
