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

}

extension CWCoin : Identifiable {

}
