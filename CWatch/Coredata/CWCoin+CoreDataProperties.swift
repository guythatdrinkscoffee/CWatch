//
//  CWCoin+CoreDataProperties.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/7/22.
//
//

import Foundation
import CoreData


extension CWCoin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CWCoin> {
        return NSFetchRequest<CWCoin>(entityName: "CWCoin")
    }

    @NSManaged public var uuid: String
    @NSManaged public var name: String
    @NSManaged public var symbol: String
    @NSManaged public var change: String
    @NSManaged public var price: String
}

extension CWCoin : Identifiable {

}

extension CWCoin {
    var priceChange: Double {
        if change.hasPrefix("-"){
            let changeString = change.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
            return -1 * (Double(changeString) ?? 0.0)
        }
        
        return Double(change) ?? 0.0
    }
    
    
    var currentPrice: Double {
        return Double(price) ?? 0.0
    }
}
